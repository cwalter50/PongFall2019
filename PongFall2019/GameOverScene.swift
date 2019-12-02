//
//  GameOverScene.swift
//  PongFall2019
//
//  Created by  on 12/2/19.
//  Copyright © 2019 DocsApps. All rights reserved.
//

import UIKit

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    override func didMove(to view: SKView) {
        let label = SKLabelNode(fontNamed: "Arial")
        label.numberOfLines = 2
        label.text = "GameOver\nYou:\(GameScene.playerScore) Computer:\(GameScene.computerScore) "
        label.fontSize = 50
        label.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        label.name = "label"
        addChild(label)
        
        let playAgainButton = SKLabelNode(fontNamed: "Arial")
        playAgainButton.text = "Play Again?"
        playAgainButton.fontSize = 50
        playAgainButton.position = CGPoint(x: frame.width / 2, y: frame.height * 0.2)
        playAgainButton.name = "playAgainButton"
        addChild(playAgainButton)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        
        let myNodes = nodes(at: touchLocation)
        
        for node in myNodes {
            if node.name == "playAgainButton" {
                let gameScene = GameScene(fileNamed: "GameScene")
                gameScene?.scaleMode = .aspectFill
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                view?.presentScene(gameScene!, transition: reveal)
            }
        }
    }
    
}

