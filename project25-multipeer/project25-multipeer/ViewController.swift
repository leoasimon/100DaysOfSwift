//
//  ViewController.swift
//  project25-multipeer
//
//  Created by Leo on 2024-08-25.
//

import UIKit
import MultipeerConnectivity

class ViewController: UICollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var images = [UIImage]()
    
    var peerId = MCPeerID(displayName: UIDevice.current.name)
    var mcSession: MCSession?
    var mcAdvertiserAssistant: MCAdvertiserAssistant?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Selfie Share"
        //        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(importPhoto))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showConnectionPrompt))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareToNetwork))
        
        mcSession = MCSession(peer: peerId, securityIdentity: nil, encryptionPreference: .required)
        mcSession?.delegate = self
    }
    
    @objc func shareToNetwork() {
        let ac = UIAlertController(title: "Have something to share?", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Send a message", style: .default, handler: sendMessage))
        ac.addAction(UIAlertAction(title: "Import a photo", style: .default, handler: importPhoto))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func sendMessage(_: UIAlertAction) {
        let ac = UIAlertController(title: "Write a message", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Send", style: .default) {
            [weak self] action in
            guard let text = ac.textFields?[0].text else { return }
            
            // 1 - Check if we have an active session we can use.
            guard let mcSession = self?.mcSession else {
                return
            }
            
            // 2 - Check if there are any peers to send to.
            guard mcSession.connectedPeers.count > 0 else { return }
            
            // 3 - Convert the new image to a Data object.
            let data = Data(text.utf8)
            
            // 4 - Send it to all peers, ensuring it gets delivered.
            do {
                try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
            } catch {
                // 5 - Show an error message if there's a problem.
                let ac = UIAlertController(title: "Unable to share picture", message: "An error occured while trying to share your picture", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(ac, animated: true)
            }
        })
    }
    
    @objc func showConnectionPrompt() {
        let ac = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Host a session", style: .default, handler: startHosting))
        ac.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "See connected users", style: .default, handler: seeConnectedPeers))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc func importPhoto(_: UIAlertAction) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func seeConnectedPeers(_: UIAlertAction) {
//        let users = ["Paul", "Mary", "Adrian"]
        
//        let message = """
//Here are all the users currently logged to your network
//
//Paul
//Mary
//Adrian
//"""
        guard let mcSession = mcSession else {
            return
        }

        let connectedUsers = mcSession.connectedPeers
        var message = "Here are all the users currently logged to your network:\n\n"
        
        for user in connectedUsers {
            message += "\(user.displayName)\n"
        }
        
        if connectedUsers.isEmpty {
            message += "No user connected yet :("
        }
        
        let ac = UIAlertController(title: "Connected users", message: message, preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(ac, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath)
        
        guard let imageView = cell.viewWithTag(1000) as? UIImageView else { return cell }
        
        imageView.image = images[indexPath.item]
        
        return cell
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        dismiss(animated: true)
        
        images.insert(image, at: 0)
        collectionView.reloadData()
        
        // 1 - Check if we have an active session we can use.
        guard let mcSession = mcSession else {
            return
        }
        
        // 2 - Check if there are any peers to send to.
        guard mcSession.connectedPeers.count > 0 else { return }
        
        // 3 - Convert the new image to a Data object.
        guard let data = image.pngData() else { return }
        
        // 4 - Send it to all peers, ensuring it gets delivered.
        do {
            try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
        } catch {
            // 5 - Show an error message if there's a problem.
            let ac = UIAlertController(title: "Unable to share picture", message: "An error occured while trying to share your picture", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        
    }
    
    func startHosting(action: UIAlertAction) {
        guard let mcSession = mcSession else {
            return
        }
        
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "lsi-project25", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant?.start()
    }
    
    func joinSession(action: UIAlertAction) {
        guard let mcSession = mcSession else {
            return
        }
        
        let mcBrowser = MCBrowserViewController(serviceType: "lsi-project25", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }
    
    func showNewMessage(_ message: String) {
        let ac = UIAlertController(title: "Message received!", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(ac, animated: true)
    }
}

extension ViewController: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
}

extension ViewController: MCSessionDelegate {
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("Connected: \(peerID.displayName)")
        case .connecting:
            print("Connecting: \(peerID.displayName)")
        case .notConnected:
            // print("Not connected: \(peerID.displayName)")
            notifyDisconnect(name: peerID.displayName)
        @unknown default:
            print("Unknwown start received: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async { [weak self] in
            if let image = UIImage(data: data) {
                self?.images.insert(image, at: 0)
                self?.collectionView.reloadData()
            } else {
                let text = String(decoding: data, as: UTF8.self)
                self?.showNewMessage(text)
            }
        }
    }
    
    func notifyDisconnect(name: String) {
        let ac = UIAlertController(title: "Someone just left", message: "\(name) has disconnected, bye \(name)!", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

