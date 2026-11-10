# Lost & Found - Campus Application

A modern, full-featured Flutter mobile application designed for Ontario Tech University students to report, track, and recover lost items across campus.

---

## Key Features

### Home Feed & Campus Search
* **Dynamic Grid Layout**: Toggle between 1-column list view, 2-column grid, and 3-column compact grid.
* **Instant Search**: Live keyword search across item titles and descriptions.
* **Campus Building Filters**: Filter items by campus locations (*Library, SIRC, Business Building, Science Building, Engineering Building, Recreation Centre, Shaw Hall*).
* **Status Badge**: Clear visual badge that indicates if your item was `FOUND`.

### Interactive Product Details & Fullscreen Media
* **Multi-Image Carousel Slider**: Swipe through multiple photos per item with active page indicator badges.
* **Pinch-to-Zoom Fullscreen Viewer**: Tap any photo to launch an interactive, full-screen viewer with `InteractiveViewer`, pinch to zoom and swipe controls.
* **Finder & Location Info**: View post details, location tags, category, subcategories, and full descriptions.

### Create Posts & Draft Management
* **Post Form Validation**: Input fields for Title, Description, Category/Subcategory, and Campus Location.
* **Multi-Photo Attachments**: Attach and preview images with deletion controls before publishing to Supabase Storage.
* **Offline Drafts**: Save draft posts locally using `shared_preferences`. Prevents empty drafts, auto-clears on save, and allows restoring saved drafts anytime.

### Dark Mode & Navigation Drawer
* **Global Dark Mode**: Dynamic dark/light mode toggle switch powered by `ValueNotifier<ThemeMode>`.
* **Campus Location Hub**: Dialog displaying Lost & Found box location.
* **Help & Guidelines**: FAQ dialog with step-by-step instructions on reporting and claiming items.
* **User Drawer Header**: Displays current account username and email address.

### Profile & Account Settings
* **User Profile**: View account details and list of user-created posts.
* **Username & Email Updates**: Edit and sync account username and email with Supabase authentication.

### Messaging Inbox
* Work in progress

---

## Demo Video
* This video demonstrates the functionaliy of the application:\
https://drive.google.com/file/d/1fZr0q_8q_f4CLWg6b5nbmO11DTElz_pG/view?usp=sharing



## Tech Stack & Dependencies

| Category | Technology |
| :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) (Dart) |
| **Backend & Database** | [Supabase](https://supabase.com) (`supabase_flutter`) |
| **Local Storage** | `shared_preferences` |
| **Media Handling** | `image_picker` |
| **UI Components** | Material 3 Design, Google Nav Bar (`google_nav_bar`) |

---

## Project Structure

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

## Getting Started

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.0.0`)
* Android Studio or VS Code with Flutter extension
* Android Emulator or physical Android device

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

## Login information
* **Email**: `test@gmail.com`
* **Password**: `123456`
* **Guest**: `Continue as guest` to use the app as a guest user
* **New User**: Create a new account


## Generative AI Usage and Acknowledgement

| AI Tool Used | Prompt(s) Used | Purpose/How It Was Used |
| :--- | :--- | :--- |
| **Gemini** | “How do I implement the use of shared_preferences for local storage draft saving and keeping a user logged in after a re-run of the program?” | Assisted in implementing `shared_preferences` to store post drafts in local storage and maintain active user sessions across app restarts. |
| **Gemini** | “How do I handle Supabase authentication (sign in, sign up) and sync updated user metadata (username/email) with database tables in Flutter?” | Generated starter code and error-handling patterns for Supabase Auth in `login.dart`, `signup.dart`, and profile data synchronization in `settings.dart`. |
| **Gemini** | “How to implement dynamic grid column toggling (1, 2, 3 columns) and filters for campus location search in Flutter?” | Assisted in generating the `RequestDraft` model (`toJson`/`fromJson`) and static `DraftStorage` helper methods (`load`, `save`, `delete`) in `draft.dart` for local draft management. |
| **ChatGPT** | “What are some good UI features/settings that we can implement in our project to enhance user experience?” | Provided feature recommendations implemented in the project, including dark mode, product cards, keyword search functionality, and a homepage navigation drawer. |
| **ChatGPT** | “How to handle row level security for a table within supabase? What are the recommended policies for each table" | Guided the design of Supabase Row Level Security (RLS) policies. Established public read access for guest browsing, enforced creator-only permissions (`auth.uid() = user_id`) for post mutations, and secured user profile modifications. |
