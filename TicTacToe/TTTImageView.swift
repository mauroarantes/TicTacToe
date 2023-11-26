//
//  TTTImageView.swift
//  TicTacToe
//
//  Created by Mauro Arantes on 25/11/2023.
//

import UIKit

class TTTImageView: UIImageView {
    
    var player: String?
    var activated: Bool = false
    
    func setPlayer(_player: String) {
        self.player = _player
        DispatchQueue.main.async {
            if self.activated == false, _player == "x" {
                self.image = UIImage(named: "x")
            } else {
                self.image = UIImage(named: "o")
            }
            self.activated = true
        }
    }
}
