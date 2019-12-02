//
//  GameScene.swift
//  PongFall2019
//
//  Created by  on 11/25/19.
//  Copyright © 2019 DocsApps. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ball = SKSpriteNode()
    var paddle = SKSpriteNode()
    var aiPaddle = SKSpriteNode()
    
    // top and bottom will help keep score
    var bottom = SKSpriteNode()
    var top = SKSpriteNode()
    var playerScoreLabel = SKLabelNode()
    var computerScoreLabel = SKLabelNode()
    static var playerScore = 0
    static var computerScore = 0
        
    override func didMove(to view: SKView) {
        
        // Set border of the world to the frame
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0.0
        self.physicsBody = borderBody
        
        // take gravity out of physics world
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        
        // get reference to paddle and ball
        paddle = childNode(withName: "paddle") as! SKSpriteNode
        ball = childNode(withName: "ball") as! SKSpriteNode
        
        createAIPaddle()
        
        setUpLabels()
        createBottomAndTopNodes()
        
        // optional addition.... this will round the SpriteKit Node for the ball.
        makeBallCircle()
        
        
        // set the bitmasks. These will help us later to determine what makes contact with what.
        ball.physicsBody!.categoryBitMask = 1
        paddle.physicsBody!.categoryBitMask = 2 // only necessarry for stretches
        aiPaddle.physicsBody!.categoryBitMask = 3 // only necessary for stretches
        bottom.physicsBody!.categoryBitMask = 4
        top.physicsBody!.categoryBitMask = 4
        
        // this will help whenever ball contacts bottom.  Add SKPhysicsContactDelegate to get access to methods. You can set multiple contactTestBitMask like 2 | 3 | 4
        ball.physicsBody!.contactTestBitMask = 4
        physicsWorld.contactDelegate = self // this will allow us to call didBegin(contact...)

    }

    func createAIPaddle() {
        // Create the Sprite programmatically.  You can play with the size of the paddle and the duration of the wait time to make the game easier or harder
        aiPaddle = SKSpriteNode(color: UIColor.black, size: CGSize(width: 200, height: 50))
        aiPaddle.position = CGPoint(x: frame.width * 0.5, y: frame.height * 0.8)
        aiPaddle.physicsBody = SKPhysicsBody(rectangleOf: aiPaddle.frame.size)
        // unwrap and set up physics
        if let aiPhysics = aiPaddle.physicsBody {
            aiPhysics.allowsRotation = false
            aiPhysics.friction = 0.0
            aiPhysics.affectedByGravity = false
            aiPhysics.isDynamic = false
        }
        aiPaddle.name = "aiPaddle"
        aiPaddle.zPosition = 1
        addChild(aiPaddle)
        
//      run an action for the aiPaddle to follow the ball.
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run(followBall),
                SKAction.wait(forDuration: 0.4)
            ])
        ))
    }
        
    func followBall() {
        let move = SKAction.moveTo(x: self.ball.position.x, duration: 0.4)
        self.aiPaddle.run(move)
    }

    
    // allows paddle to move only when it is touched.
    var isFingerOnPaddle = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self)
        
        if paddle.frame.contains(location)
        {
            // we found the paddle!
            isFingerOnPaddle = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self)
        if isFingerOnPaddle == true
        {
            paddle.position = CGPoint(x: location.x, y: paddle.position.y)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isFingerOnPaddle = false
    }
    
    
    func createBottomAndTopNodes() {
        // create a view at the very bottom and top
        bottom = SKSpriteNode(color: .red, size: CGSize(width: frame.width, height: 50))
        bottom.position = CGPoint(x: frame.width * 0.5, y: 0)
        bottom.physicsBody = SKPhysicsBody(rectangleOf: bottom.frame.size)
        bottom.physicsBody!.isDynamic = false
        bottom.name = "bottom"
        addChild(bottom)
        
        top = SKSpriteNode(color: .red, size: CGSize(width: frame.width, height: 50))
        top.position = CGPoint(x: frame.width * 0.5, y:frame.height)
        top.physicsBody = SKPhysicsBody(rectangleOf: top.frame.size)
        top.physicsBody!.isDynamic = false
        top.name = "top"
        addChild(top)
    }
    
    func setUpLabels() {
        playerScoreLabel = SKLabelNode(fontNamed: "Arial")
        playerScoreLabel.text = "0"
        playerScoreLabel.fontSize = 75
        playerScoreLabel.position = CGPoint(x: frame.width * 0.25, y: frame.height * 0.10)
        playerScoreLabel.fontColor = UIColor.black
        addChild(playerScoreLabel)
        
        computerScoreLabel = SKLabelNode(fontNamed: "Arial")
        computerScoreLabel.text = "0"
        computerScoreLabel.fontSize = 75
        computerScoreLabel.position = CGPoint(x: frame.width * 0.25, y: frame.height * 0.90)
        computerScoreLabel.fontColor = UIColor.black
        addChild(computerScoreLabel)
    }

    
    func didBegin(_ contact: SKPhysicsContact) {
//        print("contact")
        
//        print(contact.contactPoint)
        
        if (contact.bodyA.categoryBitMask == 1 || contact.bodyB.categoryBitMask == 1) && (contact.bodyA.categoryBitMask == 4 || contact.bodyB.categoryBitMask == 4)
        {
            // either (body A or body B is the ball) && (bodyA or bodyB is topOrBottom)
            if contact.bodyA.node == top || contact.bodyB.node == top
            {
                GameScene.playerScore += 1
            }
            else
            {
                GameScene.computerScore += 1
            }
            updateLabels()
            resetBall()
            if GameScene.playerScore == 5 || GameScene.computerScore == 5{
                let gameOverScene = GameOverScene(size: self.size)
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                view?.presentScene(gameOverScene, transition: reveal)
            }
        }
    }
    
    func updateLabels()
    {
        playerScoreLabel.text = "\(GameScene.playerScore)"
        computerScoreLabel.text = "\(GameScene.computerScore)"
    }
    
    func resetBall() {
        // stop the ball...
        ball.physicsBody!.velocity = CGVector.zero
        // wait for 1 second, move to center, wait 1 second, push again
        let wait = SKAction.wait(forDuration: 1.0)
        let repositionBall = SKAction.run(bringBallToCenter)
        let pushBall = SKAction.run(applyImpulseToBall)
        let sequence = SKAction.sequence([wait, repositionBall, wait, pushBall])
        run(sequence)
    }
    
    func bringBallToCenter() {
        ball.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
    }

    func applyImpulseToBall() {
        let impulseArray = [200, -200, 150, -150]
        let randx = Int.random(in: 0..<impulseArray.count)
        let randy = Int.random(in: 0..<impulseArray.count)
        ball.physicsBody!.applyImpulse(CGVector(dx: impulseArray[randx], dy: impulseArray[randy]))
    }


    func makeNewBall(touchLocation: CGPoint)
       {
           let newBall = SKSpriteNode(imageNamed: "ball")
           newBall.size = CGSize(width: 100.0, height: 100.0)
           newBall.position = CGPoint(x: (touchLocation.x), y: (touchLocation.y))
           addChild(newBall)
           newBall.physicsBody = SKPhysicsBody(circleOfRadius: 50)
           newBall.physicsBody?.affectedByGravity = true
           newBall.physicsBody?.friction = 0.0
           newBall.physicsBody?.allowsRotation = true
           newBall.physicsBody?.restitution = 1.0
           newBall.physicsBody?.velocity = CGVector(dx: -500, dy: 500)
           newBall.physicsBody?.angularVelocity = 20
       }
    
    func makeBallCircle()
    {
        // Make the ball a circle.
        let shape: SKShapeNode = SKShapeNode(circleOfRadius: 50)
        shape.name = "shape"
        shape.lineWidth = 1 // this way we see that this is a circle
        shape.fillColor = .orange // to see the true colors of our image
        //shape.strokeColor = .white
        shape.glowWidth = 20.0
//        shape.fillTexture = SKTexture(imageNamed:"myImage")
        shape.position = CGPoint(x: 0, y:200)
        self.addChild(shape)

        let newTexture: SKTexture = (self.view?.texture(from: self.childNode(withName: "shape")!))!
        
        // get reference to paddle and ball
        ball = childNode(withName: "ball") as! SKSpriteNode
        ball.texture = newTexture
    }

}
