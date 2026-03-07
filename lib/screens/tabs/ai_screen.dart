import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../../utils/glass_kit.dart';
import '../../theme_provider.dart';
import '../../constants/app_constants.dart';
import '../../widgets/vtalk_header.dart';
import '../account_settings_screen.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String? imageUrl;

  ChatMessage({required this.text, required this.isUser, this.imageUrl});
}

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});
  
  @override
  _AIScreenState createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Делаем системную панель навигации прозрачной
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ));
  }

  void _handleSubmitted(String text) async {
    if (text.isEmpty) return;
    _textController.clear();

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    await Future.delayed(Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isTyping = false;
        // Если сообщение начинается с /draw, имитируем генерацию картинки
        if (text.toLowerCase().startsWith('/draw')) {
          _messages.add(ChatMessage(
            text: "Generating: ${text.replaceFirst('/draw', '')}",
            isUser: false,
            imageUrl: "https://picsum.photos/seed/${_random.nextInt(1000)}/400/300", // Рандомная картинка
          ));
        } else {
          // Используем Neural Bubbles для ответов ИИ
          _messages.add(ChatMessage(text: _generateAIResponse(text), isUser: false));
        }
      });
      _scrollToBottom();
    }
  }

  String _generateAIResponse(String userText) {
    return "I received your message: '$userText'. I'm currently in preview mode. Matrix integration coming in v0.2!";
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // (removed unused compat adapter)

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            Expanded(
              child: _buildMessagesList(), // Твои сообщения
            ),
            // Нижнюю панель оборачиваем в SafeArea только снизу
            SafeArea(
              top: false,
              child: _buildChatStyleInput(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // 🚨 ИСПРАВЛЕНО: Оборачиваем VtalkHeader в SliverToBoxAdapter
        SliverToBoxAdapter(
          child: VtalkHeader(
            title: 'TALK AI', // Убираем "V", оставляем "TALK AI"
            showScrollAnimation: false,
            // Mercury logo customizations handled internally now
            actions: [
              GestureDetector(
                behavior: HitTestBehavior.translucent, // 🚨 НОВОЕ: Разрешаем свайп назад
                onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => const AccountSettingsScreen()),
                ),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage("${AppConstants.defaultAvatarUrl}?u=me"),
                  ),
                ),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    'How can I help you?',
                    style: TextStyle(
                      color: Provider.of<ThemeProvider>(context, listen: false).isDarkMode ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Actions grid
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    _aiTile(Icons.image, 'Create Image', Colors.purpleAccent, () => _onAction('create_image')),
                    _aiTile(Icons.photo_library, 'Edit Photo', Colors.orangeAccent, () => _onAction('edit_photo')),
                    _aiTile(Icons.text_snippet, 'Improve Text', Colors.teal, () => _onAction('improve_text')),
                    _aiTile(Icons.translate, 'Translate Text', Colors.indigo, () => _onAction('translate')),
                    _aiTile(Icons.help_outline, 'Explain', Colors.green, () => _onAction('explain')),
                  ],
                ),
                const SizedBox(height: 24),
                // small note
                Center(
                  child: Text(
                    'Choose an action above or write below',
                    style: TextStyle(color: Provider.of<ThemeProvider>(context, listen: false).isDarkMode ? Colors.white54 : Colors.black54, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 200),
              ],
            ),
          ),
        ),
        // Сообщения с Neural Bubbles
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              final message = _messages[index];
              if (message.isUser) {
                // Сообщение пользователя - стандартный стиль
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GlassKit.liquidGlass(
                      radius: 15,
                      isDark: Provider.of<ThemeProvider>(context).isDarkMode,
                      opacity: 0.15,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        padding: const EdgeInsets.all(16),
                        child: Text(message.text, style: TextStyle(color: Provider.of<ThemeProvider>(context).isDarkMode ? Colors.white : Colors.black)),
                      ),
                    ),
                  ),
                );
              } else {
                // Сообщение ИИ - Neural Bubbles
                return _buildVTalkAIMessage(message.text);
              }
            },
            childCount: _messages.length,
          ),
        ),
        // Индикатор печати ИИ
        if (_isTyping)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Column(
                children: [
                  // Мерцающая аура
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.purpleAccent.withOpacity(0.3),
                          Colors.blueAccent.withOpacity(0.3),
                          Colors.purpleAccent.withOpacity(0.3),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'VTalk AI is thinking...',
                    style: TextStyle(
                      color: Provider.of<ThemeProvider>(context).isDarkMode ? Colors.white54 : Colors.black54,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }


  void _showAIAttachmentMenu() {
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black45,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => GlassKit.liquidGlass(
        radius: 32,
        isDark: Provider.of<ThemeProvider>(context).isDarkMode,
        opacity: 0.15,
        useBlur: true,
        child: Container(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Заголовок
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Прикрепить',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Опции вложений для AI
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _buildAIAttachOption(Icons.photo_library_rounded, "Photo", Colors.blueAccent),
                  _buildAIAttachOption(Icons.camera_alt_rounded, "Camera", Colors.pinkAccent),
                  _buildAIAttachOption(Icons.location_on_rounded, "Location", Colors.greenAccent),
                  _buildAIAttachOption(Icons.text_fields_rounded, "Text", Colors.orangeAccent),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIAttachOption(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected: $label')),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }


  Widget _aiTile(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 28, backgroundColor: color.withOpacity(0.12), child: Icon(icon, color: color, size: 26)),
          const SizedBox(height: 8),
          SizedBox(
            width: 120,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Provider.of<ThemeProvider>(context, listen: false).isDarkMode ? Colors.white70 : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  void _onAction(String key) {
    switch (key) {
      case 'create_image':
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selected: Create Image')));
        break;
      case 'edit_photo':
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selected: Edit Photo')));
        break;
      case 'improve_text':
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selected: Improve Text')));
        break;
      case 'translate':
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selected: Translate Text')));
        break;
      case 'explain':
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selected: Explain')));
        break;
    }
  }

  Widget _buildChatStyleInput(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4), // МИНИМАЛЬНЫЕ ОТСТУПЫ
      child: GlassKit.liquidGlass(
        radius: 40, // Идеально гладкая форма
        useBlur: true,
        isDark: isDark,
        opacity: 0.12, // Делаем очень легким, чтобы не перегружать
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            // Тонкий бортик для ощущения премиальности
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Кнопка вложений - ЕДИНИЙ СТИЛЬ с чатами
              _buildInputCircleButton(
                icon: Icons.add_rounded, // ЕДИНЫЙ СТИЛЬ - ПЛЮС
                color: Colors.purpleAccent,
                onTap: () => _showAIAttachmentMenu(),
              ),
              
              const SizedBox(width: 8),
              
              Expanded(
                child: TextField(
                  controller: _textController,
                  maxLines: 4,
                  minLines: 1,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: "Ask VTalk AI...",
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white30 : Colors.black38,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  ),
                  onSubmitted: _handleSubmitted,
                ),
              ),

              // Кнопка отправки - "Заряженная" градиентом
              GestureDetector(
                onTap: () => _handleSubmitted(_textController.text),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueAccent,
                        Colors.purpleAccent.shade400,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purpleAccent.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_upward_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Вспомогательный виджет для кнопок внутри инпута
  Widget _buildInputCircleButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: color.withOpacity(0.7), size: 24),
    );
  }

  Widget _buildVTalkAIMessage(String text) {
  final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

  return Align(
    alignment: Alignment.centerLeft, // ИИ всегда слева
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Маленькая подпись над баблом
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 12, color: Colors.purpleAccent.withOpacity(0.8)),
              const SizedBox(width: 4),
              Text("VTALK AI", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.purpleAccent.withOpacity(0.8), letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 4),
          
          // Основное тело сообщения
          GlassKit.liquidGlass(
            radius: 20,
            useBlur: true,
            isDark: isDark,
            opacity: 0.15,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                // НЕОНОВАЯ РАМКА: создаем эффект свечения
                border: Border.all(
                  color: Colors.purpleAccent.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Текст сообщения
                  Padding(
                    padding: const EdgeInsets.only(right: 12), // Место для иконки
                    child: Text(
                      text,
                      style: TextStyle(
                        color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                  // ИКОНКА SPARKLES: в нижнем правом углу
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: Colors.purpleAccent.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
