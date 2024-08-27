//
//  GameScene.swift
//  project26-ball-rolling-game
//
//  Created by Leo on 2024-08-27.
//

import SpriteKit

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
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        loadLevel()
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
                    sprite.position = position
                    sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
                    sprite.physicsBody?.categoryBitMask = CollisionType.star.rawValue
                    sprite.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
                    sprite.physicsBody?.isDynamic = false
                    addChild(sprite)
                case "v":
                    // load vortex
                    let sprite = SKSpriteNode(imageNamed: "vortex")
                    sprite.position = position
                    sprite.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
                    sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
                    sprite.physicsBody?.categoryBitMask = CollisionType.vortex.rawValue
                    sprite.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
                    sprite.physicsBody?.isDynamic = false
                    addChild(sprite)
                case "f":
                    // load finish
                    let sprite = SKSpriteNode(imageNamed: "finish")
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
}
