//
//  ViewController.swift
//  TypingGame
//
//  Created by Fernando Jinzenji on 2017-07-07.
//  Copyright © 2017 Fernando Jinzenji. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var keyboardButton: UIButton!
    
    var ref: DatabaseReference!
    var currentPlayer: Player!
    var players = [Player]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
        
        // Create a reference to Firebase Database
        self.ref = Database.database().reference()
        
        // Create a referente to the players element
        let playerRef = Database.database().reference(withPath: "players")
        
        // Set observer for changes in the players tree
        _ = playerRef.observe(DataEventType.value, with: { (snapshot) in
            
            // clear array
            self.players.removeAll()
            
            let postDict = snapshot.value as? [String : Int] ?? [:]
            
            for obj in postDict {
                self.players.append(Player(name: obj.key, index: obj.value))
            }
            
            self.tableView.reloadData()

        })
        
        // Set player 1 as initial player
        self.currentPlayer = Player(name: "player1", index: 0)
        self.players.append(self.currentPlayer)
        
        // Authenticate user (only enable keyboard press when logged)
        self.keyboardButton.isEnabled = false
        Auth.auth().signIn(withEmail: "\(self.currentPlayer.name)@abc.ca", password: "test1234") { (user, error) in
        
            if error != nil {
                print ("\(String(describing: error?.localizedDescription))")
            }
            
            self.keyboardButton.isEnabled = true
        }
        
    }

    @IBAction func keyboardPressed(_ sender: UIButton) {
        self.currentPlayer.index += 1
        self.indexLabel.text = "\(self.currentPlayer.index)"
        
        let playerRef = Database.database().reference(withPath: "players")
        let nameRef = playerRef.child(self.currentPlayer.name)
        nameRef.setValue(self.currentPlayer.index)
        
        
    }
    
    @IBAction func playerSelected(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            self.currentPlayer = Player(name: "player1", index: 0)
        case 1:
            self.currentPlayer = Player(name: "player2", index: 0)
        default:
            self.currentPlayer = Player(name: "player3", index: 0)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PlayerTableViewCell
        
        let player = self.players[indexPath.row]
        
        cell.playerNameLabel.text = player.name
        cell.positionLabel.text = "current index is \(player.index)"
        
        return cell
    }
}

