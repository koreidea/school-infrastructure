import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Singleton TTS service for offline voice explanations.
///
/// **Primary**: Plays pre-recorded MP3 files generated with Microsoft Edge TTS
/// neural voices (en-IN-NeerjaNeural, te-IN-ShrutiNeural) — natural sounding.
///
/// **Fallback**: Uses device's built-in flutter_tts engine when no pre-recorded
/// audio is available for the activity.
class TtsService {
  TtsService._();
  static final TtsService _instance = TtsService._();
  static TtsService get instance => _instance;

  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _initialized = false;
  bool _speaking = false;
  bool _usingPlayer = false;
  void Function(bool)? _currentStateCallback;

  bool get isSpeaking => _speaking;

  /// Initialize TTS engine (for fallback).
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // iOS-specific audio session config
    if (Platform.isIOS) {
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.ambient,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );
    }

    await _tts.setSpeechRate(Platform.isIOS ? 0.48 : 0.42);
    await _tts.setPitch(1.05);
    await _tts.setVolume(1.0);

    _tts.setCompletionHandler(() => _speaking = false);
    _tts.setCancelHandler(() => _speaking = false);
    _tts.setErrorHandler((_) => _speaking = false);

    // Listen to AudioPlayer completion
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed && _usingPlayer) {
        _speaking = false;
        _usingPlayer = false;
        _currentStateCallback?.call(false);
      }
    });
  }

  /// Speak activity by code — tries pre-recorded MP3 first, falls back to TTS.
  Future<void> speakActivity({
    required String activityCode,
    required String language,
    String? fallbackText,
    void Function(bool)? onStateChange,
  }) async {
    await init();
    if (_speaking) await stop();

    final lang = language == 'te' ? 'te' : 'en';
    final assetPath = 'assets/audio/activities/${activityCode}_$lang.mp3';
    _currentStateCallback = onStateChange;

    // Try pre-recorded MP3 first
    try {
      final bytes = await rootBundle.load(assetPath);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(p.join(tempDir.path, '${activityCode}_$lang.mp3'));
      await tempFile.writeAsBytes(bytes.buffer.asUint8List());

      _usingPlayer = true;
      _speaking = true;
      onStateChange?.call(true);

      await _audioPlayer.setFilePath(tempFile.path);
      await _audioPlayer.play();
      return;
    } catch (_) {
      // MP3 not found — fall back to device TTS
    }

    // Fallback: device TTS
    if (fallbackText != null && fallbackText.isNotEmpty) {
      await _speakWithTts(fallbackText, language: language, onStateChange: onStateChange);
    }
  }

  /// Speak arbitrary text using device TTS (fallback).
  Future<void> speak(String text, {String language = 'en', void Function(bool)? onStateChange}) async {
    await init();
    if (_speaking) await stop();
    await _speakWithTts(text, language: language, onStateChange: onStateChange);
  }

  Future<void> _speakWithTts(String text, {String language = 'en', void Function(bool)? onStateChange}) async {
    final langCode = language == 'te' ? 'te-IN' : 'en-IN';
    await _tts.setLanguage(langCode);

    _tts.setCompletionHandler(() {
      _speaking = false;
      onStateChange?.call(false);
    });
    _tts.setCancelHandler(() {
      _speaking = false;
      onStateChange?.call(false);
    });

    _speaking = true;
    _usingPlayer = false;
    onStateChange?.call(true);
    await _tts.speak(text);
  }

  /// Stop current playback (MP3 or TTS).
  Future<void> stop() async {
    if (_usingPlayer) {
      await _audioPlayer.stop();
    } else {
      await _tts.stop();
    }
    _speaking = false;
    _usingPlayer = false;
  }

  /// Compose the full explanation text for TTS fallback.
  static String composeActivityText({
    required String title,
    required String description,
    String? steps,
    String? tips,
    bool isTelugu = false,
  }) {
    final buffer = StringBuffer();

    buffer.write(title);
    buffer.write('. ');
    buffer.writeln(description);

    if (steps != null && steps.isNotEmpty) {
      buffer.writeln();
      buffer.write(isTelugu ? 'దశల వారీ సూచనలు. ' : 'Step by step instructions. ');
      buffer.writeln(steps);
    }

    if (tips != null && tips.isNotEmpty) {
      buffer.writeln();
      buffer.write(isTelugu ? 'చిట్కాలు. ' : 'Some helpful tips. ');
      buffer.writeln(tips);
    }

    return buffer.toString();
  }
}
