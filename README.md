# Password Manager App

A secure, easy-to-use password manager app built with Flutter that allows you to store and manage your passwords by categories such as Social Media, E-commerce, Banking, and more. Passwords are securely encrypted and can be searched quickly using an integrated search functionality.

---

## Features

- **Category-wise password management:** Store passwords under categories like Social Media, Banking, E-commerce, etc.
- **Secure encryption:** Passwords are encrypted using AES-256 encryption with the `encrypt` package.
- **Local storage with Isar:** Fast and efficient local NoSQL database storage.
- **State management with Bloc:** Clean architecture using Bloc pattern for handling business logic.
- **Search functionality:** Easily search saved passwords by account name or username.
- **Add, edit, delete passwords:** Full CRUD support with an intuitive UI.
- **Password visibility toggle and copy:** Show/hide passwords and copy to clipboard securely.
- **Smooth UI:** Responsive and user-friendly interface with Google Fonts styling.


## Getting Started

### Prerequisites

- Flutter SDK (version XX or higher)
- Dart SDK
- Compatible IDE (VSCode, Android Studio, etc.)

### Installation

1. Clone the repo:

   ```bash
   git clone https://github.com/yourusername/password_manager_app.git
   cd password_manager_app

2. **Install dependencies:**
    - flutter pub get

3. **Run the app:**
   - flutter run


## UI Overview

### Home Screen:
- Displays a list of all stored passwords, with options to add, edit, delete, and search.

### Edit Password Screen:
- Add or edit password entries with fields for account name, username, password (encrypted), category selection, and optional notes.
- Includes password visibility toggle and clipboard copy feature.

---

## How to Use

### Home Screen
- View all saved passwords sorted by creation date.
- Tap a password to edit.
- Long press a password to delete with confirmation dialog.
- Use the search icon to open search interface and find passwords quickly.
- Use the floating action button (+) to add a new password.

### Edit Password Screen
- Fill in account name, username, and password fields.
- Choose a category for better organization.
- Add any notes related to the password.
- Save to store or update the password securely.

---

## Dependencies

- **Flutter**
- **flutter_bloc:** State management
- **Isar:** Local NoSQL database
- **encrypt:** AES encryption
- **flutter_secure_storage:** Secure key storage
- **google_fonts:** Custom fonts

