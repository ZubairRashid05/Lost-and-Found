# Lost & Found - Campus Application

A modern, full-featured Flutter mobile application designed for Ontario Tech University students to report, track, and recover lost or found items across campus.

---

## Key Features

### Home Feed & Campus Search
* **Dynamic Grid Layout**: Toggle between 1-column list view, 2-column grid, and 3-column compact grid.
* **Instant Search**: Live keyword search across item titles and descriptions.
* **Campus Building Filters**: Filter items by campus locations (*Library, SIRC, Business Building, Science Building, Engineering Building, Recreation Centre, Sha Hall*).
* **Status Badges**: Clear visual badges indicating if an item was `FOUND`.

### Interactive Product Details & Fullscreen Media
* **Multi-Image Carousel Slider**: Swipe through multiple photos per item with active page indicator badges.
* **Pinch-to-Zoom Fullscreen Viewer**: Tap any photo to launch an interactive, full-screen viewer with `InteractiveViewer` pinch zoom and swipe controls.
* **Finder & Location Info**: View poster details, location tags, category subcategories, and full descriptions.

### Create Posts & Draft Management
* **Post Form Validation**: Input fields for Title, Description, Category/Subcategory, and Campus Location.
* **Multi-Photo Attachments**: Attach and preview images with deletion controls before publishing to Supabase Storage.
* **Offline Drafts**: Save draft posts locally using `shared_preferences`. Prevents empty drafts, auto-clears on save, and allows restoring saved drafts anytime.

### Dark Mode & Navigation Drawer
* **Global Dark Mode**: Dynamic dark/light mode toggle switch powered by `ValueNotifier<ThemeMode>`.
* **Campus Location Hub**: Dialog displaying Central Lost & Found box location.
* **Help & Guidelines**: FAQ dialog with step-by-step instructions on reporting and claiming items.
* **User Drawer Header**: Displays current account username and email address.

### Profile & Account Settings
* **User Profile**: View account details and list of user-created posts.
* **Username & Email Updates**: Edit and sync account username and email with Supabase authentication user metadata and database records.

### Messaging Inbox
* Work in progress

---

## 🛠️ Tech Stack & Dependencies

| Category | Technology |
| :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) (Dart) |
| **Backend & Database** | [Supabase](https://supabase.com) (`supabase_flutter`) |
| **Local Storage** | `shared_preferences` |
| **Media Handling** | `image_picker` |
| **UI Components** | Material 3 Design, Google Nav Bar (`google_nav_bar`) |

---

## 📂 Project Structure

```
lib/
├── main.dart                  # Application entry point, ThemeNotifier, AuthGate, & routes
├── model/                     # Data Models
│   ├── draft.dart             # RequestDraft model & DraftStorage manager
│   └── product.dart           # Product data model
├── pages/                     # Screens & Views
│   ├── create.dart            # Post creation form & draft actions
│   ├── draft.dart             # Saved drafts list screen
│   ├── home.dart              # Main feed, search, location filters, drawer, & details trigger
│   ├── inbox.dart             # Chat messages & notifications screen
│   ├── login.dart             # Supabase email authentication screen
│   ├── profile.dart           # User profile & user posts screen
│   ├── settings.dart          # Username & account settings screen
│   └── signup.dart           # User registration screen
└── widgets/                   # Reusable Widgets
    ├── draft_product_card.dart# Card layout for saved draft items
    ├── navbar.dart            # Floating bottom navigation bar (GNav)
    ├── product_card.dart      # Feed item card layout
    └── product_pop_up.dart    # Product details modal dialog & full-screen viewer
```

---

## 🚀 Getting Started

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.0.0`)
* Android Studio or VS Code with Flutter extension
* Android Emulator, iOS Simulator, or physical device

### Installation

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/your-username/Lost-and-Found.git
   cd Lost-and-Found
   ```

2. **Install Pub Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run Static Analysis:**
   ```bash
   flutter analyze
   ```

4. **Launch the Application:**
   ```bash
   flutter run
   ```

---

## 📝 License

Developed for Ontario Tech University - CSCI 3101U Project.
