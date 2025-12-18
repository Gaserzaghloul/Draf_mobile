import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

typedef VoiceIntentHandler = Future<void> Function(BuildContext context);

class VoiceCommandService {
  static final VoiceCommandService _instance = VoiceCommandService._internal();
  factory VoiceCommandService() => _instance;
  VoiceCommandService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isListening = false;
  bool get isListening => _isListening;

  Future<void> initialize() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }

  Future<void> startListening({
    required BuildContext context,
    required Map<String, VoiceIntentHandler> intents,
  }) async {
    if (_isListening) {
      return;
    }

    // Request microphone permission
    final micPermission = await Permission.microphone.request();
    if (!micPermission.isGranted) {
      debugPrint('Voice: Microphone permission denied');
      await speak("Microphone permission is required for voice commands.");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission required'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
          }
        },
        onError: (errorNotification) {
          _isListening = false;
          // Only speak if it's a critical error or permanent failure.
          if (errorNotification.errorMsg != 'error_no_match') {
            // speak("I didn't catch that. Please try again.");
          }
        },
      );

      if (available) {
        _isListening = true;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Listening... (Speak "Help", "Status", or "Devices")',
              ),
              duration: Duration(seconds: 4),
            ),
          );
        }

        // Provide audio feedback
        await speak("Listening");

        await _speech.listen(
          onResult: (result) async {
            if (result.finalResult) {
              _isListening = false;
              await _speech.stop();

              final command = result.recognizedWords.toLowerCase();

              // Find matching intent
              bool handled = false;
              // Check exact matches or "contains" logic
              for (final entry in intents.entries) {
                // Split intent keys by comma to allow aliases (e.g. "help,sos,emergency")
                final aliases = entry.key
                    .split(',')
                    .map((e) => e.trim().toLowerCase())
                    .toList();

                for (final alias in aliases) {
                  if (command.contains(alias)) {
                    await speak("Executing $alias");
                    if (context.mounted) {
                      await entry.value(context);
                    }
                    handled = true;
                    break;
                  }
                }
                if (handled) break;
              }

              if (!handled) {
                await speak("Sorry, I didn't understand the command $command.");
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Unknown: "$command"')),
                  );
                }
              }
            }
          },
          // Try to force on-device recognition for reliability.
          // onDevice: true,
          localeId: 'en_US',
          listenFor: const Duration(seconds: 10),
          pauseFor: const Duration(seconds: 3),
          // ignore: deprecated_member_use
          cancelOnError: false, // Keep listening even if minor error occurs
        );
      } else {
        _isListening = false;
        await speak("Speech recognition is not available on this device.");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Speech recognition not available')),
          );
        }
      }
    } catch (e) {
      _isListening = false;
      debugPrint('Voice: Exception during startListening: $e');
      await speak("An error occurred with voice commands.");
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Voice error: $e')));
      }
    }
  }

  Future<void> stopListening(BuildContext context) async {
    if (!_isListening) return;
    _isListening = false;
    await _speech.stop();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Voice: Stopped')));
    }
  }
}