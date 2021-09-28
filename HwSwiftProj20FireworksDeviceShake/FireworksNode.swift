//
//  FireworksNode.swift
//  HwSwiftProj20FireworksDeviceShake
//
//  Created by Alex Wibowo on 28/9/21.
//

import UIKit
import SpriteKit

class FireworksNode: SKNode {

    
    var rocket: SKSpriteNode!
    
    
    func configureAt(at position: CGPoint){
        self.position = position
    
        rocket = SKSpriteNode(imageNamed: "rocket")
        rocket.name = "firework"
        rocket.colorBlendFactor = 1
        
        
        switch Int.random(in: 0...2) {
        case 0:
            rocket.color = .red
        case 1:
            rocket.color = .cyan
        case 2:
            rocket.color = .green
        default:
            break;
        }
        
        
        addChild(rocket)
        
        
        if let fuse = SKEmitterNode(fileNamed: "fuse") {
            fuse.position = CGPoint(x: 0, y: -15)
            addChild(fuse)
        }
    }
    
    func configureMovement(xMovement: CGFloat){
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint.zero)
        bezierPath.addLine(to: CGPoint(x: xMovement, y: 1000))
        
        run(SKAction.follow(bezierPath.cgPath, asOffset: true, orientToPath: true, speed: 200))
        
    }
}
