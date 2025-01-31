//
//  GameViewController.swift
//  space-invaders
//
//  Created by Matheus Abrahão on 31/01/25.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let skView = view as? SKView else { return }

        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true

        // Create and configure the scene
        let scene = MainMenuScene(size: view.bounds.size)
        scene.scaleMode = .aspectFill

        // Present the scene
        skView.presentScene(scene)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
