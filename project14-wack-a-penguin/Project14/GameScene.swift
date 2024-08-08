//
//  GameScene.swift
//  Project14
//
//  Created by Leo on 2024-07-04.x
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var slots = [WhackSlot]()
    
    var gameScore: SKLabelNode!
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    var popupTime = 0.85
    var numRounds = 0
    
    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0, y: 0)
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 384)
        //        background.position = CGPoint(x: 0, y: 0)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x: 8, y: 8)
        //        gameScore.position = CGPoint(x: 0, y: 0)
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        for i in 0..<5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 410)) }
        for i in 0..<4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 320)) }
        for i in 0..<5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 230)) }
        for i in 0..<4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 140)) }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.createEnemy()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let tappedNodes = nodes(at: touch.location(in: self))
        
        for node in tappedNodes {
            guard let whackSlot = node.parent?.parent as? WhackSlot else { return }
            if !whackSlot.isVisible { return }
            if whackSlot.isHit { return }
            
            whackSlot.hit()
            
            if node.name == "charFriend" {
                score -= 5
                
                SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false)
            }
            
            if node.name == "charEnemy" {
                whackSlot.charNode.xScale = 0.85
                whackSlot.charNode.yScale = 0.85
            
                score += 1
                
                SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false)
            }
        }
    }
    
    func createSlot(at position: CGPoint) {
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        slots.append(slot)
    }
    
    func createEnemy() {
        popupTime *= 0.991
        
        slots.shuffle()
        slots[0].show(hideTime: popupTime)
        
        if Int.random(in: 0...12) > 4 { slots[1].show(hideTime: popupTime)}
        if Int.random(in: 0...12) > 8 { slots[2].show(hideTime: popupTime)}
        if Int.random(in: 0...12) > 10 { slots[3].show(hideTime: popupTime)}
        if Int.random(in: 0...12) > 11 { slots[4].show(hideTime: popupTime)}
        
        let minDelay = popupTime / 2
        let maxDelay = popupTime * 2
        let delay = Double.random(in: minDelay...maxDelay)
        
        numRounds += 1
        if (numRounds >= 30) {
            gameOver()
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {[weak self] in self?.createEnemy()})
    }
    
    func gameOver() {
        for slot in slots {
            slot.hide()
        }
        
        let gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.position = CGPoint(x: 512, y: 384)
        gameOver.zPosition = 1
        addChild(gameOver)
        
        let finalScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        finalScoreLabel.text = "Final score: \(score)"
        finalScoreLabel.position = CGPoint(x: 512, y: 300)
        finalScoreLabel.zPosition = 1
        addChild(finalScoreLabel)
        
        SKAction.playSoundFileNamed("GAMEOVER.caf", waitForCompletion: false)
    }
}
