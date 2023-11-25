//
//  MPCHandler.swift
//  TicTacToe
//
//  Created by Mauro Arantes on 25/11/2023.
//

import UIKit
import MultipeerConnectivity

class MPCHandler: NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate {
    
    var peerID: MCPeerID!
    var session: MCSession!
    var browser: MCBrowserViewController!
    var advertiser: MCNearbyServiceAdvertiser?
    
    let didChangeStateNotification = NSNotification.Name(rawValue: "MPC_DidChangeStateNotification")
    let didReceiveDataNotification = NSNotification.Name(rawValue: "MPC_DidReceiveDataNotification")
    
    func setupPeer(displayName: String) {
        peerID = MCPeerID(displayName: displayName)
    }
    
    func setupSession() {
        session = MCSession(peer: peerID)
        session.delegate = self
    }
    
    func setupBrowser() {
        
        browser = MCBrowserViewController(serviceType: "game", session: session)
    }
    
    func advertise(activate: Bool) {
        if activate {
            advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "game")
            advertiser?.delegate = self
            advertiser?.startAdvertisingPeer()
        } else {
            advertiser?.stopAdvertisingPeer()
            advertiser = nil
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        let userInfo: [String : Any] = ["peerID" : peerID, "state" : state.rawValue]
        NotificationCenter.default.post(name: didChangeStateNotification, object: nil, userInfo: userInfo)
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let userInfo: [String : Any] = ["data" : data, "peerID" : peerID]
        NotificationCenter.default.post(name: didReceiveDataNotification, object: nil, userInfo: userInfo)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}
