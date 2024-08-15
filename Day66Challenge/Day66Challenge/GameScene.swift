//
//  GameScene.swift
//  Day66Challenge
//
//  Created by Leo on 2024-07-30.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var spawnTimer: Timer?
    var targets = [SKNode]()
    
    override func didMove(to view: SKView) {
        let firstSeparator = SKSpriteNode(color: .red, size: CGSize(width: size.width, height: 3))
        let secondSeparator = SKSpriteNode(color: .red, size: CGSize(width: size.width, height: 3))
        
        firstSeparator.position = CGPoint(x: size.width / 2, y: size.height * 0.33)
        secondSeparator.position = CGPoint(x: size.width / 2, y: size.height * 0.66)
        
        addChild(firstSeparator)
        addChild(secondSeparator)
        
        spawnTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(spawnRandomTarget), userInfo: nil, repeats: true)
    }
    
    func getSpeed(for targetSize: String) -> Int {
        let dict = ["sm": 400, "md": 270, "lg": 150]
        
        return dict[targetSize]!
    }
    
    @objc func spawnRandomTarget() {
        let targetSize = ["sm", "md", "lg"].randomElement()!
        let speed = getSpeed(for: targetSize)
        let row = [1,2,3].randomElement()!
        
        let rowHeight = size.height / 3
        
        let direction = row == 2 ? -1 : 1
        
        let targetNode = SKSpriteNode(imageNamed: "target-good")
        let widths = ["sm": 32, "md": 64, "lg": 128]
        let w = widths[targetSize]!
        targetNode.scale(to: CGSize(width: w, height: w))
        
        let y = rowHeight * CGFloat(row) - rowHeight / 2
        let x = row == 2 ? size.width + 72 : -72
        targetNode.position = CGPoint(x: x, y: y)
        
        targetNode.physicsBody = SKPhysicsBody()
        targetNode.physicsBody?.velocity = CGVector(dx: speed * direction, dy: 0)
        targetNode.physicsBody?.linearDamping = 0
        targetNode.physicsBody?.affectedByGravity = false
        
        targetNode.name = "target-good"
        targets.append(targetNode)
        addChild(targetNode)
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        let nodes = self.nodes(at: pos)
        
        for node in nodes {
            if (node.name ?? "").starts(with: "target") {
                print("Touched a target with name: \(node.name)")
            }
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        for target in targets {
            if target.position.x < -72 || target.position.x > size.width + 72 {
                target.removeFromParent()
            }
        }
    }
}
