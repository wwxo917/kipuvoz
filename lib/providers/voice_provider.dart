import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/voice_command_service.dart';
import '../data/services/ai_command_service.dart';
import 'supabase_providers.dart';

final aiCommandServiceProvider = Provider<AiCommandService>((ref) =>
    AiCommandService(ref.watch(supabaseClientProvider)));

final voiceCommandServiceProvider = Provider<VoiceCommandService>((ref) =>
    VoiceCommandService(aiService: ref.watch(aiCommandServiceProvider)));
