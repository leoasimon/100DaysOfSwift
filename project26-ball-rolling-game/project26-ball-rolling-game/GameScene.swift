//
//  GameScene.swift
//  project26-ball-rolling-game
//
//  Created by Leo on 2024-08-27.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene {
    
    enum CollisionType: UInt32 {
        case player = 0b00000001
        case wall = 0b00000010
        case star = 0b00000100
        case vortex = 0b00001000
        case finish = 0b00010000
        case teleporter = 0b00100000
    }
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    private var player: SKSpriteNode!
    
    private var lastTouchPosition: CGPoint?
    
    private let motionManager = CMMotionManager()
    
    private var scoreLabel: SKLabelNode!
    private var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    private var isGameOver = false
    
    private var currenLevel = 4
    private var nLevels = 4
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.zPosition = 1
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.position = CGPoint(x: 16, y: size.height - 16)
        addChild(scoreLabel)
        
        loadLevel()
        createPlayer()
        
        motionManager.startAccelerometerUpdates()
        
        physicsWorld.contactDelegate = self
    }
    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        
        player.position = CGPoint(x: 96, y: 672)
        player.zPosition = 1
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5
        
        player.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        
        player.physicsBody?.collisionBitMask = CollisionType.wall.rawValue
        
        player.physicsBody?.contactTestBitMask = CollisionType.star.rawValue | CollisionType.vortex.rawValue | CollisionType.finish.rawValue
        
        addChild(player)
    }
    
    func loadLevel() {
        let levelName = "level\(currenLevel)"
        guard let levelURL = Bundle.main.url(forResource: levelName, withExtension: "txt") else {
            fatalError("Could not find \(levelName).txt in the app bundle")
        }
        
        guard let level = try? String(contentsOf: levelURL) else {
            fatalError("Could not load \(levelName).txt from the app bundle")
        }
        
        let lines = level.components(separatedBy: "\n")
        
        for (row, line) in lines.reversed().enumerated() {
            for (col, c) in line.enumerated() {
                let position = CGPoint(x: col * 64 + 32, y: row * 64 + 32)
                switch c {
                case "x":
                    instanciateWall(at: position)
                case "s":
                    instanciateStar(at: position)
                case "v":
                    instanciateVortex(at: position)
                case "f":
                    instanciateFinish(at: position)
                case "t":
                    instanciateTeleporter(at: position)
                default:
                    if c != " " {
                        fatalError("Unknown character in our level: \(c)")
                    }
                }
            }
        }
    }
    
    private func clearLevel() {
        for col in 0..<12 {
            for row in 0..<16 {
                for node in nodes(at: CGPoint(x: col * 64 + 32, y: row * 64 + 32)) {
                    if node.name != nil {
                        node.removeFromParent()
                    }
                }
            }
        }
    }
    private func instanciateTeleporter(at position: CGPoint) {
        let sprite = SKSpriteNode(color: .green, size: CGSize(width: 42, height: 42))
        sprite.name = "teleporter"
        sprite.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
        let scaleDown = SKAction.scale(to: 0.2, duration: 1)
        let scaleUp = SKAction.scale(to: 1, duration: 1)
        let sequence = SKAction.sequence([scaleDown, scaleUp])
        sprite.run(SKAction.repeatForever(sequence))
        
        sprite.position = position
        
        sprite.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        sprite.physicsBody?.isDynamic = false
        sprite.physicsBody?.categoryBitMask = CollisionType.teleporter.rawValue
        sprite.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        
        addChild(sprite)
    }
    
    private func instanciateWall(at position: CGPoint) {
        let sprite = SKSpriteNode(imageNamed: "block")
        sprite.position = position
        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        sprite.physicsBody?.categoryBitMask = CollisionType.wall.rawValue
        sprite.physicsBody?.collisionBitMask = CollisionType.player.rawValue
        sprite.physicsBody?.isDynamic = false
        addChild(sprite)
    }
    
    private func instanciateStar(at position: CGPoint) {
        let sprite = SKSpriteNode(imageNamed: "star")
        sprite.name = "star"
        sprite.position = position
        sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        sprite.physicsBody?.categoryBitMask = CollisionType.star.rawValue
        sprite.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        sprite.physicsBody?.isDynamic = false
        addChild(sprite)
    }
    
    private func instanciateVortex(at position: CGPoint) {
        let sprite = SKSpriteNode(imageNamed: "vortex")
        sprite.name = "vortex"
        sprite.position = position
        sprite.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
        sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        sprite.physicsBody?.categoryBitMask = CollisionType.vortex.rawValue
        sprite.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        sprite.physicsBody?.isDynamic = false
        addChild(sprite)
    }
    
    private func instanciateFinish(at position: CGPoint) {
        let sprite = SKSpriteNode(imageNamed: "finish")
        sprite.name = "finish"
        sprite.position = position
        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        sprite.physicsBody?.categoryBitMask = CollisionType.finish.rawValue
        sprite.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        sprite.physicsBody?.isDynamic = false
        addChild(sprite)
    }
    
    func playerCollided(with node: SKNode) {
        if node.name == "star" {
            node.removeFromParent()
            score += 1
        } else if node.name == "vortex" {
            player.physicsBody?.isDynamic = false
            score -= 1
            isGameOver = true
            
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])
            
            player.run(sequence) { [weak self] in
                self?.createPlayer()
                self?.isGameOver = false
            }
        } else if node.name == "finish" {
            currenLevel += 1
            guard currenLevel <= nLevels else {
                // show final gameOver screen
                isGameOver = true
                return
            }
            player.removeFromParent()
            clearLevel()
            loadLevel()
            createPlayer()
        } else if node.name == "teleporter" {
            player.physicsBody?.isDynamic = false
            
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])
            
            player.run(sequence)
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        guard let touch = touches.first else { return }
        
        lastTouchPosition = touch.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with: UIEvent?) {
        guard let touch = touches.first else { return }
        
        lastTouchPosition = touch.location(in: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with: UIEvent?) {
        lastTouchPosition = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isGameOver == false else { return }
#if targetEnvironment(simulator)
        guard let lastTouchPosition = lastTouchPosition else {
            return
        }
        
        let diff = CGPoint(x: lastTouchPosition.x - player.position.x, y: lastTouchPosition.y - player.position.y)
        physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
        
#else
        guard let accelerometerData = motionManager.accelerometerData else { return }
        
        physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
#endif
    }
}


extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA == player {
            playerCollided(with: nodeB)
        } else if nodeB == player {
            playerCollided(with: nodeA)
        }
    }
}
