//
//  GameScene.swift
//  project20-fireworks-game
//
//  Created by Leo on 2024-08-06.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var gameTimer: Timer?
    var fireworks = [SKNode]()
    var remainingLaunches = 1 {
        didSet {
            if remainingLaunches == 0 {
                remainingLaunchesLabel.text = "Remaining launches: \(remainingLaunches)"
            }
        }
    }
    
    let scoreLabel = SKLabelNode()
    let remainingLaunchesLabel = SKLabelNode()
    var gameOverScreen: SKSpriteNode?
    
    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        let bg = SKSpriteNode(imageNamed: "background")
        bg.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        bg.blendMode = .replace
        bg.zPosition = -1
        
        addChild(bg)
        
        scoreLabel.text = "Score: \(score)"
        scoreLabel.position = CGPoint(x: size.width - 128, y: size.height - 128)
        addChild(scoreLabel)
        
        remainingLaunchesLabel.text = "Remaining launches: \(remainingLaunches)"
        remainingLaunchesLabel.position = CGPoint(x: 160, y: 64)
        addChild(remainingLaunchesLabel)
        
        createGameOverScreen()
//        endGame()
        
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    }
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        checkTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        checkTouches(touches)
    }
    
    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 900 {
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    
    func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtPoint {
            guard node.name == "firework" else { return }
            
            for parent in fireworks {
                guard let firework = parent.children.first as? SKSpriteNode else { return }
                
                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
                
            }
            node.name = "selected"
            node.colorBlendFactor = 0
        }
    }
    
    @objc func launchFireworks() {
        guard remainingLaunches > 0 else { return endGame() }
        
        let movementAmount: CGFloat = 1800
        
        switch Int.random(in: 0...3) {
        case 0:
            // fire five, straight up
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 200, y: bottomEdge)
            
        case 1:
            // fire five, in a fan
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge)
            
        case 2:
            // fire five, from the left to the right
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)
            
        case 3:
            // fire five, from the right to the left
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)
            
        default:
            break
        }
        
        remainingLaunches -= 1
    }
    
    func createFirework(xMovement: CGFloat, x: Int, y: Int) {
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1
        firework.name = "firework"
        node.addChild(firework)
        
        switch Int.random(in: 0...2) {
        case 0:
            firework.color = .cyan
        case 1:
            firework.color = .green
        case 2:
            firework.color = .red
        default:
            break
        }
        
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        node.run(move)
        
        if let emitter = SKEmitterNode(fileNamed: "fuse") {
            emitter.position = CGPoint(x: 0, y: -22)
            node.addChild(emitter)
        }
        
        fireworks.append(node)
        addChild(node)
    }
    
    func explodeFireworks() {
        var numExploded = 0
        
        for (index, firework) in fireworks.enumerated().reversed() {
            guard let node = firework.children.first as? SKSpriteNode else { return }
            
            if node.name == "selected" {
                explode(firework: node)
                fireworks.remove(at: index)
                numExploded += 1
            }
        }
        
        switch numExploded {
        case 0:
            // nothing – rubbish!
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
        }
    }
    
    func explode(firework: SKNode) {
        if let explosion = SKEmitterNode(fileNamed: "explode") {
            explosion.position = firework.position
            addChild(explosion)
        }
        
        firework.removeFromParent()
    }
    
    func createGameOverScreen() {
        gameOverScreen = SKSpriteNode(color: .white, size: CGSize(width: 420, height: 420))
        
        guard let gameOverScreen = gameOverScreen else {
            return
        }

        gameOverScreen.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        let gameOverLabel = SKLabelNode()
        gameOverLabel.text = "Game over!"
        gameOverLabel.fontSize = 32
        gameOverLabel.fontColor = .black
        gameOverLabel.position = CGPoint(x: 0, y: 128)
        gameOverScreen.addChild(gameOverLabel)
        
        let btnPadding = 64.0
        
        let restartLabel = SKLabelNode()
        restartLabel.text = "Start a new game"
        restartLabel.fontColor = .white
        restartLabel.position = CGPoint(x: 0, y: -(restartLabel.frame.height / 2))
        
        let restartBtn = SKSpriteNode(color: .blue, size: CGSize(width: restartLabel.frame.width + btnPadding, height: restartLabel.frame.height + btnPadding))
        restartBtn.position = CGPoint(x: 0, y: 0)

        restartBtn.addChild(restartLabel)
        gameOverScreen.addChild(restartBtn)
        
    }
    
    func endGame() {
        print("Game over!")
        gameTimer?.invalidate()
        
        guard let gameOverScreen = gameOverScreen else {
            return
        }
        
        addChild(gameOverScreen)
    }
}
