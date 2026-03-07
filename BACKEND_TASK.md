# Knoty — Задание бэкендеру (FINAL v2)

## Контекст
Делаем новое приложение Knoty на основе vtalk_app.
Бэкенд — копия vtalk на новом немецком сервере с изменениями ниже.
Все данные хранятся только в Германии (GDPR обязательно).
Веб-панель администратора: Knoty Admin (отдельный веб-проект).

---

## Что убираем из vtalk
- Всё VPN: серверы, конфиги, ping, статусы подключения
- Эндпоинты: /servers, /vpn-config, /connect и подобные

---

## Роли (UserRole)

```
appAdmin    — суперадмин. Полный доступ ко всему.
schoolAdmin — администратор конкретной школы.
teacher     — учитель своей школы.
parent      — родитель, привязан к ребёнку.
student     — ученик.
```

### appAdmin может:
- Создавать аккаунты школ
- Назначать schoolAdmin
- Одобрять любых пользователей
- Настраивать GlobalSettings (лимиты песочницы и т.д.)
- Генерировать коды для любой школы
- Видеть всех пользователей системы
- Банить и удалять любые аккаунты

### schoolAdmin может (только в своей школе):
- Одобрять учеников, родителей, учителей
- Связывать родителей с детьми
- Генерировать активационные коды
- Добавлять расписания и кружки
- Банить и удалять аккаунты своей школы

---

## Новая модель пользователя

```
UserModel {
  id:                  string
  email:               string
  firstName:           string
  lastName:            string
  role:                enum(student|parent|teacher|schoolAdmin|appAdmin)
  verificationLevel:   enum(sandbox|schoolVerified|fullyVerified)
  isApproved:          boolean
  status:              enum(active|banned|deleted)
  schoolId:            string | null
  classId:             string | null
  parentId:            string | null
  childId:             string | null
  limits: {
    dailyMinutes:      int
    dailyAiRequests:   int
    chatCurfewHour:    int | null
  }
  bannedAt:            datetime | null
  bannedBy:            userId | null
  banReason:           string | null
  createdAt:           datetime
}
```

Дефолты лимитов берутся из GlobalSettings при создании.

---

## GlobalSettings

Настраивается appAdmin. Клиент получает при старте.

```
GlobalSettings {
  sandboxDailyMinutes:          int   (default: 30)
  sandboxAiRequests:            int   (default: 10)
  schoolVerifiedDailyMinutes:   int   (default: 60)
  schoolVerifiedAiRequests:     int   (default: 30)
  activationCodeExpiryDays:     int   (default: 90)
  appName:                      string ("Knoty")
  maintenanceMode:              boolean
}
```

```
GET  /settings/global           — публичный, клиент при старте
PUT  /admin/settings/global     — только appAdmin
```

---

## Школы

```
School {
  id:          string
  name:        string
  city:        string
  address:     string
  adminId:     string (schoolAdmin userId)
  createdAt:   datetime
}
```

```
POST /admin/schools/create
{
  name, city, address,
  adminEmail,     ← создаёт аккаунт schoolAdmin автоматически
  adminFirstName,
  adminLastName
}
Доступно: только appAdmin

GET  /admin/schools             — список школ. Только appAdmin
GET  /schools                   — публичный список (id + name + city) для экрана регистрации
```

---

## Регистрация

### Путь А: с активационным кодом
```
POST /auth/register
{
  email, password,
  firstName, lastName,
  activationCode: "KNOTY-XXXX-XXXX"
}
```
Бэкенд проверяет:
1. Код существует и status = unused
2. Код не истёк
3. firstName + lastName совпадают с теми что привязаны к коду
4. Если всё ок → verificationLevel = schoolVerified, isApproved = true
5. schoolId + classId + role берутся из кода
6. Код → status = used, usedBy = userId

Если имя не совпадает → ошибка "Name stimmt nicht überein"
Если код использован → ошибка "Code bereits verwendet"
Если истёк → ошибка "Code abgelaufen"

### Путь Б: без кода
```
POST /auth/register
{
  email, password,
  firstName, lastName,
  schoolId, classId,
  role: "student" | "parent" | "teacher"
}
```
- verificationLevel = sandbox
- isApproved = false
- Ждёт одобрения schoolAdmin или appAdmin

### Проверка кода до регистрации (UX)
```
POST /auth/verify-code
{
  code:      "KNOTY-XXXX-XXXX",
  firstName: string,
  lastName:  string
}
Ответ: { valid: bool, schoolName, className, role }
```
Показать пользователю: "Code gültig — Goethe Gymnasium, Klasse 5B. Stimmt das?"
Если имя не совпадает — valid: false.

---

## Активационные коды

Формат: `KNOTY-[A-Z0-9]{4}-[A-Z0-9]{4}`
Исключить: I, O, 1, 0

```
ActivationCode {
  code:        string (unique)
  schoolId:    string
  classId:     string
  role:        student | teacher
  firstName:   string   ← привязан к конкретному ученику
  lastName:    string   ← только он может использовать
  status:      unused | used | expired
  usedBy:      userId | null
  expiresAt:   datetime
  createdBy:   adminId
}
```

```
POST /admin/codes/generate
{
  schoolId, classId, role,
  students: [              ← массив учеников с именами
    { firstName, lastName },
    { firstName, lastName },
    ...
  ],
  expiresInDays: int
}
Ответ: [
  { firstName, lastName, code: "KNOTY-XXXX-XXXX" },
  ...
]
Доступно: schoolAdmin (своя школа), appAdmin (любая)

GET /admin/codes?schoolId=&classId=&status=
Список кодов. Доступно: schoolAdmin, appAdmin
```

---

## Одобрение пользователей

```
GET  /admin/users/pending
     schoolAdmin → только своя школа
     appAdmin    → все

POST /admin/users/:id/approve
{
  verificationLevel: "schoolVerified" | "fullyVerified",
  schoolId?: string,
  classId?:  string
}

POST /admin/users/:id/link-parent
{ parentId: string, childId: string }
```

---

## Бан и удаление аккаунтов

```
POST /admin/users/:id/ban
{
  reason: string
}
— status → banned. Пользователь не может войти.
— Токены инвалидируются немедленно.
Доступно: schoolAdmin (своя школа), appAdmin (все)

POST /admin/users/:id/unban
— status → active
Доступно: schoolAdmin (своя школа), appAdmin (все)

DELETE /admin/users/:id
— Мягкое удаление: status → deleted, данные анонимизируются (GDPR)
— email → "deleted_[id]@knoty.de"
— firstName/lastName → "Gelöschter Nutzer"
— Чаты и сообщения заменить на "Nachricht gelöscht"
Доступно: schoolAdmin (своя школа), appAdmin (все)
```

Клиент должен обрабатывать 403 с кодом `ACCOUNT_BANNED` — показывать экран бана.

---

## Лимиты

```
PATCH /parent/child/:childId/limits
{
  dailyMinutes:    int,
  dailyAiRequests: int,
  chatCurfewHour:  int | null
}
Доступно: parent (fullyVerified, только свой ребёнок), appAdmin

GET /users/:id/limits
```

---

## Типы чатов

```
chatType: enum(direct | personalGroup | classGroup | teacherStudent)
```

**direct** — личный чат. Без изменений из vtalk.

**personalGroup** — личная группа пользователя.
- Доступно всем включая sandbox
- Создаёт любой пользователь из своих контактов
- Нет привязки к школе

**classGroup** — школьный чат класса.
- Только schoolVerified+
- Привязан к schoolId + classId
- Создаётся автоматически при верификации
- teacher = модератор, student = участник, parent = observer (только чтение)

---

## Что оставляем без изменений из vtalk
- JWT авторизация
- Direct messages
- Push-уведомления
- Базовые поля профиля

---

## Приоритет для MVP
1. GlobalSettings API
2. Schools API (create + list)
3. Auth (register + verify-code)
4. Activation codes (generate с привязкой имён)
5. Admin approve API
6. Ban/unban/delete API
7. User limits API
8. Parent-child linking
9. Chat types (personalGroup + classGroup)
