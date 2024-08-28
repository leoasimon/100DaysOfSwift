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
        case player = 1
        case wall = 2
        case star = 4
        case vortex = 8
        case finish = 16
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
        
        player.physicsBody?.contactTestBitMask = CollisionType.star.rawValue
        player.physicsBody?.contactTestBitMask = CollisionType.vortex.rawValue
        player.physicsBody?.contactTestBitMask = CollisionType.finish.rawValue
        
        addChild(player)
    }
    
    func loadLevel() {
        guard let levelURL = Bundle.main.url(forResource: "level1", withExtension: "txt") else {
            fatalError("Could not find level1.txt in the app bundle")
        }
        
        guard let level = try? String(contentsOf: levelURL) else {
            fatalError("Could not load level1.txt from the app bundle")
        }
        
        let lines = level.components(separatedBy: "\n")
        
        for (row, line) in lines.reversed().enumerated() {
            for (col, c) in line.enumerated() {
                let position = CGPoint(x: col * 64 + 32, y: row * 64 + 32)
                switch c {
                case "x":
                    // load wall
                    let sprite = SKSpriteNode(imageNamed: "block")
                    sprite.position = position
                    sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
                    sprite.physicsBody?.categoryBitMask = CollisionType.wall.rawValue
                    sprite.physicsBody?.collisionBitMask = CollisionType.player.rawValue
                    sprite.physicsBody?.isDynamic = false
                    addChild(sprite)
                case "s":
                    // load star
                    let sprite = SKSpriteNode(imageNamed: "star")
                    sprite.name = "star"
                    sprite.position = position
                    sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
                    sprite.physicsBody?.categoryBitMask = CollisionType.star.rawValue
                    sprite.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
                    sprite.physicsBody?.isDynamic = false
                    addChild(sprite)
                case "v":
                    let sprite = SKSpriteNode(imageNamed: "vortex")
                    sprite.name = "vortex"
                    sprite.position = position
                    sprite.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
                    sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
                    sprite.physicsBody?.categoryBitMask = CollisionType.vortex.rawValue
                    sprite.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
                    sprite.physicsBody?.isDynamic = false
                    addChild(sprite)
                case "f":
                    let sprite = SKSpriteNode(imageNamed: "finish")
                    sprite.name = "vortex"
                    sprite.position = position
                    sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
                    sprite.physicsBody?.categoryBitMask = CollisionType.finish.rawValue
                    sprite.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
                    sprite.physicsBody?.isDynamic = false
                    addChild(sprite)
                default:
                    if c != " " {
                        fatalError("Unknown character in our level: \(c)")
                    }
                }
            }
        }
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
            isGameOver = true
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
