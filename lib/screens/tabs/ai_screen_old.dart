// Old AI screen removed
// (file kept as stub to avoid analyzer errors)
void main() {}
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

  Widget _buildInputArea() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return GlassKit.liquidGlass(
          radius: 25,
          child: Container(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add_rounded, color: Colors.blueAccent), // ЕДИНЫЙ СТИЛЬ - ПЛЮС
                  onPressed: () => _showAIAttachmentMenu(),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _textController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: "Message or /draw...", 
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black54
                        ), 
                        border: InputBorder.none
                      ),
                      onSubmitted: _handleSubmitted,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blueAccent), 
                  onPressed: () => _handleSubmitted(_textController.text)
                ),
              ],
            ),
          ),
        );
      },
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

  Widget _aiAction(IconData i, String l, Color c) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30, 
              backgroundColor: c.withOpacity(0.1), 
              child: Icon(i, color: c, size: 30)
            ),
            SizedBox(height: 8),
            Text(
              l, 
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54, 
                fontSize: 12
              )
            ),
          ],
        );
      },
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
