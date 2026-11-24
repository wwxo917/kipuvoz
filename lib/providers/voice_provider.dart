import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/voice_command_service.dart';

final voiceCommandServiceProvider = Provider<VoiceCommandService>((ref) {
  return VoiceCommandService();
});