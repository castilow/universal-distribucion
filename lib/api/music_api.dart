import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:chat_messenger/config/app_config.dart';

class MusicTrack {
  final String id;
  final String name;
  final String artist;
  final String album;
  final String? previewUrl;
  final String? thumbnailUrl;
  final int? duration; // en milisegundos

  MusicTrack({
    required this.id,
    required this.name,
    required this.artist,
    required this.album,
    this.previewUrl,
    this.thumbnailUrl,
    this.duration,
  });
}

abstract class MusicApi {
  static String? _spotifyAccessToken;
  static DateTime? _tokenExpiry;

  /// Buscar canciones en Spotify
  static Future<List<MusicTrack>> searchSpotify(String query) async {
    try {
      debugPrint('🎵 [MUSIC_API] Buscando en Spotify: $query');
      
      // Obtener token de acceso
      final accessToken = await _getSpotifyAccessToken();
      if (accessToken == null) {
        debugPrint('❌ [MUSIC_API] No se pudo obtener el token de Spotify');
        throw Exception('No se pudo obtener el token de Spotify');
      }

      debugPrint('✅ [MUSIC_API] Token de Spotify obtenido');

      // Buscar canciones (aumentar límite para tener más opciones con preview)
      final encodedQuery = Uri.encodeComponent(query);
      final url = Uri.parse(
        'https://api.spotify.com/v1/search?q=$encodedQuery&type=track&limit=50&market=US',
      );

      debugPrint('🔍 [MUSIC_API] URL de búsqueda Spotify: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('📡 [MUSIC_API] Respuesta Spotify: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tracks = data['tracks']?['items'] as List? ?? [];

        debugPrint('🎵 [MUSIC_API] Encontradas ${tracks.length} canciones en Spotify');

        final results = tracks.map((track) {
          try {
            final album = track['album'] as Map<String, dynamic>? ?? {};
            final artists = track['artists'] as List? ?? [];
            final artistNames = artists
                .map((a) => (a as Map<String, dynamic>?)?['name'] as String? ?? '')
                .where((name) => name.isNotEmpty)
                .join(', ');

            final trackName = track['name'] as String? ?? 'Sin título';
            final trackId = track['id'] as String? ?? '';
            final previewUrl = track['preview_url'] as String?;
            final images = album['images'] as List? ?? [];
            final thumbnailUrl = images.isNotEmpty && images[0] != null
                ? ((images[0] as Map<String, dynamic>?)?['url'] as String?)
                : null;
            final duration = track['duration_ms'] as int?;

            // Log detallado del preview
            if (previewUrl != null && previewUrl.isNotEmpty) {
              debugPrint('🎵 [MUSIC_API] Track Spotify: $trackName - $artistNames');
              debugPrint('   ✅ Preview URL disponible: ${previewUrl.substring(0, previewUrl.length > 50 ? 50 : previewUrl.length)}...');
            } else {
              debugPrint('🎵 [MUSIC_API] Track Spotify: $trackName - $artistNames');
              debugPrint('   ⚠️ Preview URL no disponible para esta canción');
            }

            return MusicTrack(
              id: trackId,
              name: trackName,
              artist: artistNames.isNotEmpty ? artistNames : 'Desconocido',
              album: album['name'] as String? ?? '',
              previewUrl: previewUrl,
              thumbnailUrl: thumbnailUrl,
              duration: duration,
            );
          } catch (e) {
            debugPrint('❌ [MUSIC_API] Error procesando track de Spotify: $e');
            return null;
          }
        }).whereType<MusicTrack>().toList();

        // Priorizar canciones con preview (ponerlas primero)
        results.sort((a, b) {
          final aHasPreview = a.previewUrl != null && a.previewUrl!.isNotEmpty;
          final bHasPreview = b.previewUrl != null && b.previewUrl!.isNotEmpty;
          if (aHasPreview && !bHasPreview) return -1;
          if (!aHasPreview && bHasPreview) return 1;
          return 0;
        });

        final withPreview = results.where((t) => t.previewUrl != null && t.previewUrl!.isNotEmpty).length;
        debugPrint('✅ [MUSIC_API] Retornando ${results.length} tracks válidos de Spotify (${withPreview} con preview)');
        return results;
      } else {
        debugPrint('❌ [MUSIC_API] Error en respuesta Spotify: ${response.statusCode} - ${response.body}');
        throw Exception('Error al buscar en Spotify: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [MUSIC_API] Error buscando música en Spotify: $e');
      throw Exception('Error buscando música: $e');
    }
  }

  /// Obtener las canciones más populares de Spotify
  static Future<List<MusicTrack>> getPopularTracks() async {
    try {
      final accessToken = await _getSpotifyAccessToken();
      if (accessToken == null) {
        throw Exception('No se pudo obtener el token de Spotify');
      }

      // Obtener playlists populares
      final url = Uri.parse(
        'https://api.spotify.com/v1/browse/featured-playlists?limit=1',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Por ahora retornamos lista vacía, se puede mejorar
        return [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Obtener token de acceso de Spotify (Client Credentials Flow)
  static Future<String?> _getSpotifyAccessToken() async {
    try {
      // Verificar si el token aún es válido (válido por 1 hora)
      if (_spotifyAccessToken != null && 
          _tokenExpiry != null && 
          DateTime.now().isBefore(_tokenExpiry!)) {
        return _spotifyAccessToken;
      }

      final credentials = base64Encode(
        utf8.encode('${AppConfig.spotifyClientId}:${AppConfig.spotifyClientSecret}'),
      );

      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'grant_type=client_credentials',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _spotifyAccessToken = data['access_token'] as String;
        // El token expira en 1 hora, guardamos la hora de expiración
        _tokenExpiry = DateTime.now().add(const Duration(hours: 1));
        return _spotifyAccessToken;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Buscar música en YouTube
  static Future<List<MusicTrack>> searchYouTube(String query) async {
    try {
      debugPrint('🎵 [MUSIC_API] Buscando en YouTube: $query');
      
      if (AppConfig.youtubeApiKey.isEmpty) {
        debugPrint('⚠️ [MUSIC_API] YouTube API Key no configurada');
        return [];
      }

      final encodedQuery = Uri.encodeComponent(query);
      final url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/search?'
        'part=snippet&'
        'q=$encodedQuery&'
        'type=video&'
        'videoCategoryId=10&' // Categoría de música
        'maxResults=20&'
        'key=${AppConfig.youtubeApiKey}',
      );

      debugPrint('🔍 [MUSIC_API] URL de búsqueda YouTube: $url');

      final response = await http.get(url);

      debugPrint('📡 [MUSIC_API] Respuesta YouTube: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List? ?? [];

        debugPrint('🎵 [MUSIC_API] Encontrados ${items.length} videos en YouTube');

        final results = items.map((item) {
          try {
            final snippet = item['snippet'] as Map<String, dynamic>? ?? {};
            final idData = item['id'] as Map<String, dynamic>? ?? {};
            final videoId = idData['videoId'] as String? ?? '';
            final title = snippet['title'] as String? ?? 'Sin título';
            final channelTitle = snippet['channelTitle'] as String? ?? 'Desconocido';
            final thumbnails = snippet['thumbnails'] as Map<String, dynamic>?;
            final highThumbnail = thumbnails?['high'] as Map<String, dynamic>?;
            final thumbnailUrl = highThumbnail?['url'] as String?;
            
            debugPrint('🎵 [MUSIC_API] Track YouTube: $title - $channelTitle (ID: $videoId)');
            
            return MusicTrack(
              id: videoId,
              name: title,
              artist: channelTitle,
              album: '',
              thumbnailUrl: thumbnailUrl,
              // YouTube no proporciona preview URL directamente, pero podemos usar el video ID
              previewUrl: videoId.isNotEmpty ? 'https://www.youtube.com/watch?v=$videoId' : null,
            );
          } catch (e) {
            debugPrint('❌ [MUSIC_API] Error procesando item de YouTube: $e');
            return null;
          }
        }).whereType<MusicTrack>().toList();

        debugPrint('✅ [MUSIC_API] Retornando ${results.length} tracks válidos de YouTube');
        return results;
      } else {
        try {
          final errorData = json.decode(response.body);
          final errorMsg = errorData['error']?['message'] as String? ?? response.statusCode.toString();
          debugPrint('❌ [MUSIC_API] Error en respuesta YouTube: ${response.statusCode} - $errorMsg');
        } catch (_) {
          debugPrint('❌ [MUSIC_API] Error en respuesta YouTube: ${response.statusCode}');
        }
        return [];
      }
    } catch (e) {
      // Si hay error, retornar lista vacía en lugar de lanzar excepción
      debugPrint('❌ [MUSIC_API] Error buscando música en YouTube: $e');
      return [];
    }
  }
  
  /// Buscar música en ambas plataformas (Spotify y YouTube)
  static Future<List<MusicTrack>> searchAll(String query) async {
    try {
      debugPrint('🎵 [MUSIC_API] Buscando en todas las plataformas: $query');
      
      final results = await Future.wait([
        searchSpotify(query).catchError((e) {
          debugPrint('❌ [MUSIC_API] Error en Spotify: $e');
          return <MusicTrack>[];
        }),
        searchYouTube(query).catchError((e) {
          debugPrint('❌ [MUSIC_API] Error en YouTube: $e');
          return <MusicTrack>[];
        }),
      ]);
      
      // Combinar resultados, Spotify primero
      final combined = [
        ...results[0],
        ...results[1],
      ];
      
      debugPrint('✅ [MUSIC_API] Total de resultados: ${combined.length} (Spotify: ${results[0].length}, YouTube: ${results[1].length})');
      
      return combined;
    } catch (e) {
      debugPrint('❌ [MUSIC_API] Error en searchAll: $e');
      return [];
    }
  }
}

