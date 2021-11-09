import SpriteKit

class MenuScene: SKScene {
    
    var playButton = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(color: .cyan, size: CGSize(width: frame.size.width, height: frame.size.height))
        
        background.position = CGPoint(x: 0, y: 0)
        playButton = SKSpriteNode(imageNamed: "play")
        playButton.position = CGPoint(x: 0, y: 0)
        playButton.size = CGSize(width: 300, height: 150)
        addChild(background)
        addChild(playButton)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let pos = touch.location(in: self)
            let node = self.atPoint(pos)
            
            if node == playButton {
                if let view = self.view {
                    if let scene = SKScene(fileNamed: "GameScene") {
                        scene.scaleMode = .aspectFill
                        view.presentScene(scene)
                    }
                }
            }
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
