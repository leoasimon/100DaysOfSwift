//
//  GameScene.swift
//  Day66Challenge
//
//  Created by Leo on 2024-07-30.
//

import SpriteKit
import GameplayKit

enum TargetSize: Int, CaseIterable {
    case xs = 32
    case s = 48
    case m = 64
    case l = 96
    case xl = 128
}

func getTargetSpeed(with targetSize: TargetSize) -> Int {
    switch targetSize {
    case .xs:
        return 10
    case .s:
        return 6
    case .m:
        return 3
    case .l:
        return 2
    case .xl:
        return 1
    }
}

enum Row {
    case top, mid, bottom
}

class Target {
    let size: TargetSize
    let velocity: CGVector
    let sprite: SKSpriteNode
    
    init(row: Row) {
        size = TargetSize.allCases.randomElement()!
        
        let speed = getTargetSpeed(with: size)
        
        let direction = row == .mid ? -1 : 1
        
        velocity = CGVector(dx: speed * direction, dy: 0)
        
        sprite = SKSpriteNode()
    }
}

class GameScene: SKScene {
    
    let targets = [SKSpriteNode]()
    
    func getSpawnPosition(on row: Int, for targetSize: TargetSize) -> CGPoint {
        let xOffset = row == 1 ? -5 : 5
        let nRows = 3
        
        let rowHeight = size.height / CGFloat(nRows)
        
        let yOffset = 0
        
        let y = CGFloat(yOffset) + (rowHeight / CGFloat(2)) - CGFloat((targetSize.rawValue / 2))
        let x = row == 1 ? size.width : 0
        
        return CGPoint(x: x + CGFloat(xOffset), y: y)
    }

    func getScore(from targetSize: TargetSize) -> Int {
        switch targetSize {
        case .xs:
            return 10
        case .s:
            return 6
        case .m:
            return 3
        case .l:
            return 2
        case .xl:
            return 1
        }
    }
    
    override func didMove(to view: SKView) {
        let testTarget = SKSpriteNode(imageNamed: "target-good")
        
        testTarget.size = CGSize(width: 32, height: 32)
        
        testTarget.position = CGPoint(x: 200, y: 200)
        
        addChild(testTarget)
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
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
    }
    
    func spawn() {
        let row = [0,1,2].randomElement()!
        let targetSize = TargetSize.allCases.randomElement()!
        let position = getSpawnPosition(on: row, for: targetSize)
    }
}
