## College Football Spread Game

A Flutter application for managing and playing a college football spread prediction game. This app allows users to make picks for football games, view the leaderboard, and provides an admin interface for managing games and user picks.

## Features

- **User Page:**  
  - Enter your username and make picks for the weekly football games.
  - Submit your picks and view your current selections.

- **Leaderboard:**  
  - See all users’ correct picks.
  - View win probabilities for each user (Monte Carlo simulation).
  - Search for users on the leaderboard.

- **Admin Page:**  
  - Password-protected access ("football2024" by default).
  - Add, update, and delete games.
  - Set game winners.
  - Clear all games or picks.
  - Search and manage users (clear picks, delete users).

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- [Hive](https://docs.hivedb.dev/) (used for local data storage)

### Installation

1. **Clone the repository:**
    ```sh
    git clone https://github.com/jeling43/football_app.git
    cd football_app
    ```

2. **Install dependencies:**
    ```sh
    flutter pub get
    ```

3. **Run the app:**
    - For mobile:
        ```sh
        flutter run
        ```
    - For web:
        ```sh
        flutter run -d chrome
        ```

### Usage

- **User Page:**  
  Make your picks for the games and submit.

- **Leaderboard:**  
  See leader stats and win probabilities.

- **Admin Page:**  
  Enter the password (`football2024` by default) to access admin controls.

## Hosting

For free/static hosting, use [GitHub Pages](https://pages.github.com/) for the web build:

1. Build for web:
    ```sh
    flutter build web
    ```
2. Push the contents of `build/web` to your repo’s `gh-pages` branch.
3. Enable GitHub Pages in your repository settings.

Alternatively, use [Firebase Hosting](https://firebase.google.com/products/hosting), [Netlify](https://www.netlify.com/), or [Vercel](https://vercel.com/) for free hosting of static sites.

## Folder Structure

- `lib/`
  - `main.dart` - App entry point and routing.
  - `pages/` - UI pages: `user_page.dart`, `admin_page.dart`, `leaderboard_page.dart`, etc.
  - `models/` - Data models: `game.dart`, `leaderboard_entry.dart`.
  - `providers/` - State management: `game_provider.dart`, `leaderboard_provider.dart`.
- `web/` - Web build and config files.

## Customization

- **Admin Password:**  
  Change the `adminPassword` value in `lib/pages/admin_page.dart` to update the admin access password.

## License

This project is open source. See [LICENSE](LICENSE) for details.

## Credits

Developed by [jeling43](https://github.com/jeling43).
