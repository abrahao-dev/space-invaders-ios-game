//
//  GameScene.swift
//  space-invaders
//
//  Created by Matheus Abrahão on 31/01/25.
//

import SpriteKit
import GameplayKit

// MARK: - GameScene
final class GameScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - Constants
    private enum Constants {
        static let shipSize = CGSize(width: 60, height: 80)
        static let bulletSize = CGSize(width: 4, height: 16)
        static let enemySize = CGSize(width: 40, height: 40)
        static let shootingInterval: TimeInterval = 0.5
        static let powerUpDuration: TimeInterval = 5.0
        static let enemySpawnIntervalBase: TimeInterval = 2.0
        static let enemySpawnIntervalMin: TimeInterval = 0.5
    }

    // MARK: - Properties
    private var spaceship: SKSpriteNode!
    private var touchLocation: CGPoint?
    private var lastUpdateTime: TimeInterval = 0
    private var deltaTime: TimeInterval = 0

    // Game state
    private var score = 0 {
        didSet {
            // Remove the automatic score label update here
        }
    }
    private var lives = 3
    private var isGameOver = false
    private var isPoweredUp = false
    private var canShoot = true

    // UI elements
    private var scoreLabel: SKLabelNode?
    private var heartNodes: [SKSpriteNode] = []
    private var waveCounterLabel: SKLabelNode?
    private var nukeButton: SKSpriteNode?

    // Add wave tracking
    private var currentWave = 1
    private var enemiesDestroyedInWave = 0
    private var enemiesPerWave = 10

    // Add to Properties section
    private enum PowerUpType: CaseIterable {
        case speedBoost
        case multiShot
        case shield

        var color: UIColor {
            switch self {
            case .speedBoost: return .yellow
            case .multiShot: return .cyan
            case .shield: return .green
            }
        }
    }

    // Add these properties
    private var currentPowerUp: PowerUpType?
    private var shieldNode: SKShapeNode?

    // Add to Properties section
    private var nukeAvailable = false

    // Add missing properties
    var isReadyToStart: Bool = false
    private lazy var gameLayer = SKNode()
    private lazy var uiLayer = SKNode()
    var bulletPool: SKNode = {
        let node = SKNode()
        node.name = "bulletPool"
        return node
    }()
    var enemyFrames: [SKTexture] = []

    // MARK: - Lifecycle
    override func sceneDidLoad() {
        super.sceneDidLoad()

        // Add layers only once
        addChild(gameLayer)
        addChild(uiLayer)

        // Basic setup
        backgroundColor = Colors.background
        setupPhysics()
    }

    override func didMove(to view: SKView) {
        // Remove duplicate setup calls
        resetGameState()
        setupGame()
    }

    private func setupGame() {
        // Remove duplicate layer setup since it's done in sceneDidLoad
        setupSpaceship()  // Setup spaceship first
        setupUI()         // Then UI elements
        setupLives()      // Then lives display
        startEnemySpawning()
    }

    private func resetGameState() {
        // Remove any existing nodes first
        gameLayer.removeAllChildren()
        uiLayer.removeAllChildren()

        // Reset game variables
        score = 0
        lives = 3
        isGameOver = false
        currentWave = 1
        enemiesDestroyedInWave = 0
        enemiesPerWave = 10
        nukeAvailable = false
        currentPowerUp = nil
        isPoweredUp = false
        canShoot = true

        heartNodes.removeAll()
    }

    // MARK: - Setup
    private func setupUI() {
        // Remove old score setup and create a single, clean implementation
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel?.fontSize = 24
        scoreLabel?.fontColor = Colors.scoreColor
        scoreLabel?.horizontalAlignmentMode = .left
        scoreLabel?.position = CGPoint(x: 20, y: frame.height - 40)
        scoreLabel?.zPosition = 100
        scoreLabel?.text = "SCORE: 0"

        if let scoreLabel = scoreLabel {
            uiLayer.addChild(scoreLabel)
        }

        // Wave counter setup
        waveCounterLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        waveCounterLabel?.fontSize = 16
        waveCounterLabel?.fontColor = Colors.powerUp
        waveCounterLabel?.position = CGPoint(x: frame.midX, y: frame.height - 30)
        waveCounterLabel?.zPosition = 100
        waveCounterLabel?.text = "WAVE 1"

        if let waveLabel = waveCounterLabel {
            uiLayer.addChild(waveLabel)
        }

        setupNukeButton()
        setupLives()
    }

    private func setupSpaceship() {
        // Create spaceship
        spaceship = SKSpriteNode(imageNamed: "spaceship")
        spaceship.size = Constants.shipSize
        spaceship.position = CGPoint(x: frame.midX, y: 100)
        spaceship.zPosition = 10

        // Setup physics
        spaceship.physicsBody = SKPhysicsBody(rectangleOf: spaceship.size)
        spaceship.physicsBody?.isDynamic = true
        spaceship.physicsBody?.affectedByGravity = false
        spaceship.physicsBody?.allowsRotation = false
        spaceship.physicsBody?.categoryBitMask = PhysicsCategory.player
        spaceship.physicsBody?.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.powerUp
        spaceship.physicsBody?.collisionBitMask = PhysicsCategory.none

        // Add to game layer
        gameLayer.addChild(spaceship)

        // Add engine glow effect
        addEngineGlow()
    }

    private func addEngineGlow() {
        let glow = SKEffectNode()
        glow.shouldRasterize = true
        glow.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 2.0])

        let engineGlow = SKShapeNode(rectOf: CGSize(width: 8, height: 12))
        engineGlow.fillColor = Colors.powerUp
        engineGlow.strokeColor = .clear
        engineGlow.position = CGPoint(x: 0, y: -spaceship.size.height/2)

        glow.addChild(engineGlow)
        spaceship.addChild(glow)

        // Add engine pulse animation
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.2),
            SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        ])
        engineGlow.run(SKAction.repeatForever(pulse))
    }

    // MARK: - Game Logic
    private func shoot() {
        guard canShoot && !isGameOver else { return }

        // Create bullet
        let bullet = SKSpriteNode(color: Colors.bulletColor, size: Constants.bulletSize)
        bullet.position = CGPoint(x: spaceship.position.x, y: spaceship.position.y + spaceship.size.height/2)
        bullet.zPosition = 5

        createBulletPhysics(for: bullet)
        gameLayer.addChild(bullet)

        // Move bullet
        bullet.run(SKAction.sequence([
            SKAction.moveBy(x: 0, y: frame.height, duration: 1.0),
            SKAction.removeFromParent()
        ]))

        // Visual feedback instead of sound
        playLaserEffect()

        // Reset shooting cooldown
        canShoot = false
        run(SKAction.wait(forDuration: Constants.shootingInterval)) { [weak self] in
            self?.canShoot = true
        }
    }

    private func createEnemy() -> SKSpriteNode {
        let enemy = SKSpriteNode(color: Colors.shipAccent, size: Constants.enemySize)
        enemy.name = "enemy"

        let glow = SKEffectNode()
        glow.shouldRasterize = true
        glow.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 2.0])
        let glowSprite = SKSpriteNode(color: Colors.shipAccent, size: CGSize(
            width: Constants.enemySize.width + 4,
            height: Constants.enemySize.height + 4
        ))
        glowSprite.alpha = 0.3
        glow.addChild(glowSprite)
        enemy.addChild(glow)

        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        enemy.run(.repeatForever(pulse))

        return enemy
    }

    // MARK: - Enemy Spawning
    private func startEnemySpawning() {
        let spawnAction = SKAction.sequence([
            SKAction.wait(forDuration: Constants.enemySpawnIntervalBase),
            SKAction.run { [weak self] in
                self?.spawnEnemy()
            }
        ])

        run(.repeatForever(spawnAction), withKey: "spawning")
    }

    private func spawnEnemy() {
        guard !isGameOver else { return }

        let enemy = SKSpriteNode(color: Colors.shipAccent, size: Constants.enemySize)
        enemy.name = "enemy"

        // Random position at top of screen
        let xPos = CGFloat.random(in: enemy.size.width...frame.width-enemy.size.width)
        enemy.position = CGPoint(x: xPos, y: frame.height + enemy.size.height)

        // Physics setup
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.isDynamic = true
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.bullet | PhysicsCategory.player
        enemy.physicsBody?.collisionBitMask = PhysicsCategory.none

        gameLayer.addChild(enemy)

        // Movement
        let moveDown = SKAction.moveTo(y: -enemy.size.height, duration: Constants.enemySpawnIntervalBase)
        let checkBottom = SKAction.run { [weak self] in
            // Only trigger if the enemy wasn't destroyed
            if enemy.parent != nil {
                self?.enemyReachedBottom()
            }
        }
        let remove = SKAction.removeFromParent()

        enemy.run(SKAction.sequence([moveDown, checkBottom, remove]))
    }

    // MARK: - Power-ups
    private func activatePowerUp(type: PowerUpType) {
        deactivatePowerUp()

        currentPowerUp = type
        isPoweredUp = true

        switch type {
        case .speedBoost:
            spaceship.run(.scale(to: 1.2, duration: 0.3))
            spaceship.run(.colorize(with: .yellow, colorBlendFactor: 0.5, duration: 0.3))

        case .multiShot:
            spaceship.run(.colorize(with: .cyan, colorBlendFactor: 0.5, duration: 0.3))

        case .shield:
            let shield = SKShapeNode(circleOfRadius: Constants.shipSize.width * 0.7)
            shield.strokeColor = .green
            shield.glowWidth = 2.0
            shield.alpha = 0.6
            spaceship.addChild(shield)
            shieldNode = shield
        }

        run(.sequence([
            .wait(forDuration: Constants.powerUpDuration),
            .run { [weak self] in self?.deactivatePowerUp() }
        ]))
    }

    private func deactivatePowerUp() {
        isPoweredUp = false
        currentPowerUp = nil

        spaceship.run(.scale(to: 1.0, duration: 0.3))
        spaceship.run(.colorize(withColorBlendFactor: 0.0, duration: 0.3))
        shieldNode?.removeFromParent()
        shieldNode = nil
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if isGameOver {
            // Check if tap is on the restart text
            let restartRect = CGRect(x: frame.width/2 - 100, y: frame.height/2 - 120, width: 200, height: 40)
            if restartRect.contains(location) {
                restart()
            }
            return
        }

        // Handle nuke button
        if let nukeButton = nukeButton,
           nukeButton.contains(location) && nukeAvailable {
            activateNuke()
            return
        }

        // Normal game touch handling
        touchLocation = location
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLocation = touches.first?.location(in: self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLocation = nil
    }

    override func update(_ currentTime: TimeInterval) {
        guard let touchLocation = touchLocation else { return }

        let newX = min(max(touchLocation.x, spaceship.size.width/2), frame.width - spaceship.size.width/2)
        let newY = min(max(touchLocation.y, spaceship.size.height/2), frame.height * 0.8)

        let moveAction = SKAction.move(to: CGPoint(x: newX, y: newY), duration: 0.1)
        spaceship.run(moveAction)

        enumerateChildNodes(withName: "powerUp") { powerUp, _ in
            if powerUp.frame.intersects(self.spaceship.frame) {
                if let powerUpType = powerUp.userData?["type"] as? PowerUpType {
                    self.activatePowerUp(type: powerUpType)
                }
                powerUp.removeFromParent()
            }
        }

        shoot()
    }

    // MARK: - Nuke Button
    private func setupNukeButton() {
        let buttonSize: CGFloat = 40
        nukeButton = SKSpriteNode(color: Colors.powerUp, size: CGSize(width: buttonSize, height: buttonSize))
        nukeButton?.position = CGPoint(x: frame.width - 30, y: 100)
        nukeButton?.zPosition = 90 // Lower than UI elements but above game elements
        nukeButton?.alpha = 0.5
        nukeButton?.name = "nukeButton"

        if let button = nukeButton {
            uiLayer.addChild(button)
        }
    }

    private func activateNuke() {
        guard nukeAvailable else { return }

        // Visual feedback
        let flash = SKSpriteNode(color: .white, size: frame.size)
        flash.position = CGPoint(x: frame.midX, y: frame.midY)
        flash.zPosition = 999
        flash.alpha = 0
        uiLayer.addChild(flash)

        // Flash animation
        flash.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.8, duration: 0.1),
            SKAction.fadeAlpha(to: 0, duration: 0.2),
            SKAction.removeFromParent()
        ]))

        // Remove all enemies with explosion effects
        enumerateChildNodes(withName: "enemy") { [weak self] node, _ in
            guard let self = self else { return }

            // Create explosion effect
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = node.position
                explosion.zPosition = 500
                explosion.particleLifetime = 0.5
                self.gameLayer.addChild(explosion)

                // Remove explosion after animation
                explosion.run(SKAction.sequence([
                    SKAction.wait(forDuration: 0.5),
                    SKAction.removeFromParent()
                ]))
            }

            // Remove enemy
            node.removeFromParent()

            // Increment score
            self.score += 5
            self.enemiesDestroyedInWave += 1
        }

        // Reset nuke state
        nukeAvailable = false
        nukeButton?.alpha = 0.5

        // Play sound effect
        run(SKAction.playSoundFileNamed("explosion", waitForCompletion: false))

        // Check wave progress
        checkWaveProgress()
    }

    private func updateScore(_ newScore: Int) {
        score = newScore
        scoreLabel?.text = "SCORE: \(score)"

        // Animate score change
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        scoreLabel?.run(SKAction.sequence([scaleUp, scaleDown]))
    }

    private func restart() {
        // Remove all game over nodes
        removeAllChildren()

        // Create new scene properly
        let newScene = GameScene(size: size)
        newScene.scaleMode = scaleMode

        // Ensure proper transition
        view?.presentScene(newScene, transition: SKTransition.fade(withDuration: 0.3))
    }

    private func gameOver() {
        isGameOver = true
        removeAllActions()

        // Remove all enemies
        enumerateChildNodes(withName: "enemy") { node, _ in
            node.removeAllActions()
            node.removeFromParent()
        }

        let gameOverNode = SKNode()
        gameOverNode.zPosition = 1000

        let gameOverLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.fontSize = 40
        gameOverLabel.fontColor = Colors.scoreColor
        gameOverLabel.position = CGPoint(x: frame.width/2, y: frame.height/2)

        let finalScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        finalScoreLabel.text = "Final Score: \(score)"
        finalScoreLabel.fontSize = 30
        finalScoreLabel.fontColor = Colors.scoreColor
        finalScoreLabel.position = CGPoint(x: frame.width/2, y: frame.height/2 - 50)

        let tapLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        tapLabel.text = "Tap to Restart"
        tapLabel.fontSize = 25
        tapLabel.fontColor = Colors.highlight
        tapLabel.position = CGPoint(x: frame.width/2, y: frame.height/2 - 100)

        [gameOverLabel, finalScoreLabel, tapLabel].forEach { label in
            label.alpha = 0
            gameOverNode.addChild(label)
        }

        addChild(gameOverNode)

        // Animate labels
        let fadeIn = SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeIn(withDuration: 0.3)
        ])

        gameOverNode.children.forEach { node in
            node.run(fadeIn)
        }
    }

    // Add this method to handle collisions
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        // Handle player-enemy collision
        if collision == PhysicsCategory.player | PhysicsCategory.enemy {
            if let enemy = (contact.bodyA.categoryBitMask == PhysicsCategory.enemy ? contact.bodyA.node : contact.bodyB.node) {
                enemy.removeFromParent()
                handlePlayerCollision()
            }
        }

        // Handle bullet-enemy collision
        if collision == PhysicsCategory.bullet | PhysicsCategory.enemy {
            let bullet = contact.bodyA.categoryBitMask == PhysicsCategory.bullet ? contact.bodyA.node : contact.bodyB.node
            let enemy = contact.bodyA.categoryBitMask == PhysicsCategory.enemy ? contact.bodyA.node : contact.bodyB.node
            handleBulletEnemyCollision(bullet: bullet, enemy: enemy)
        }

        // Handle player-powerup collision
        if collision == PhysicsCategory.player | PhysicsCategory.powerUp {
            let powerUp = contact.bodyA.categoryBitMask == PhysicsCategory.powerUp ? contact.bodyA.node : contact.bodyB.node
            handlePowerUpCollection(powerUp: powerUp)
        }
    }

    // Replace sound effects with visual feedback
    private func playExplosionEffect(at position: CGPoint) {
        let explosion = SKEmitterNode()
        explosion.particleTexture = SKTexture(imageNamed: "spaceship") // Using existing spaceship texture
        explosion.particleBirthRate = 100
        explosion.numParticlesToEmit = 20
        explosion.particleLifetime = 0.5
        explosion.particleSpeed = 50
        explosion.particleSpeedRange = 20
        explosion.particleAlpha = 0.8
        explosion.particleAlphaSpeed = -1.0
        explosion.particleScale = 0.2
        explosion.particleScaleRange = 0.1
        explosion.position = position
        explosion.zPosition = 50

        addChild(explosion)

        explosion.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.removeFromParent()
        ]))
    }

    // Replace laser sound with visual effect
    private func playLaserEffect() {
        let flash = SKSpriteNode(color: Colors.bulletColor, size: CGSize(width: 4, height: 16))
        flash.position = spaceship.position
        flash.zPosition = 5
        flash.alpha = 0.8

        addChild(flash)

        flash.run(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 20, duration: 0.1),
            SKAction.removeFromParent()
        ]))
    }

    // MARK: - Collision Handling
    func handlePlayerCollision() {
        if !isGameOver && !isPoweredUp {
            lives -= 1
            updateLivesDisplay()

            // Visual feedback for player hit
            let flash = SKSpriteNode(color: .red, size: spaceship.size)
            flash.position = spaceship.position
            flash.zPosition = spaceship.zPosition + 1
            addChild(flash)

            flash.run(SKAction.sequence([
                SKAction.fadeAlpha(to: 0.5, duration: 0.1),
                SKAction.fadeOut(withDuration: 0.1),
                SKAction.removeFromParent()
            ]))

            // Add invulnerability period
            isPoweredUp = true
            spaceship.alpha = 0.5

            run(SKAction.sequence([
                SKAction.wait(forDuration: 2.0),
                SKAction.run { [weak self] in
                    self?.isPoweredUp = false
                    self?.spaceship.alpha = 1.0
                }
            ]))
        }
    }

    func handleBulletEnemyCollision(bullet: SKNode?, enemy: SKNode?) {
        // Remove bullet and enemy
        bullet?.removeFromParent()
        enemy?.removeFromParent()

        // Update score
        score += 10
        scoreLabel?.text = "SCORE: \(score)"

        // Play explosion effect
        if let enemyPosition = enemy?.position {
            playExplosionEffect(at: enemyPosition)
        }

        // Check wave progress
        checkWaveProgress()

        // Chance to spawn power-up
        if Int.random(in: 1...100) <= 10 { // 10% chance
            if let position = enemy?.position {
                spawnPowerUp(at: position)
            }
        }
    }

    func handlePowerUpCollection(powerUp: SKNode?) {
        powerUp?.removeFromParent()

        // Apply power-up effect
        isPoweredUp = true
        spaceship.run(SKAction.colorize(with: Colors.powerUp, colorBlendFactor: 0.5, duration: 0.3))

        // Show power-up text
        let powerUpLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        powerUpLabel.text = "POWER UP!"
        powerUpLabel.fontSize = 20
        powerUpLabel.fontColor = Colors.powerUp
        powerUpLabel.position = CGPoint(x: frame.midX, y: frame.height - 100)
        powerUpLabel.alpha = 0
        addChild(powerUpLabel)

        powerUpLabel.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.2),
            SKAction.wait(forDuration: 1.0),
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))

        // Reset power-up after duration
        run(SKAction.sequence([
            SKAction.wait(forDuration: Constants.powerUpDuration),
            SKAction.run { [weak self] in
                self?.isPoweredUp = false
                self?.spaceship.run(SKAction.colorize(withColorBlendFactor: 0, duration: 0.3))
            }
        ]))
    }

    private func spawnPowerUp(at position: CGPoint) {
        let powerUp = SKShapeNode(circleOfRadius: 10)
        powerUp.fillColor = Colors.powerUp
        powerUp.strokeColor = Colors.highlight
        powerUp.glowWidth = 2
        powerUp.position = position
        powerUp.zPosition = 5

        // Add physics
        powerUp.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        powerUp.physicsBody?.isDynamic = true
        powerUp.physicsBody?.affectedByGravity = false
        powerUp.physicsBody?.categoryBitMask = PhysicsCategory.powerUp
        powerUp.physicsBody?.contactTestBitMask = PhysicsCategory.player
        powerUp.physicsBody?.collisionBitMask = PhysicsCategory.none

        // Add to scene
        gameLayer.addChild(powerUp)

        // Animate
        let moveDown = SKAction.moveBy(x: 0, y: -frame.height, duration: 4.0)
        powerUp.run(SKAction.sequence([
            moveDown,
            SKAction.removeFromParent()
        ]))
    }
}

// MARK: - Factory Methods
private extension GameScene {
    // Remove or comment out the createShipSprite function since we're using an image asset now
    // private func createShipSprite(pointing direction: ShipDirection, color: UIColor) -> SKSpriteNode {
    //     // ... old triangle drawing code ...
    // }
}

// MARK: - Lives Management
private extension GameScene {
    func setupLives() {
        // Clear existing hearts
        heartNodes.forEach { $0.removeFromParent() }
        heartNodes.removeAll()

        // Create new hearts
        for i in 0..<lives {
            let heart = SKSpriteNode(imageNamed: "spaceship")
            heart.size = CGSize(width: 20, height: 20)
            heart.position = CGPoint(
                x: frame.width - 30 - CGFloat(i * 25),
                y: frame.height - 30
            )
            heart.zPosition = 1000
            heart.alpha = 0.8
            heartNodes.append(heart)
            uiLayer.addChild(heart)
        }
    }

    func updateLivesDisplay() {
        while heartNodes.count > lives {
            if let heart = heartNodes.popLast() {
                heart.run(SKAction.sequence([
                    .fadeOut(withDuration: 0.2),
                    .removeFromParent()
                ]))
            }
        }

        if lives <= 0 {
            gameOver()
        }
    }
}

// MARK: - Enemy Management
private extension GameScene {
    func enemyReachedBottom() {
        if !isGameOver {
            lives -= 1
            updateLivesDisplay()

            // Visual feedback
            let flash = SKSpriteNode(color: .red, size: CGSize(width: frame.width, height: 2))
            flash.position = CGPoint(x: frame.midX, y: 0)
            flash.alpha = 0
            flash.zPosition = 999 // Ensure it's visible above other elements
            gameLayer.addChild(flash)

            flash.run(SKAction.sequence([
                .fadeAlpha(to: 1, duration: 0.1),
                .wait(forDuration: 0.1),
                .fadeAlpha(to: 0, duration: 0.1),
                .removeFromParent()
            ]))

            // Screen shake
            let shake = SKAction.sequence([
                .moveBy(x: 0, y: -5, duration: 0.05),
                .moveBy(x: 0, y: 5, duration: 0.05)
            ])
            gameLayer.run(.repeat(shake, count: 2))

            // Play sound
            run(SKAction.playSoundFileNamed("explosion", waitForCompletion: false))
        }
    }

    func updateEnemySpawnInterval(to interval: TimeInterval) {
        // Remove existing spawn action
        removeAction(forKey: "spawning")

        // Create new spawn action with updated interval
        let spawnAction = SKAction.sequence([
            SKAction.wait(forDuration: interval),
            SKAction.run { [weak self] in
                self?.spawnEnemy()
            }
        ])

        run(.repeatForever(spawnAction), withKey: "spawning")
    }
}

// MARK: - Game State Management
private extension GameScene {
    func checkWaveProgress() {
        enemiesDestroyedInWave += 1

        if currentWave > 1 && enemiesDestroyedInWave == enemiesPerWave / 2 {
            nukeAvailable = true
            nukeButton?.alpha = 1.0

            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.2),
                SKAction.scale(to: 1.0, duration: 0.2)
            ])
            nukeButton?.run(pulse)
        }

        if enemiesDestroyedInWave >= enemiesPerWave {
            startNewWave()
        }
    }

    private func startNewWave() {
        currentWave += 1
        enemiesDestroyedInWave = 0
        enemiesPerWave = min(10 + (currentWave * 2), 30)

        // Calculate new interval but store it for use
        let newInterval = max(
            Constants.enemySpawnIntervalMin,
            Constants.enemySpawnIntervalBase - (Double(currentWave - 1) * 0.1)
        )

        // Use the new interval
        updateEnemySpawnInterval(to: newInterval)

        displayWaveTransition()
    }

    private func displayWaveTransition() {
        // Make wave transition more exciting
        let waveLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        waveLabel.text = "WAVE \(currentWave)"
        waveLabel.fontSize = 40
        waveLabel.fontColor = Colors.scoreColor
        waveLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        waveLabel.alpha = 0
        addChild(waveLabel)

        // Add bonus score for completing wave
        let waveBonus = currentWave * 100
        updateScore(score + waveBonus)

        let bonusLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        bonusLabel.text = "+\(waveBonus) WAVE BONUS!"
        bonusLabel.fontSize = 25
        bonusLabel.fontColor = Colors.powerUp
        bonusLabel.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        bonusLabel.alpha = 0
        addChild(bonusLabel)

        // Animate wave transition
        let fadeInOut = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.wait(forDuration: 1.0),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ])

        waveLabel.run(fadeInOut)
        bonusLabel.run(fadeInOut)

        // Update wave counter
        waveCounterLabel?.text = "WAVE \(currentWave)"
    }
}

// MARK: - Helper Methods
private extension GameScene {
    private enum ShipDirection {
        case up, down
    }
}

// MARK: - Performance Optimizations
private extension GameScene {
    func optimizeNodeCreation() {
        // Preload textures using proper method
        let gameTexturesAtlas = SKTextureAtlas(named: "GameTextures")
        gameTexturesAtlas.preload { [weak self] in
            self?.isReadyToStart = true
        }

        // Setup bullet pool
        gameLayer.addChild(bulletPool)

        // Load enemy textures
        let enemyAtlas = SKTextureAtlas(named: "Enemies")
        enemyFrames = enemyAtlas.textureNames.compactMap { enemyAtlas.textureNamed($0) }
    }

    func cleanupResources() {
        // Remove unused nodes
        gameLayer.children.forEach { node in
            if !frame.intersects(node.frame) {
                node.removeFromParent()
            }
        }

        // Clear texture memory properly
        let texturesToPreload: [SKTexture] = enemyFrames
        SKTexture.preload(texturesToPreload) { }
    }
}

// MARK: - Scene Setup
extension GameScene {
    private func setupLayers() {
        addChild(gameLayer)
        addChild(uiLayer)
    }

    private func setupPhysics() {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        // Create boundaries
        let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.categoryBitMask = PhysicsCategory.none
        physicsBody?.collisionBitMask = PhysicsCategory.none
    }

    func createBulletPhysics(for bullet: SKSpriteNode) {
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.categoryBitMask = PhysicsCategory.bullet
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        bullet.physicsBody?.collisionBitMask = PhysicsCategory.none
    }
}

// MARK: - Physics Categories
private struct PhysicsCategory {
    static let none: UInt32    = 0
    static let player: UInt32  = 0b1      // 1
    static let enemy: UInt32   = 0b10     // 2
    static let bullet: UInt32  = 0b100    // 4
    static let powerUp: UInt32 = 0b1000   // 8
    static let all: UInt32     = UInt32.max
}
