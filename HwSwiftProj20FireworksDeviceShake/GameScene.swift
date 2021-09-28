//
//  GameScene.swift
//  HwSwiftProj20FireworksDeviceShake
//
//  Created by Alex Wibowo on 28/9/21.
//

import SpriteKit


class GameScene: SKScene {
    
    var scoreLabel : SKLabelNode!
    var playAgain: SKLabelNode!
    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22
    
    let numRounds = 8
    var currentRound = 0
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var fireworks = [FireworksNode]()
    var gameTimer : Timer!
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background")
        
        background.blendMode = .replace
        background.position = CGPoint(x: 512, y: 384)
        background.zPosition = -1
        addChild(background)
       
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x:50, y: 50)
        addChild(scoreLabel)
        
        
        playAgain = SKLabelNode(fontNamed: "Chalkduster")
        playAgain.position = CGPoint(x: 512, y: 384)
        playAgain.text = "Play again?"
        playAgain.name = "PLAYAGAIN"
        playAgain.horizontalAlignmentMode = .center
        playAgain.alpha = 0
        playAgain.zPosition = 5
        addChild(playAgain)
        
        score = 0
        
        gameTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(launchFireworks), userInfo:
                                            nil, repeats: true)
        
    }
    
    func createFirework(xMovement: CGFloat, x: Int, y: Int){
      
            
            let firework = FireworksNode()
            firework.configureAt(at: CGPoint(x: x, y: y))
            firework.configureMovement(xMovement: xMovement)
            
            fireworks.append(firework)
            addChild(firework)
            
    }
    
    @objc func launchFireworks(){
        
        if currentRound <= numRounds {
            currentRound += 1
            playAgain.alpha = 0
        
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
            
        } else {
            gameTimer.invalidate()
            playAgain.run(SKAction.fadeIn(withDuration: 0.7))
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        let nodes = nodes(at: location)
        
        if nodes.contains(playAgain) {
            score = 0
            currentRound = 0
            playAgain.alpha = 0
            gameTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
        } else {
            checkTouch(touches)
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouch(touches)
    }
    
    
    func checkTouch(_ touches: Set<UITouch>){
        guard let touch = touches.first else { return }
        let firstTouch = touch.location(in: self)
        let nodes = nodes(at: firstTouch)
        
        for case let node as SKSpriteNode in nodes {
            guard node.name == "firework" else { continue }
            
            for parent in fireworks {
                guard let firstChild = parent.children.first as? SKSpriteNode else { continue }
                
                if firstChild.name == "selected" && firstChild.color != node.color {
                    firstChild.name = "firework"
                    firstChild.colorBlendFactor = 1
                }
            }
           
            node.name = "selected"
            node.colorBlendFactor = 0
        }
        
    }
    
    func explode(firework: FireworksNode) {
        if let explode  = SKEmitterNode(fileNamed: "explode") {
            explode.position = firework.position
            addChild(explode)
        }
        firework.removeFromParent()
    }
    
    
    func explodeFireworks(){
        var numExploded = 0
        for (index, firework) in fireworks.enumerated().reversed() {
            guard let firstChild = firework.children.first as? SKSpriteNode else { continue }
            
            if firstChild.name == "selected" {
                explode(firework: firework)
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
   
    
    override func update(_ currentTime: TimeInterval) {
        
        for (index, firework) in fireworks.enumerated().reversed() {
            
           
            if firework.position.y > 900 {
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
        
    }
}
