## Copilot Specific Instructions
Always prioritize code context from open tabs and follow the Flutter architecture defined in AI_GUIDELINES.md.

# Cursor Rules for Flutter Project (v_app)

## Stack and Architecture (Logic & State)

### Framework
- Framework: Flutter (Stable).

### State Management
- Use ONLY the `provider` package. Any attempts to introduce riverpod, bloc, get_it, or signals are FORBIDDEN.

### Navigation
- Main screen implemented via PageView in conjunction with BottomNavigationBar. Mandatory support for horizontal swipes between 4-5 main tabs.

### Feature Toggling
- Dashboard screen must control visibility of tabs (AI, VPN, etc.). State must be saved via SharedPreferences.

### Imports
- Use only absolute imports (e.g., package:v_app/...). No relative paths (../../).

## Design System (HAI3 Airy Style)

### General Style
- Overall style: Minimalism, "airy", clean.

### Colors
- Main background: Strictly pure white (#FFFFFF). Contrast black text.

### Paddings
- Paddings: Minimum 20dp for all outer containers and cards.

### Radius
- Border Radius: All buttons, cards, and input elements must have border_radius of at least 24dp.

### Fonts
- Fonts: Headings — minimum 22px, main text — minimum 16px.

## Media and Assets (Assets)

### Icons
- Icons: Strictly SVG format (via flutter_svg). No raster graphics (PNG/JPG) in the interface.

### Animations
- Animations: Use Lottie (JSON) for micro-interactions and system reactions.

### Emojis and Stickers
- Emojis and Stickers: Support Animated WebP (priority) or GIF.

### Images
- Images: For remote photos, use CachedNetworkImage with soft "fade-in" effect.

## Code Quality and Cleanup

### Strict Typing
- No use of `dynamic`. All types must be explicitly declared.

### No Dead Code
- Upon finding any garbage, unused imports, or Riverpod remnants — immediately delete.

### Error Handling
- All async calls must be wrapped in try-catch blocks with logs.

### Widget Structure
- Follow Atomic Design (breakdown into atoms, molecules, organisms in presentation/widgets folder).

### 🌍 Localization & German-Ready UI (i18n)
- No Hardcoded Strings: Запрещено использовать жестко прописанный текст в виджетах. Все строки должны браться из AppLocalizations.of(context)!.
- German Language Support: Учитывать, что немецкие слова на 30-50% длиннее английских/русских.
- Flexible Layouts: * Всегда оборачивать длинные текстовые элементы в Flexible или Expanded внутри Row.
- Использовать overflow: TextOverflow.ellipsis или maxLines для предотвращения выхода текста за границы экрана.
- Запрещено использовать фиксированную ширину (width) для кнопок и текстовых контейнеров — они должны расти вместе с контентом (используй constraints или padding).
- Scalable Fonts: Текст должен корректно переноситься на новую строку, не ломая высоту карточек в стиле HAI3.

## Language and Comments

### Code
- Code: Variable names, functions, and comments in code — in English.

### UI and Explanations
- UI and Explanations: All app interface and responses to user — in Russian.

## Localization

### Internationalization (i18n)
- Forbidden to hardcode strings (text) directly in widgets.
- Use `flutter_localizations` package and .arb file generation.
- All strings must be called via `AppLocalizations.of(context)!.key`.
- Supported languages: Russian (ru), English (en), German (de).
