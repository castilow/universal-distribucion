import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

enum BackgroundType {
  color,
  gradient,
  image,
}

class BackgroundController extends GetxController {
  static BackgroundController get to => Get.find();

  final Rx<BackgroundType> backgroundType = BackgroundType.color.obs;
  final RxInt selectedColorValue = 0xFFFFFFFF.obs; // Default white
  final RxInt selectedGradientIndex = 0.obs;
  final RxString customImagePath = ''.obs;

  // Predefined gradients
  final List<LinearGradient> gradients = [
    const LinearGradient(colors: [Color(0xFF74ebd5), Color(0xFFACB6E5)]),
    const LinearGradient(colors: [Color(0xFFff9a9e), Color(0xFFfecfef)]),
    const LinearGradient(colors: [Color(0xFFa18cd1), Color(0xFFfbc2eb)]),
    const LinearGradient(colors: [Color(0xFF84fab0), Color(0xFF8fd3f4)]),
    const LinearGradient(colors: [Color(0xFFe0c3fc), Color(0xFF8ec5fc)]),
    const LinearGradient(colors: [Color(0xFF43e97b), Color(0xFF38f9d7)]),
    const LinearGradient(colors: [Color(0xFFfa709a), Color(0xFFfee140)]),
    const LinearGradient(colors: [Color(0xFF30cfd0), Color(0xFF330867)]),
    const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]), // Dark Premium
  ];

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final typeIndex = prefs.getInt('bg_type') ?? 0;
    backgroundType.value = BackgroundType.values[typeIndex];
    
    selectedColorValue.value = prefs.getInt('bg_color') ?? 0xFFFFFFFF;
    selectedGradientIndex.value = prefs.getInt('bg_gradient_index') ?? 0;
    customImagePath.value = prefs.getString('bg_image_path') ?? '';
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bg_type', backgroundType.value.index);
    await prefs.setInt('bg_color', selectedColorValue.value);
    await prefs.setInt('bg_gradient_index', selectedGradientIndex.value);
    await prefs.setString('bg_image_path', customImagePath.value);
  }

  void setSolidColor(Color color) {
    backgroundType.value = BackgroundType.color;
    selectedColorValue.value = color.value;
    _saveSettings();
  }

  void setGradient(int index) {
    backgroundType.value = BackgroundType.gradient;
    selectedGradientIndex.value = index;
    _saveSettings();
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      backgroundType.value = BackgroundType.image;
      customImagePath.value = image.path;
      _saveSettings();
    }
  }

  BoxDecoration get currentDecoration {
    switch (backgroundType.value) {
      case BackgroundType.color:
        return BoxDecoration(color: Color(selectedColorValue.value));
      case BackgroundType.gradient:
        if (selectedGradientIndex.value < gradients.length) {
          return BoxDecoration(gradient: gradients[selectedGradientIndex.value]);
        }
        return const BoxDecoration(color: Colors.white);
      case BackgroundType.image:
        if (customImagePath.value.isNotEmpty) {
          return BoxDecoration(
            image: DecorationImage(
              image: FileImage(File(customImagePath.value)),
              fit: BoxFit.cover,
            ),
          );
        }
        return const BoxDecoration(color: Colors.white);
    }
  }
}
