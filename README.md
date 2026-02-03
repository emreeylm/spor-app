# MuscleWiki Exercise & Planner App

A high-performance iOS app built with SwiftUI and SwiftData for exploring exercises and planning your workout and diet.

## Features

- **Keşfet (Explore)**: Browse exercises by muscle group using a grid view or an **interactive Body Map**.
- **Interactive Anatomy**: Toggle between front and back views to select muscles visually.
- **Video Streaming**: Watch exercise demonstration videos directly in the app.
- **Programım (My Program)**: A 7-day workout planner to track your sets, reps, and weights.
- **Diyet (Diet)**: A 7-day meal planner grouped by meal type (Breakfast, Lunch, etc.).
- **Local Persistence**: All your plans are saved locally on your device using SwiftData.

## Tech Stack

- **SwiftUI**: Modern declarative UI.
- **SwiftData**: Native local persistence.
- **URLSession**: Clean networking without external dependencies.
- **AVKit**: High-quality video streaming.

### 1. Explore (Keşfet)
- **Muscle Selection**: Choose between a standard grid view or a **MuscleWiki-style interactive Body Map**.
- **Interactive Anatomy**: Front and back views of the human body with selectable muscle regions.
- **Exercise List**: Paginated list of exercises with thumbnails and target muscle information.

## Setup Instructions

1. **Clone the repository.**
2. **Open `spor-app.xcodeproj` in Xcode 15+.**
3. **Configure API Key**:
    - Open `spor-app/Utils/Config.swift`.
    - Replace `PUT_YOUR_KEY_HERE` with your [RapidAPI Key](https://rapidapi.com/musclewiki/api/musclewiki/).
4. **Target Version**: Ensure your target device or simulator is running iOS 17.0 or later.
5. **Run**: Select a simulator and press `Cmd + R`.

## Implementation Details

- **MVVM Architecture**: Separates business logic from UI.
- **Rich Aesthetics**: Custom components like `DayPickerView` and `MuscleCard` for a premium feel.
- **Local-First**: The app works offline for Program and Diet tabs (Explore requires internet).

## Notes

- The app uses `MuscleWiki API`. If the API schema changes, update `ExerciseDTO.swift`.
- SwiftData models are automatically migrated for minor changes.
