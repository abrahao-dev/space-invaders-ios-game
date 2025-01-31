import SpriteKit

final class MainMenuScene: SKScene {
    override func didMove(to view: SKView) {
        setupBackground()
        setupTitle()
        setupButtons()
    }

    private func setupBackground() {
        backgroundColor = Colors.background

        // Add animated stars
        for _ in 0...50 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...3))
            star.fillColor = Colors.highlight
            star.strokeColor = .clear
            star.position = CGPoint(
                x: CGFloat.random(in: 0...frame.width),
                y: CGFloat.random(in: 0...frame.height)
            )
            star.alpha = CGFloat.random(in: 0.3...0.7)

            let duration = TimeInterval.random(in: 1.0...3.0)
            star.run(.repeatForever(.sequence([
                .fadeAlpha(to: 0.2, duration: duration),
                .fadeAlpha(to: 0.7, duration: duration)
            ])))

            addChild(star)
        }
    }

    private func setupTitle() {
        // Main title with gradient
        let titleNode = SKNode()
        titleNode.position = CGPoint(x: frame.midX, y: frame.midY + 100)

        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "SPACE"
        titleLabel.fontSize = 45
        titleLabel.fontColor = Colors.highlight

        let subtitleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        subtitleLabel.text = "INVADERS"
        subtitleLabel.fontSize = 40
        subtitleLabel.fontColor = Colors.powerUp
        subtitleLabel.position = CGPoint(x: 0, y: -45)

        // Add developer credit
        let devLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        devLabel.text = "Developed by Abrahão Dev"
        devLabel.fontSize = 16
        devLabel.fontColor = Colors.shipAccent
        devLabel.position = CGPoint(x: frame.midX, y: frame.height * 0.1)

        titleNode.addChild(titleLabel)
        titleNode.addChild(subtitleLabel)
        addChild(titleNode)
        addChild(devLabel)

        // Floating animation for title
        let float = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 10, duration: 1.5),
            SKAction.moveBy(x: 0, y: -10, duration: 1.5)
        ])
        titleNode.run(.repeatForever(float))
    }

    private func setupButtons() {
        let startButton = createMenuButton(text: "START GAME", position: CGPoint(x: frame.midX, y: frame.midY - 20))
        let highScoreButton = createMenuButton(text: "HIGH SCORES", position: CGPoint(x: frame.midX, y: frame.midY - 100))

        addChild(startButton)
        addChild(highScoreButton)
    }

    private func createMenuButton(text: String, position: CGPoint) -> SKNode {
        let buttonWidth: CGFloat = 220
        let buttonHeight: CGFloat = 60

        // Create container node
        let container = SKNode()
        container.position = position

        // Create button background with gradient
        let button = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 30)
        button.fillColor = Colors.shipBase
        button.strokeColor = Colors.powerUp
        button.lineWidth = 2
        button.name = text.lowercased().replacingOccurrences(of: " ", with: "_")

        // Add glow effect
        let glow = SKEffectNode()
        glow.shouldRasterize = true
        glow.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 3.0])
        let glowShape = SKShapeNode(rectOf: CGSize(width: buttonWidth + 4, height: buttonHeight + 4), cornerRadius: 30)
        glowShape.fillColor = Colors.powerUp
        glowShape.strokeColor = .clear
        glowShape.alpha = 0.3
        glow.addChild(glowShape)

        // Create label
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 25
        label.fontColor = Colors.highlight
        label.verticalAlignmentMode = .center

        // Add hover animation
        let hover = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 1.0),
            SKAction.scale(to: 1.0, duration: 1.0)
        ])
        button.run(.repeatForever(hover))

        // Assemble button
        container.addChild(glow)
        container.addChild(button)
        button.addChild(label)

        return container
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = nodes(at: location).first

        if touchedNode?.name == "start_game" {
            // Disable button to prevent multiple taps
            touchedNode?.isUserInteractionEnabled = false

            // Start loading immediately
            showLoadingTransition()
        } else if touchedNode?.name == "high_scores" {
            // Handle high scores button (can be implemented later)
            print("High Scores tapped")
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        enumerateChildNodes(withName: "//*") { node, _ in
            if let button = node as? SKShapeNode,
               button.name?.contains("_") == true {
                if button.contains(location) {
                    button.fillColor = Colors.powerUp
                } else {
                    button.fillColor = Colors.shipBase
                }
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Reset button colors
        enumerateChildNodes(withName: "//*") { node, _ in
            if let button = node as? SKShapeNode,
               button.name?.contains("_") == true {
                button.fillColor = Colors.shipBase
            }
        }
    }

    private func showLoadingTransition() {
        // Pre-load game assets
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = .aspectFill

        // Show loading screen with shorter duration
        let progressDuration: TimeInterval = 0.8 // Reduced from 1.2

        // Create overlay
        let overlay = SKSpriteNode(color: .black, size: size)
        overlay.position = CGPoint(x: frame.midX, y: frame.midY)
        overlay.alpha = 0
        overlay.zPosition = 100
        addChild(overlay)

        // Create container for loading elements
        let container = SKNode()
        container.position = CGPoint(x: frame.midX, y: frame.midY)
        container.zPosition = 101

        // Create loading text
        let loadingLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        loadingLabel.text = "LOADING"
        loadingLabel.fontSize = 30
        loadingLabel.fontColor = Colors.highlight
        loadingLabel.position = CGPoint(x: 0, y: 30) // Adjusted position
        loadingLabel.alpha = 0

        // Create progress bar background - Centered
        let barWidth: CGFloat = 200
        let barHeight: CGFloat = 8
        let barBackground = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 4)
        barBackground.fillColor = Colors.darkAccent
        barBackground.strokeColor = Colors.shipAccent
        barBackground.lineWidth = 1
        barBackground.position = CGPoint(x: 0, y: 0) // Centered
        barBackground.alpha = 0

        // Create progress bar fill - Aligned with background
        let progressBar = SKShapeNode(rectOf: CGSize(width: 0, height: barHeight - 2), cornerRadius: 3)
        progressBar.fillColor = Colors.powerUp
        progressBar.strokeColor = .clear
        progressBar.position = CGPoint(x: 0, y: 0) // Centered
        progressBar.alpha = 0

        // Create percentage label
        let percentLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        percentLabel.fontSize = 20
        percentLabel.fontColor = Colors.highlight
        percentLabel.position = CGPoint(x: 0, y: -30) // Adjusted position
        percentLabel.alpha = 0

        // Add all elements to container
        container.addChild(loadingLabel)
        container.addChild(barBackground)
        container.addChild(progressBar)
        container.addChild(percentLabel)
        addChild(container)

        // Animate overlay
        overlay.run(.fadeIn(withDuration: 0.3))

        // Fade in elements
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        loadingLabel.run(fadeIn)
        barBackground.run(fadeIn)
        progressBar.run(fadeIn)
        percentLabel.run(fadeIn)

        // Animate progress bar - removed unused variables
        let updateProgress = SKAction.customAction(withDuration: progressDuration) { node, elapsedTime in
            let progress = elapsedTime / CGFloat(progressDuration)
            let width = barWidth * progress
            progressBar.path = CGPath(roundedRect: CGRect(x: -barWidth/2, y: -barHeight/2 + 1, width: width, height: barHeight - 2),
                                    cornerWidth: 3, cornerHeight: 3, transform: nil)
            percentLabel.text = "\(Int(progress * 100))%"

            // Add glow effect as progress increases
            progressBar.alpha = 0.8 + (progress * 0.2)
            let glowWidth = CGFloat(2 + (progress * 3))
            progressBar.glowWidth = glowWidth
        }

        progressBar.run(updateProgress)

        // Transition to game scene
        run(SKAction.sequence([
            .wait(forDuration: progressDuration),
            .run { [weak self] in
                guard let self = self else { return }
                self.view?.presentScene(gameScene, transition: SKTransition.fade(withDuration: 0.3))
            }
        ]))
    }
}
