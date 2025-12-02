# Messaging Feature Documentation

## 📁 Feature Structure

The Messaging feature follows **Clean Architecture** with three main layers:

### **Presentation Layer** (`presentation/`)
- **Pages**: User-facing screens
  - `Messages.dart` - Main messages/conversations list
  - `Chat.dart` - Individual chat conversation
  - `Message.dart` - Single message detail view
  - `Notofication.dart` - Notifications list
- **Widgets**: Reusable UI components
  - `chat_message_bubble.dart` - Message bubble widget
  - `message_card_widget.dart` - Message card widget

### **Domain Layer** (`domain/`)
- **Entities**: Core business logic objects
  - `message_entity.dart` - Message data model
  - `chat_entity.dart` - Chat conversation model
  - `notification_entity.dart` - Notification model
- **Repositories**: Abstract repository interfaces
- **UseCases**: Business logic operations

### **Data Layer** (`data/`)
- **Models**: Entity extensions with serialization
  - `message_model.dart`
  - `chat_model.dart`
  - `notification_model.dart`
- **DataSources**: API/local data access
  - Remote data sources (API calls)
  - Local data sources (Caching)
- **Repositories**: Concrete implementations

---

## 🎨 Page Features

### **Messages.dart**
**Purpose**: Display all conversations/chats
- **Features**:
  - List of all doctor/patient conversations
  - Doctor name, specialty, and avatar
  - Last message preview
  - Unread message badge (red)
  - Online/offline status indicator (green dot)
  - Time since last message (5m, 2h, 3d ago)
  - Tap to open Chat page
- **Colors**: Blue tinted avatar backgrounds, red unread badges
- **Responsive**: Uses ScreenUtil for all sizes

### **Chat.dart**
**Purpose**: Real-time conversation interface
- **Features**:
  - Message bubbles (left for receiver, right for sender)
  - Timestamps for each message
  - Online status in header
  - Input field for typing messages
  - Add button for attachments
  - Send button for messages
  - Reverse ListView for new messages at bottom
- **Colors**: Blue bubbles for sender, gray for receiver
- **Styling**: Rounded corners, proper spacing, readable fonts

### **Message.dart**
**Purpose**: View a single message in detail
- **Features**:
  - Sender profile card with avatar
  - Online/offline status badge
  - Full message content display
  - Message timestamp
  - Quick reply buttons (Understood, Thanks, Will do, Okay)
  - Reply CTA button
- **Colors**: Light backgrounds, color-coded status
- **Interactive**: Quick reply buttons change message workflow

### **Notofication.dart**
**Purpose**: Alert and notification center
- **Features**:
  - Categorized notifications (appointments, medication, results, alerts, etc.)
  - Read/unread status (blue dot for unread)
  - Notification type icons (emoji)
  - Color-coded notification types
  - Time formatting (just now, 2m ago, etc.)
  - Tap to mark as read
  - More menu for batch actions
- **Colors**: Different background colors per notification type
- **Icons**: Emoji icons for quick visual identification

---

## 🎯 Design Specifications

### **Typography**
- **Font Family**: Montserrat (custom weights 300-700)
- **Sizes**:
  - Headers: 16.sp
  - Body text: 12-14.sp
  - Secondary text: 10-11.sp

### **Colors**
- **Primary Blue**: `#004AAD` (AppColors.primaryBlue6)
- **Accent Red**: `#FF3131` (AppColors.primaryRed5)
- **Text Dark**: `#333333` (AppColors.white06)
- **Text Light**: `#7F7F7F` (AppColors.white04)
- **Backgrounds**: White (#FFFFFF) and light gray (#F9F9F9)

### **Spacing**
- Uses `flutter_screenutil` for responsive sizing
- Consistent padding: 12.w (horizontal), 8.h-16.h (vertical)
- Border radius: 12-16.r for cards, 20.r for pills
- Gaps between elements: 4-12.h

### **Components**
- **Avatar**: 56.w circles with initials/emoji
- **Unread Badge**: Red pills (8.w × 8.w) with count
- **Online Indicator**: Green 14.w circle in corner
- **Bubbles**: Max width 75% of screen, rounded corners
- **Cards**: 16.r radius with light backgrounds

---

## 🚀 Usage Examples

### Navigate to Messages Page
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => MessagesPage()),
);
```

### Navigate to Chat Page
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ChatPage(chat: chatItem),
  ),
);
```

### Navigate to Message Detail
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MessagePage(
      senderName: 'Dr. Ijeoma',
      senderAvatar: '👨‍⚕️',
      profession: 'Cardiologist',
      message: 'Get well soon.',
      messageTime: DateTime.now(),
      isOnline: true,
    ),
  ),
);
```

### Navigate to Notifications
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => NotificationPage()),
);
```

---

## 🔄 Integration Points

### **With Navigation/Drawer**
Add to drawer in `lib/features/Home/presentation/widget/drawer.dart`:
```dart
DrawerItem(label: 'Messages', assetPath: AssetsIcon.mail),
```

### **Next Steps**
1. Create BLoC for state management
2. Implement API service layer
3. Add local database caching (Hive/SQLite)
4. Implement WebSocket for real-time messaging
5. Add image/file attachment support
6. Implement voice messaging
7. Add group chat functionality

---

## 📱 Responsive Behavior
All pages use `flutter_screenutil` for automatic scaling:
- Works on phones (320w - 430w)
- Scales text, spacing, and components proportionally
- Maintains 16:9 design ratios across devices
- Tested on various screen sizes

---

## 🎨 Dark Mode Support
All pages support both light and dark themes:
- Detects theme with `Theme.of(context).brightness`
- Adjusts colors conditionally
- Maintains proper contrast in both modes
- Uses `AppColors` constants for consistency

