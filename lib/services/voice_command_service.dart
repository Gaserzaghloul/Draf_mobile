import 'package:flutter/material.dart';

typedef VoiceIntentHandler = Future<void> Function(BuildContext context);

class VoiceCommandService {
  static final VoiceCommandService _instance = VoiceCommandService._internal();
  factory VoiceCommandService() => _instance;
  VoiceCommandService._internal();

  bool _isListening = false;
  bool get isListening => _isListening;

  Future<void> startListening({
    required BuildContext context,
    required Map<String, VoiceIntentHandler> intents,
  }) async {
    if (_isListening) return;
    _isListening = true;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice: Listening... (scaffold)'),
        duration: Duration(seconds: 2),
      ),
    );

    // Demo: simulate a recognized phrase by showing a chooser dialog
    await Future.delayed(const Duration(milliseconds: 300));
    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                leading: Icon(Icons.mic),
                title: Text('Voice command (demo)'),
                subtitle: Text('Select an intent to simulate recognition'),
              ),
              ...intents.entries.map((e) => ListTile(
                    leading: const Icon(Icons.play_arrow),
                    title: Text(e.key),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await e.value(context);
                    },
                  )),
            ],
          ),
        );
      },
    );

    _isListening = false;
  }

  Future<void> stopListening(BuildContext context) async {
    if (!_isListening) return;
    _isListening = false;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice: Stopped')),
    );
  }
}


