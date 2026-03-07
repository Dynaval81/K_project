import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vtalk_app/core/constants.dart';
import 'package:vtalk_app/core/constants/app_constants.dart';
import 'package:vtalk_app/core/controllers/ai_controller.dart';
import 'package:vtalk_app/presentation/widgets/molecules/chat_input_field.dart';
import 'package:vtalk_app/presentation/widgets/molecules/message_bubble.dart';

/// V-Assistant distinct bubble color (light purple).
const Color kAiBubbleColor = Color(0xFFF3E5F5);

/// Subtle gradient background for AI chat.
const LinearGradient kAiBackgroundGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFFF8F5FA),
    Color(0xFFFDFBFF),
  ],
);

/// HAI3 Screen: AI Assistant chat with V-Assistant (Airy + distinct style).
class AiAssistantScreen extends StatelessWidget {
  const AiAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AIController(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: kAiBackgroundGradient),
          child: SafeArea(
            child: Consumer<AIController>(
            builder: (context, ai, _) => Column(
              children: [
                _buildAppBar(context),
                Expanded(child: _buildMessageList(context)),
                ChatInputField(onSendMessage: ai.sendUserMessage),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white.withValues(alpha: 0.85),
      elevation: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: kAiBubbleColor,
            child: Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            'V-Assistant',
            style: TextStyle(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.delete_outline, color: AppColors.onSurfaceVariant),
          onPressed: () => context.read<AIController>().clearChat(),
        ),
        IconButton(
          icon: Icon(Icons.person_outline_rounded, color: AppColors.onSurface),
          onPressed: () => context.push(AppRoutes.settings),
        ),
      ],
    );
  }

  Widget _buildMessageList(BuildContext context) {
    return Consumer<AIController>(
      builder: (context, ai, _) {
        if (ai.messages.isEmpty && !ai.isThinking) {
          return _buildEmptyState(context);
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          reverse: true,
          itemCount: ai.messages.length + (ai.isThinking ? 1 : 0),
          itemBuilder: (context, index) {
            if (ai.isThinking && index == 0) {
              return _buildThinkingBubble(context);
            }
            final msgIndex = ai.isThinking ? index - 1 : index;
            final message = ai.messages[ai.messages.length - 1 - msgIndex];
            final isPreviousFromSame = msgIndex < ai.messages.length - 1 &&
                ai.messages[ai.messages.length - 2 - msgIndex].isMe == message.isMe;
            return MessageBubble(
              message: message,
              isMe: message.isMe,
              isPreviousFromSameSender: isPreviousFromSame,
              receiverBubbleColor: kAiBubbleColor,
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 56, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'Chat with V-Assistant',
            style: AppTextStyles.body.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask anything – I\'ll respond in a moment.',
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThinkingBubble(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: kAiBubbleColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Thinking...',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
