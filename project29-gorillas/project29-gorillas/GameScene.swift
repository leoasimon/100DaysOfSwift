//
//  GameScene.swift
//  project29-gorillas
//
//  Created by Leo on 2024-09-08.
//

import SpriteKit
import GameplayKit

enum CollisionType: UInt32 {
    case banana = 1
    case building = 2
    case player = 4
}

class GameScene: SKScene {
    
    var buildings = [BuildingNode]()
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    
    var currentPlayer = 1
    var banana: SKSpriteNode!
    
    var throwIndicator: SKSpriteNode!
    
    weak var viewController: GameViewController!
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
        physicsWorld.contactDelegate = self
        
        createBuildings()
        createPlayers()
        createThrowIndicator()
    }
    
    private func createBuildings() {
        var currentX = -15
        
        while currentX < 1024 {
            let height = Int.random(in: 300...600)
            let width = Int.random(in: 2...4) * 40
            
            let building = BuildingNode(color: .red, size: CGSize(width: width, height: height))
            building.position = CGPoint(x: currentX + width / 2, y: height / 2)
            building.setup()
            addChild(building)
            buildings.append(building)
            
            currentX += width + 2
        }
    }
    
    private func createPlayers() {
        //        Create a player sprite and name it "player1".
        player1 = SKSpriteNode(imageNamed: "player")
        player1.name = "player1"
        player2 = SKSpriteNode(imageNamed: "player")
        player2.name = "player2"
        
        //        Create a physics body for the player that collides with bananas, and set it to not be dynamic.
        player1.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width / 2)
        player1.physicsBody?.isDynamic = false
        player1.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        player1.physicsBody?.collisionBitMask = CollisionType.banana.rawValue
        player1.physicsBody?.contactTestBitMask = CollisionType.banana.rawValue
        
        player2.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width / 2)
        player2.physicsBody?.isDynamic = false
        player2.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        player2.physicsBody?.collisionBitMask = CollisionType.banana.rawValue
        player2.physicsBody?.contactTestBitMask = CollisionType.banana.rawValue
        
        //        Position the player at the top of the second building in the array. (This is why we needed to keep an array of the buildings.)
        let secondBuilding = buildings[1]
        let player1X = secondBuilding.position.x
        let player1Y = secondBuilding.size.height + player1.size.height / 2
        player1.position = CGPoint(x: player1X, y: player1Y)
        
        let secondLastBuilding = buildings[buildings.count - 2]
        let player2X = secondLastBuilding.position.x
        let player2Y = secondLastBuilding.size.height + player2.size.height / 2
        player2.position = CGPoint(x: player2X, y: player2Y)
        
        //        Add the player to the scene.
        addChild(player1)
        addChild(player2)
    }
    
    private func createThrowIndicator() {
        throwIndicator = SKSpriteNode(color: .red, size: CGSize(width: 64, height: 6))
        throwIndicator.anchorPoint = CGPoint(x: 0, y: throwIndicator.anchorPoint.y)
        
        
        if currentPlayer == 2 {
            throwIndicator.position = CGPoint(x: player2.position.x + 24, y: player2.position.y + 32)
            throwIndicator.zRotation = .pi * 3 / 4
        } else {
            throwIndicator.zRotation = .pi / 4
            throwIndicator.position = CGPoint(x: player1.position.x - 24, y: player1.position.y + 32)
        }
        
        addChild(throwIndicator)
    }
    
    func updateThrowIndicator(angle: Int, velocity: Int) {
        throwIndicator.size.width = CGFloat(velocity)
        
        if currentPlayer == 2 {
            throwIndicator.zRotation = CGFloat(180 - angle) * .pi / 180
        } else {
            throwIndicator.zRotation = CGFloat(angle) * .pi / 180
        }
    }
    
    
    func launch(angle: Int, velocity: Int) {
        throwIndicator.isHidden = true
        //        Figure out how hard to throw the banana. We accept a velocity parameter, but I'll be dividing that by 10. You can adjust this based on your own play testing.
        let speed = Double(velocity) / 10
        
        //        Convert the input angle to radians. Most people don't think in radians, so the input will come in as degrees that we will convert to radians.
        let radianAngle = Double(angle) * Double.pi / 180
        
        //        If somehow there's a banana already, we'll remove it then create a new one using circle physics.
        if banana != nil {
            banana.removeFromParent()
        }
        banana = SKSpriteNode(imageNamed: "banana")
        banana.name = "banana"
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
        banana.physicsBody?.categoryBitMask = CollisionType.banana.rawValue
        banana.physicsBody?.collisionBitMask = CollisionType.player.rawValue | CollisionType.building.rawValue
        banana.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        banana.physicsBody?.usesPreciseCollisionDetection = true
        addChild(banana)
        
        //        If player 1 was throwing the banana, we position it up and to the left of the player and give it some spin.
        if currentPlayer == 1 {
            banana.physicsBody?.angularVelocity = -20
            banana.position = CGPoint(x: player1.position.x - 24, y: player1.position.y + player1.size.width / 2 + 24)
        } else {
            banana.physicsBody?.angularVelocity = 20
            banana.position = CGPoint(x: player2.position.x - 24, y: player2.position.y + player2.size.width / 2 + 24)
        }
        
        //        Animate player throwing their arm up then putting it down again.
        let raiseArmTexture = SKTexture(imageNamed: "player\(currentPlayer)Throw")
        let raiseArm = SKAction.setTexture(raiseArmTexture)
        let pause = SKAction.wait(forDuration: 0.15)
        let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
        let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
        
        //        Make the banana move in the correct direction.
        let x = speed * cos(radianAngle)
        let y = speed * sin(radianAngle)
        
        if currentPlayer == 1 {
            player1.run(sequence)
            banana.physicsBody?.applyImpulse(CGVector(dx: x, dy: y))
        } else {
            player2.run(sequence)
            banana.physicsBody?.applyImpulse(CGVector(dx: -x, dy: y))
        }
    }
    
    func destroy(player: SKNode) {
        if let explosion = SKEmitterNode(fileNamed: "hitPlayer") {
            explosion.position = player.position
            addChild(explosion)
        }
        player.removeFromParent()
        banana.removeFromParent()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let newGame = GameScene(size: self.size)
            newGame.viewController = self.viewController
            self.viewController.currentGame = newGame
            
            self.changePlayer()
            newGame.currentPlayer = self.currentPlayer
            
            let transition = SKTransition.doorway(withDuration: 1.5)
            self.view?.presentScene(newGame, transition: transition)
        }
    }
    
    func bananaHit(building: SKNode, atPoint: CGPoint) {
        guard let building = building as? BuildingNode else { return }
        let buildingLocation = convert(atPoint, to: building)
        building.hit(at: buildingLocation)
        
        if let explosion = SKEmitterNode(fileNamed: "hitBuilding") {
            explosion.position = atPoint
            addChild(explosion)
        }

        banana.name = ""
        banana.removeFromParent()
        banana = nil
        
        changePlayer()
    }
    
    func changePlayer() {
        throwIndicator.isHidden = false
        if currentPlayer == 1 {
            throwIndicator.position = CGPoint(x: player2.position.x + 24, y: player2.position.y + 32)
            throwIndicator.zRotation = .pi - throwIndicator.zRotation
            currentPlayer = 2
        } else {
            throwIndicator.position = CGPoint(x: player1.position.x - 24, y: player1.position.y + 32)
            throwIndicator.zRotation = .pi - throwIndicator.zRotation
            currentPlayer = 1
        }
        
        viewController.activatePlayer(number: currentPlayer)
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard banana != nil else { return }

        if abs(banana.position.y) > 1000 {
            banana.removeFromParent()
            banana = nil
            changePlayer()
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        guard let firstNode = firstBody.node else { return }
        guard let secondNode = secondBody.node else { return }
        
        if firstNode.name == "banana" && secondNode.name == "player1" {
            destroy(player: player1)
        } else if firstNode.name == "banana" && secondNode.name == "player2" {
            destroy(player: player2)
        } else if firstNode.name == "banana" && secondNode.name == "building" {
            bananaHit(building: secondNode, atPoint: contact.contactPoint)
        }
    }
}
