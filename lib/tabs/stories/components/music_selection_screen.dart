import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_audio/just_audio.dart';
import 'package:chat_messenger/api/music_api.dart';
import 'package:chat_messenger/models/story/submodels/story_music.dart';

class MusicSelectionScreen extends StatefulWidget {
  final MusicTrack track;
  final Function(StoryMusic)? onMusicSelected;

  const MusicSelectionScreen({
    super.key,
    required this.track,
    this.onMusicSelected,
  });

  @override
  State<MusicSelectionScreen> createState() => _MusicSelectionScreenState();
}

class _MusicSelectionScreenState extends State<MusicSelectionScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final RxBool _isPlaying = false.obs;
  final RxBool _isLoading = false.obs;
  final RxDouble _currentPosition = 0.0.obs;
  final RxDouble _duration = 0.0.obs;
  final RxDouble _startTime = 0.0.obs;
  final RxDouble _selectedDuration = 30.0.obs; // Máximo 30 segundos
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  bool _hasAutoPlayed = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      debugPrint('🎵 [MUSIC_SELECTION] Inicializando player para: ${widget.track.name}');
      debugPrint('🎵 [MUSIC_SELECTION] Preview URL: ${widget.track.previewUrl ?? "null"}');
      
      if (widget.track.previewUrl == null || widget.track.previewUrl!.isEmpty) {
        debugPrint('⚠️ [MUSIC_SELECTION] No hay preview disponible para esta canción');
        return;
      }

      // Para YouTube, usar el video ID para obtener el audio completo
      bool isYouTube = widget.track.previewUrl!.contains('youtube.com') || 
                       widget.track.previewUrl!.contains('youtu.be');
      
      String audioUrl = widget.track.previewUrl!;
      
      if (isYouTube) {
        // Extraer el video ID de YouTube
        String? videoId = _extractYouTubeVideoId(widget.track.previewUrl!);
        if (videoId != null) {
          // Usar una URL de audio directa de YouTube (formato m3u8 o similar)
          // Nota: Esto puede requerir una librería especializada para obtener el audio real
          // Por ahora, usamos el video ID para referencia
          debugPrint('🎵 [MUSIC_SELECTION] Video de YouTube detectado: $videoId');
          // Usaremos el video ID almacenado en el track
          audioUrl = widget.track.previewUrl!;
        }
      }

      _isLoading.value = true;
      debugPrint('🎵 [MUSIC_SELECTION] Cargando preview desde: ${widget.track.previewUrl}');
      
      // Verificar que la URL sea válida
      try {
        final uri = Uri.parse(widget.track.previewUrl!);
        if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
          throw Exception('URL inválida: ${widget.track.previewUrl}');
        }
        debugPrint('✅ [MUSIC_SELECTION] URL válida: ${uri.scheme}://${uri.host}');
      } catch (e) {
        debugPrint('❌ [MUSIC_SELECTION] URL inválida: $e');
        _isLoading.value = false;
        return;
      }
      
      try {
        debugPrint('📥 [MUSIC_SELECTION] Configurando audio source...');
        
        // Para YouTube, necesitamos una URL de audio directa
        // Por ahora, intentamos cargar la URL tal cual
        if (isYouTube) {
          debugPrint('⚠️ [MUSIC_SELECTION] YouTube requiere procesamiento especial del audio');
          // Mostrar mensaje al usuario
          if (mounted) {
            Get.snackbar(
              'YouTube',
              'Para YouTube, se usará el video completo. Selecciona el segmento que deseas usar.',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 3),
            );
          }
          // Establecer una duración estimada para YouTube (puedes ajustar esto)
          _duration.value = widget.track.duration != null 
              ? (widget.track.duration! / 1000.0) 
              : 180.0; // 3 minutos por defecto
          _isLoading.value = false;
          return;
        }
        
        await _audioPlayer.setUrl(audioUrl);
        debugPrint('✅ [MUSIC_SELECTION] Audio cargado exitosamente');
      } catch (e) {
        debugPrint('❌ [MUSIC_SELECTION] Error cargando audio: $e');
        debugPrint('❌ [MUSIC_SELECTION] Stack trace: ${StackTrace.current}');
        _isLoading.value = false;
        
        // Mostrar error al usuario
        if (mounted) {
          Get.snackbar(
            'Error',
            'No se pudo cargar el preview: $e',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
        }
        return;
      }

      // Escuchar posición
      _positionSubscription = _audioPlayer.positionStream.listen((position) {
        _currentPosition.value = position.inSeconds.toDouble();
        
        // Si llegamos al final de la canción, no resetear automáticamente
        // Permitir que el usuario navegue libremente
        if (position.inSeconds >= _duration.value && _duration.value > 0) {
          _isPlaying.value = false;
        }
      });

      // Escuchar duración
      _durationSubscription = _audioPlayer.durationStream.listen((duration) {
        if (duration != null) {
          _duration.value = duration.inSeconds.toDouble();
          if (_duration.value < 30.0) {
            _selectedDuration.value = _duration.value;
          }
        }
      });

      // Escuchar cambios de estado del player
      _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
        debugPrint('🎵 [MUSIC_SELECTION] Estado del player: ${state.processingState}, playing: ${state.playing}');
        
        // Reproducir automáticamente cuando esté listo (solo una vez)
        if (state.processingState == ProcessingState.ready && 
            !_isPlaying.value && 
            !_hasAutoPlayed) {
          _hasAutoPlayed = true;
          _audioPlayer.play().then((_) {
            _isPlaying.value = true;
            debugPrint('▶️ [MUSIC_SELECTION] Preview iniciado automáticamente');
          }).catchError((e) {
            debugPrint('❌ [MUSIC_SELECTION] Error al reproducir: $e');
            _hasAutoPlayed = false; // Permitir reintentar
          });
        }
        
        if (state.processingState == ProcessingState.completed) {
          _isPlaying.value = false;
          // No resetear la posición al final - permitir que el usuario navegue
          debugPrint('⏹️ [MUSIC_SELECTION] Canción terminada');
        }
      });

      // Intentar obtener duración inmediatamente
      try {
        final duration = await _audioPlayer.duration;
        if (duration != null) {
          _duration.value = duration.inSeconds.toDouble();
          if (_duration.value < 30.0) {
            _selectedDuration.value = _duration.value;
          }
          debugPrint('📏 [MUSIC_SELECTION] Duración obtenida: ${_duration.value}s');
        }
      } catch (e) {
        debugPrint('⚠️ [MUSIC_SELECTION] No se pudo obtener duración inmediatamente: $e');
      }

      _isLoading.value = false;
      debugPrint('✅ [MUSIC_SELECTION] Player inicializado');
      
      // Intentar reproducir después de un breve delay como respaldo
      Future.delayed(const Duration(milliseconds: 800), () async {
        if (!_hasAutoPlayed && !_isPlaying.value) {
          try {
            final state = _audioPlayer.playerState;
            debugPrint('🎵 [MUSIC_SELECTION] Estado del player (respaldo): ${state.processingState}');
            
            if (state.processingState == ProcessingState.ready) {
              debugPrint('▶️ [MUSIC_SELECTION] Reproduciendo preview (respaldo)...');
              await _audioPlayer.play();
              _isPlaying.value = true;
              _hasAutoPlayed = true;
              debugPrint('✅ [MUSIC_SELECTION] Preview reproduciéndose (respaldo)');
            }
          } catch (e) {
            debugPrint('❌ [MUSIC_SELECTION] Error al reproducir (respaldo): $e');
          }
        }
      });
    } catch (e) {
      debugPrint('❌ [MUSIC_SELECTION] Error inicializando player: $e');
      _isLoading.value = false;
    }
  }

  String? _extractYouTubeVideoId(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.host.contains('youtube.com')) {
        return uri.queryParameters['v'];
      } else if (uri.host.contains('youtu.be')) {
        return uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;
      }
    } catch (e) {
      debugPrint('❌ [MUSIC_SELECTION] Error extrayendo video ID: $e');
    }
    return null;
  }

  Future<void> _playPause() async {
    try {
      // Si es YouTube, mostrar mensaje
      bool isYouTube = widget.track.previewUrl?.contains('youtube.com') == true || 
                       widget.track.previewUrl?.contains('youtu.be') == true;
      
      if (isYouTube) {
        Get.snackbar(
          'YouTube',
          'La reproducción completa de YouTube requiere configuración adicional. Puedes seleccionar el segmento que deseas usar.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
        return;
      }
      
      if (_isPlaying.value) {
        await _audioPlayer.pause();
        _isPlaying.value = false;
      } else {
        // Si estamos al final de la canción, volver al inicio
        if (_currentPosition.value >= _duration.value && _duration.value > 0) {
          await _audioPlayer.seek(Duration.zero);
          _currentPosition.value = 0.0;
        }
        await _audioPlayer.play();
        _isPlaying.value = true;
      }
    } catch (e) {
      debugPrint('❌ [MUSIC_SELECTION] Error en play/pause: $e');
    }
  }

  Future<void> _seekTo(double seconds) async {
    try {
      final seekPosition = Duration(seconds: seconds.toInt());
      await _audioPlayer.seek(seekPosition);
      _currentPosition.value = seconds;
    } catch (e) {
      debugPrint('❌ [MUSIC_SELECTION] Error en seek: $e');
    }
  }

  void _selectMusic() {
    final storyMusic = StoryMusic(
      trackId: widget.track.id,
      trackName: widget.track.name,
      artistName: widget.track.artist,
      albumName: widget.track.album,
      previewUrl: widget.track.previewUrl ?? '',
      thumbnailUrl: widget.track.thumbnailUrl,
      youtubeVideoId: widget.track.previewUrl?.contains('youtube.com') == true 
          ? widget.track.id 
          : null,
      startTime: _startTime.value > 0 ? _startTime.value : null,
      duration: _selectedDuration.value,
      isCurrentlyPlaying: false,
      createdAt: DateTime.now(),
    );

    debugPrint('✅ [MUSIC_SELECTION] Música seleccionada:');
    debugPrint('   - Track: ${storyMusic.trackName}');
    debugPrint('   - Inicio: ${storyMusic.startTime}s');
    debugPrint('   - Duración: ${storyMusic.duration}s');

    // Llamar al callback si existe
    widget.onMusicSelected?.call(storyMusic);
    
    Get.back(); // Cerrar esta pantalla
    Get.back(); // Cerrar también la pantalla de búsqueda
  }

  String _formatTime(double seconds) {
    final mins = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasPreview = widget.track.previewUrl != null && 
                       widget.track.previewUrl!.isNotEmpty &&
                       !widget.track.previewUrl!.contains('youtube.com') &&
                       !widget.track.previewUrl!.contains('youtu.be');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Música'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Información de la canción
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: widget.track.thumbnailUrl != null
                      ? CachedNetworkImage(
                          imageUrl: widget.track.thumbnailUrl!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[300],
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[300],
                            child: const Icon(Icons.music_note, size: 50),
                          ),
                        )
                      : Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.music_note, size: 50),
                        ),
                ),
                const SizedBox(width: 16),
                // Información
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.track.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.track.artist,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.track.album.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.track.album,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Controles de preview - Estilo Instagram
          Expanded(
            child: Obx(() {
              if (_isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              bool isYouTube = widget.track.previewUrl?.contains('youtube.com') == true || 
                               widget.track.previewUrl?.contains('youtu.be') == true;

              if (!hasPreview) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.music_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Preview no disponible',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Esta canción no tiene preview disponible.\nPuedes agregarla directamente a tu historia.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Barra de progreso principal (estilo Instagram)
                    Obx(() => Column(
                      children: [
                        // Indicador visual del segmento seleccionado
                        Container(
                          height: 60,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Stack(
                            children: [
                              // Barra de fondo (toda la canción)
                              Positioned.fill(
                                child: Container(
                                  height: 4,
                                  margin: const EdgeInsets.symmetric(vertical: 28),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              // Segmento seleccionado (resaltado)
                              if (_duration.value > 0)
                                Positioned(
                                  left: ((_startTime.value / _duration.value) * (MediaQuery.of(context).size.width - 80)).clamp(0.0, double.infinity),
                                  width: ((_selectedDuration.value / _duration.value) * (MediaQuery.of(context).size.width - 80)).clamp(0.0, double.infinity),
                                  top: 28,
                                  child: Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              // Indicador de posición actual
                              if (_duration.value > 0)
                                Positioned(
                                  left: ((_currentPosition.value / _duration.value) * (MediaQuery.of(context).size.width - 80)).clamp(0.0, MediaQuery.of(context).size.width - 80),
                                  top: 0,
                                  child: Container(
                                    width: 4,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: _isPlaying.value ? Theme.of(context).primaryColor : Colors.grey[600],
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        
                        // Tiempos
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatTime(_currentPosition.value),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              _formatTime(_duration.value),
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        ),
                        
                        // Información del segmento seleccionado
                        Container(
                          margin: const EdgeInsets.only(top: 15),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text('Inicio', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                  Text(
                                    _formatTime(_startTime.value),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Container(width: 1, height: 30, color: Colors.grey[300]),
                              Column(
                                children: [
                                  Text('Duración', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                  Text(
                                    _formatTime(_selectedDuration.value),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),

                    const SizedBox(height: 30),

                    // Botón play/pause grande (centrado)
                    Obx(() => IconButton(
                      iconSize: 80,
                      icon: Icon(
                        _isPlaying.value ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: _playPause,
                    )),

                    const SizedBox(height: 40),

                    // Selector de inicio (deslizable)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Seleccionar inicio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Obx(() => Text(
                              _formatTime(_startTime.value),
                              style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
                            )),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Obx(() {
                          final maxStart = (_duration.value - _selectedDuration.value).clamp(0.0, _duration.value);
                          return Slider(
                            value: _startTime.value.clamp(0.0, maxStart),
                            min: 0.0,
                            max: maxStart > 0 ? maxStart : 0.0,
                            onChanged: maxStart > 0 ? (value) {
                              _startTime.value = value;
                              if (!isYouTube) {
                                _audioPlayer.seek(Duration(seconds: value.toInt()));
                                _currentPosition.value = value;
                              }
                            } : null,
                          );
                        }),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Selector de duración
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Duración del clip', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Obx(() => Text(
                              '${_formatTime(_selectedDuration.value)} / 30s',
                              style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
                            )),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Obx(() => Slider(
                          value: _selectedDuration.value.clamp(5.0, 30.0),
                          min: 5.0,
                          max: (_duration.value - _startTime.value).clamp(5.0, 30.0),
                          onChanged: (value) {
                            _selectedDuration.value = value;
                            final maxStart = (_duration.value - value).clamp(0.0, _duration.value);
                            if (_startTime.value > maxStart) {
                              _startTime.value = maxStart;
                            }
                          },
                        )),
                      ],
                    ),

                    if (isYouTube) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Para YouTube, selecciona el segmento que deseas usar. El video completo estará disponible en tu historia.',
                                style: TextStyle(fontSize: 12, color: Colors.orange[900]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ),

          // Botón de seleccionar
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectMusic,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Usar esta música',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

