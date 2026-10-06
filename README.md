# Digital Pet State Lab

## CSC 4360 - Mobile App Development
**Student:** Eyobed Gebregziabher  
**Activity:** In-Class Activity 07 - Digital Pet State Lab  
**Platform:** Flutter / Dart

## Project Overview

This project is a digital pet application built with Flutter. The main goal of the activity was to practice managing local state with StatefulWidget and setState(), working with timers, updating the UI from changing state, and safely handling Flutter widget lifecycle methods.

The pet has happiness and hunger values that range from 0 to 100. The user can name the pet, feed it, play with it, pause the session, resume the session, and reset the game.

## Core Features

- Editable pet name
- Happiness meter from 0-100
- Hunger meter from 0-100
- Happy, Neutral, and Unhappy mood states
- Pet color changes based on happiness
- Feed action
- Play action
- Automatic hunger increase every 30 seconds
- Win condition
- Game-over condition
- Reset functionality
- Care controls disabled after the game ends
- Timer cleanup using dispose()

## Pet Mood System

The pet's mood is determined by its happiness level:

- Happiness above 70: Happy / Green
- Happiness from 30-70: Neutral / Yellow
- Happiness below 30: Unhappy / Red

The pet image uses ColorFiltered with BlendMode.modulate so the same pet image can represent different moods without needing separate images.

## Game Rules

### Feed

Feeding reduces hunger by 10.

After feeding:

- If hunger becomes less than 30, happiness decreases by 20.
- Otherwise, happiness increases by 10.

All meter values are clamped between 0 and 100.

### Play

Playing with the pet:

- Increases happiness by 10
- Increases hunger by 5

### Hunger Timer

Hunger automatically increases by 5 every 30 seconds.

If hunger is already near the maximum, it is clamped at 100. Later hunger overflow can also decrease happiness.

### Win Condition

The player wins when happiness remains above 80 continuously for 3 minutes.

If happiness falls to 80 or below, the win timer is canceled.

### Loss Condition

The game ends when:

- Hunger reaches 100
- Happiness is 10 or lower

After winning or losing, the care controls are disabled until the user resets the pet.

## Undergraduate Pathway

I completed the undergraduate pathway with two advanced features.

### Advanced Feature 1 - Session Controls

I added Pause and Resume controls.

When the game is paused:

- The hunger timer stops.
- The win timer stops.
- Feed and Play are disabled.
- Pet name editing is disabled.

When the game resumes, the timers and controls become active again.

### Advanced Feature 2 - Visual Polish

I added visual feedback to make state changes easier to see.

The visual effects include:

1. AnimatedScale on the pet when its state changes.
2. Smoothly animated happiness and hunger progress indicators.

The animations also respect the device's reduced-motion accessibility setting using MediaQuery.disableAnimations.

## State Management

The application uses a StatefulWidget to store and update the pet's state.

Important state includes:

- Pet name
- Happiness
- Hunger
- Game-over state
- Win state
- Pause state
- Hunger timer
- Win timer

setState() is used whenever a state change needs to update the interface.

## Timer and Lifecycle Management

The hunger timer is started when the pet screen is initialized.

Timers are canceled when necessary during:

- Pause
- Reset
- Win
- Loss
- dispose()

The TextEditingController used for the pet name is also disposed when the widget is removed.

## Testing

The application was manually tested during development.

| Test | Result |
| --- | --- |
| Application launches correctly | PASS |
| Initial happiness and hunger are 50 | PASS |
| Pet name can be changed | PASS |
| Feed updates hunger and happiness | PASS |
| Play updates hunger and happiness | PASS |
| Mood label changes correctly | PASS |
| Pet tint changes with mood | PASS |
| Hunger increases automatically | PASS |
| 30-second hunger timer works | PASS |
| Win condition works | PASS |
| Happiness of exactly 80 does not qualify for win | PASS - verified by program logic |
| Loss condition works | PASS |
| Care controls disable after outcome | PASS |
| Reset restores the pet | PASS |
| Pause stops the session | PASS |
| Resume restarts the session | PASS |
| Pet animation works | PASS |
| Progress meter animations work | PASS |

For faster testing, temporary shorter timer values were used when testing the win and loss conditions. The required 30-second hunger timer and 3-minute win timer were restored before the final version.

## Feature-to-Outcome Map

| Feature | Outcome |
| --- | --- |
| StatefulWidget and setState() | Manages changing pet state |
| Feed and Play | Demonstrates event-driven state changes |
| Hunger timer | Demonstrates timer-driven state |
| Win/loss logic | Demonstrates state-dependent outcomes |
| ColorFiltered pet | Gives visual mood feedback |
| Pause/Resume | Adds session control |
| AnimatedScale | Adds visual state feedback |
| Animated progress indicators | Makes meter changes easier to see |
| Reduced-motion support | Improves accessibility |
| dispose() cleanup | Safely manages timers and controllers |

## Setup

Clone the repository:

git clone https://github.com/eyobedmerhawi/inclass07.git

Move into the project:

cd inclass07

Install Flutter dependencies:

flutter pub get

Run the application:

flutter run

## Release Build

To build the Android release APK:

flutter build apk --release

The generated APK can be found at:

build/app/outputs/flutter-apk/app-release.apk

## Asset

The digital pet uses a sugar glider PNG stored at:

assets/pet.png

The pet image has a transparent background so ColorFiltered can apply the mood tint.

## Collaboration

This activity was completed individually rather than as a two-team project. Because I worked independently, there were no cross-team pull requests or peer reviews to document.

## Repository

https://github.com/eyobedmerhawi/inclass07