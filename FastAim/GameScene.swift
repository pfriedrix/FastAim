//
//  GameScene.swift
//  FastAim
//
//  Created by Ivan Romancev on 08.11.2021.
//

import SpriteKit
import UIKit

class GameScene: SKScene, UIWebViewDelegate {
    
    var score: Int = 0
    var timeStart = Date()
    let hole = SKSpriteNode(imageNamed: "hole")
    let mole = SKSpriteNode(imageNamed: "mole")
    let gameOver = SKSpriteNode(imageNamed: "gameover")
    var scoreLabel = SKLabelNode()
    
    var moveableArea = SKNode()
    var webview = UIWebView()
    
    var showWebView = false
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(color: .green, size: CGSize(width: frame.size.width, height: frame.size.height))
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = 1
        addChild(background)
        drawMole()
        
        scoreLabel.setScale(0.1)
        scoreLabel.fontSize = 32
        scoreLabel.text = String(score)
        scoreLabel.position = CGPoint(x: 0, y: 0)
        scoreLabel.zPosition = 10
        scoreLabel.fontColor = .red
        scoreLabel.verticalAlignmentMode = .center
        
        
        addChild(hole)
        addChild(mole)
        addChild(scoreLabel)
        
        let swipeRight : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedRight))
        
        swipeRight.direction = .right
        
        view.addGestureRecognizer(swipeRight)
    }
    
    private func drawMole() {
        let randomX = Double.random(in: frame.minX+100...frame.maxX-100)
        let randomY = Double.random(in: frame.minY+100...frame.maxY-100)
        hole.position = CGPoint(x: randomX, y: randomY)
        mole.position = CGPoint(x: randomX, y: randomY - 10)
        hole.zPosition = 2
        mole.zPosition = 3
        mole.alpha = 0
        let action = SKAction.group([SKAction.fadeIn(withDuration: 0.3), SKAction.moveTo(y: randomY, duration: 0.2)])
        mole.run(action)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if score == 0 {
            timeStart = Date()
        }
        
        if let touch = touches.first {
            let currTime = Date()
            let pos = touch.location(in: self)
            let node = self.atPoint(pos)
            if node == mole {
                mole.zPosition = -1
                hole.zPosition = -1
                score += 1
                
                
                animateScore(score)
                
                if score >= 10 {
                    let overallTime = currTime.timeIntervalSinceReferenceDate - self.timeStart.timeIntervalSinceReferenceDate
                    gameOver.zPosition = 2
                    gameOver.position = CGPoint(x: 0, y: 0)
                    addChild(gameOver)
                    self.finish(overallTime < 7 ? true : false)
                    self.showWebView.toggle()
                    
                }
                else {
                    drawMole()
                }
            }
        }
    }
    
    private func animateScore(_ score: Int) {
        scoreLabel.text = String(score)
        let actionScale = SKAction.scale(to: 10, duration: 0.3)
        let actionFadeOut = SKAction.fadeOut(withDuration: 0.2)
        let action = SKAction.group([actionScale, actionFadeOut])
        scoreLabel.run(action)
        scoreLabel.alpha = 1
        scoreLabel.setScale(0.1)
    }
    
    private func loadWebView(_ win: Bool, route: Route?) {
        if let route = route {
            let urlString = win ? route.winner : route.loser
            webview.delegate = self
            webview.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            
            if let url = URL(string: urlString) {
                webview.loadRequest(URLRequest(url: url))
                webview.scalesPageToFit = true
                view?.addSubview(webview)
            }
        }
    }
    
    @objc func swipedRight(sender: UISwipeGestureRecognizer) {
        if showWebView {
            webview.removeFromSuperview()
            showWebView.toggle()
        }
        else {
            if let scene = SKScene(fileNamed: "MenuScene") {
                scene.scaleMode = .aspectFill
                
                view?.presentScene(scene)
            }
        }
    }
    
    
    
    private func finish(_ win: Bool) {
        let url = URL(string: "https://2llctw8ia5.execute-api.us-west-1.amazonaws.com/prod")
        if let url = url {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                let route = try! decoder.decode(Route.self, from: data)
                DispatchQueue.main.async {
                    self.loadWebView(win, route: route)
                }
            }
            task.resume()
        }
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        
    }
}


struct Route: Codable {
    let winner: String
    let loser: String
}
