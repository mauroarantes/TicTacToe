//
//  ViewController.swift
//  TicTacToe
//
//  Created by Mauro Arantes on 25/11/2023.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCBrowserViewControllerDelegate {
    
    @IBOutlet var fields: [TTTImageView]!
    
    var appDelegate: AppDelegate!
    var currentPlayer: String!
    var wait: Bool = false
    
    @IBAction func connectWithPlayer(sender: AnyObject) {
        if let session = appDelegate.mpcHandler.session {
            appDelegate.mpcHandler.setupBrowser()
            appDelegate.mpcHandler.browser.delegate = self
            self.present(appDelegate.mpcHandler.browser, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.mpcHandler.setupPeer(displayName: UIDevice.current.name)
        appDelegate.mpcHandler.setupSession()
        appDelegate.mpcHandler.advertise(activate: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(peerChangedStateWithNotification(notification:)), name: appDelegate.mpcHandler.didChangeStateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleReceivedDataWithNotification(notification:)), name: appDelegate.mpcHandler.didReceiveDataNotification, object: nil)
        setupField()
        currentPlayer = "x"
    }
    
    @objc func peerChangedStateWithNotification(notification: NSNotification) {
        if let dictionary = notification.userInfo {
            let userInfo = NSDictionary(dictionary: dictionary)
            let state = userInfo.object(forKey: "state") as! Int
            if state == MCSessionState.connecting.rawValue {
                DispatchQueue.main.async {
                    self.navigationItem.title = "Connected"
                }
            }
        }
    }
    
    @objc func handleReceivedDataWithNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo, let receivedData = userInfo["data"] as? Data, let senderPeerID = userInfo["peerID"] as? MCPeerID {
            do {
                let message = try JSONSerialization.jsonObject(with: receivedData) as! NSDictionary
                let senderDisplayName = senderPeerID.displayName
                let field: Int? = message.object(forKey: "field") as? Int
                let player: String? = message.object(forKey: "player") as? String
                if message.object(forKey: "string") as? String == "New Game" {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Tic Tac Toe", message: "\(senderDisplayName) has started a new game", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                            self.resetField()
                        }))
                        self.present(alert, animated: true)
                    }
                }
                if let field = field, let player = player {
                    fields[field].player = player
                    fields[field].setPlayer(_player: player)
                    wait = false
                    if player == "x" {
                        currentPlayer = "o"
                    } else {
                        currentPlayer = "x"
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
    @objc func fieldTapped(recognzier: UITapGestureRecognizer) {
        guard !wait else { return }
        let tappedField = recognzier.view as! TTTImageView
        tappedField.setPlayer(_player: currentPlayer)
        wait = true
        
        if let player = currentPlayer {
            let messageDict: [String : Any] = ["field" : tappedField.tag, "player" : player]
            do {
                let messageData = try JSONSerialization.data(withJSONObject: messageDict, options: .prettyPrinted)
                try appDelegate.mpcHandler.session.send(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, with: .reliable)
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func newGame(_ sender: Any) {
        resetField()
        
        let messageDict = ["string" : "New Game"]
        do {
            let messageData = try JSONSerialization.data(withJSONObject: messageDict, options: .prettyPrinted)
            try appDelegate.mpcHandler.session.send(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, with: .reliable)
        } catch {
            print(error)
        }
    }
    
    func setupField() {
        for index in 0 ... fields.count - 1 {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(fieldTapped(recognzier:)))
            gestureRecognizer.numberOfTapsRequired = 1
            fields[index].addGestureRecognizer(gestureRecognizer)
        }
    }
    
    func resetField() {
        DispatchQueue.main.async {
            for index in 0 ... self.fields.count - 1 {
                self.fields[index].image = nil
                self.fields[index].activated = false
                self.fields[index].player = ""
            }

        }    }
    
    func browserViewController(_ browserViewController: MCBrowserViewController, shouldPresentNearbyPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) -> Bool {
        true
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.browser.dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.browser.dismiss(animated: true)
    }
}

