# Space Invaders iOS Game

A modern, feature-rich implementation of the classic Space Invaders arcade game built with Swift 5 and SpriteKit. This project demonstrates advanced iOS game development techniques, clean architecture, and professional coding practices.

## 🎮 Game Overview

Space Invaders is a vertically-scrolling shooter game where players control a spaceship to defend against waves of alien invaders. The game features progressive difficulty, power-up systems, and modern visual effects while maintaining the nostalgic feel of the original arcade classic.

## ✨ Key Features

### Core Gameplay
- **Smooth Touch Controls**: Intuitive tap-to-shoot and slide-to-move mechanics
- **Wave-Based Progression**: Increasingly challenging enemy waves with dynamic spawning
- **Power-Up System**: Three distinct power-ups (Speed Boost, Multi-Shot, Shield) with visual indicators
- **Special Abilities**: Unlockable "Nuke" ability for clearing multiple enemies
- **Lives System**: Three lives with visual heart indicators
- **Score Tracking**: Persistent high score system with wave completion bonuses

### Technical Features
- **Physics-Based Collision Detection**: Precise hit detection using SpriteKit physics
- **Object Pooling**: Optimized bullet and enemy management for performance
- **State Management**: Clean game state handling with proper lifecycle management
- **Responsive Design**: Adaptive UI for different iPhone screen sizes
- **Visual Effects**: Particle systems, animations, and modern UI elements

## 🏗️ Architecture & Design Patterns

### Project Structure
```
space-invaders/
├── GameScene.swift          # Main game logic and physics
├── MainMenuScene.swift      # Menu system and navigation
├── GameViewController.swift # Scene management and lifecycle
├── SharedResources.swift    # Colors, extensions, and utilities
└── Assets.xcassets/         # Game assets and sprites
```

### Design Patterns Implemented
- **MVC Architecture**: Clear separation of concerns
- **Protocol-Oriented Programming**: Extensible and testable code
- **Singleton Pattern**: Shared resources and game state
- **Observer Pattern**: Event-driven game mechanics
- **Factory Pattern**: Object creation and management

### Key Technical Implementations

#### Physics System
```swift
// Custom physics categories for collision detection
struct PhysicsCategory {
    static let none: UInt32 = 0
    static let ship: UInt32 = 0b1
    static let enemy: UInt32 = 0b10
    static let bullet: UInt32 = 0b100
    static let powerUp: UInt32 = 0b1000
}
```

#### Object Pooling
```swift
// Efficient bullet management
private func getBulletFromPool() -> SKSpriteNode {
    if let bullet = bulletPool.children.first {
        bullet.removeFromParent()
        return bullet as! SKSpriteNode
    }
    return createBullet()
}
```

#### State Management
```swift
// Clean game state handling
private enum GameState {
    case menu
    case playing
    case paused
    case gameOver
}
```

## 🛠️ Technical Stack

- **Language**: Swift 5.0+
- **Framework**: SpriteKit (Apple's 2D game framework)
- **Physics Engine**: Built-in SpriteKit physics
- **UI Framework**: UIKit integration with SpriteKit
- **Development Environment**: Xcode 13.0+
- **Target Platform**: iOS 14.0+

## 📱 User Interface

### Visual Design
- **Color Scheme**: Custom space-themed palette with hex color management
- **Typography**: Avenir Next font family for modern readability
- **Animations**: Smooth transitions and particle effects
- **Responsive Layout**: Adaptive positioning for different screen sizes

### UI Components
- **Main Menu**: Animated background with floating stars
- **HUD Elements**: Score display, lives indicator, wave counter
- **Power-Up Indicators**: Visual feedback for active abilities
- **Game Over Screen**: Final score and restart options

## 🎯 Game Mechanics

### Combat System
- **Weapon Types**: Single-shot and multi-shot modes
- **Enemy AI**: Progressive difficulty with varied movement patterns
- **Collision Detection**: Precise hit boxes and damage calculation
- **Power-Up Effects**: Temporary ability enhancements

### Progression System
- **Wave Management**: Dynamic enemy spawning and difficulty scaling
- **Score Multipliers**: Bonus points for wave completion
- **Achievement System**: Unlockable abilities and milestones

## 🧪 Testing

The project includes comprehensive testing infrastructure:

- **Unit Tests**: Core game logic and utility functions
- **UI Tests**: User interface and interaction testing
- **Performance Tests**: Frame rate and memory usage validation

## 🚀 Installation & Setup

### Prerequisites
- macOS with Xcode 13.0 or later
- iOS 14.0+ device or simulator
- Swift 5.0+ knowledge

### Getting Started
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/space-invaders-ios-game.git
   cd space-invaders-ios-game
   ```

2. Open the project in Xcode:
   ```bash
   open space-invaders.xcodeproj
   ```

3. Select your target device or simulator

4. Build and run the project (⌘+R)

### Build Configuration
- **Deployment Target**: iOS 14.0+
- **Swift Version**: 5.0
- **Architecture**: ARM64 (iOS devices), x86_64 (simulator)
- **Optimization**: Release builds optimized for performance

## 📊 Performance Considerations

### Optimization Techniques
- **Object Pooling**: Reuses game objects to reduce memory allocation
- **Texture Atlasing**: Efficient sprite management
- **Physics Optimization**: Selective collision detection
- **Memory Management**: Proper cleanup and resource disposal

### Target Performance
- **Frame Rate**: Consistent 60 FPS on supported devices
- **Memory Usage**: < 100MB peak memory consumption
- **Battery Efficiency**: Optimized for extended gameplay sessions

## 🔧 Development Practices

### Code Quality
- **Swift Style Guide**: Follows Apple's Swift API Design Guidelines
- **Documentation**: Comprehensive inline comments and documentation
- **Error Handling**: Robust error management and edge case handling
- **Code Organization**: Clear separation of concerns and modular design

### Version Control
- **Git Workflow**: Feature branch development with clean commit history
- **Code Review**: Peer review process for quality assurance
- **Continuous Integration**: Automated testing and build validation

## 🎨 Asset Management

### Graphics
- **Sprite Sheets**: Optimized texture atlases for performance
- **Vector Graphics**: Scalable UI elements
- **Animation Frames**: Smooth sprite animations

### Audio
- **Sound Effects**: Immersive gameplay audio
- **Background Music**: Atmospheric space-themed soundtrack

## 📈 Future Enhancements

### Planned Features
- **Multiplayer Support**: Local and online multiplayer modes
- **Achievement System**: Extended progression and rewards
- **Customization**: Ship skins and visual themes
- **Leaderboards**: Global and local score tracking

### Technical Improvements
- **Metal Integration**: Enhanced graphics performance
- **ARKit Integration**: Augmented reality gameplay modes
- **Cloud Save**: Cross-device progress synchronization

## 👨‍💻 Developer Information

**Matheus Abrahão**  
- GitHub: [@abrahao-dev](https://github.com/abrahao-dev)  
- LinkedIn: [linkedin.com/in/matheusabrahao](https://www.linkedin.com/in/matheusabrahao)  
- Portfolio: [matheusabrahao.com.br](https://www.matheusabrahao.com.br)  

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## 🙏 Acknowledgments

- Inspired by the classic Space Invaders arcade game
- Built with Apple's SpriteKit framework
- Special thanks to the iOS development community

---

*This project demonstrates advanced Swift development skills, clean architecture principles, and professional game development practices suitable for iOS development roles.*
