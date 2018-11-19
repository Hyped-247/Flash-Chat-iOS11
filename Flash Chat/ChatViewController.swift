//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework



class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    
    
    // Declare instance variables here
    var messageArray : [Message] = [Message]()

    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTextfield.delegate = self

        
        
        //TODO: Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target: self, action:
            #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        
        

        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil),
        forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        retrieveMessages()
        
        messageTableView.separatorStyle = .none
        
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    
    //TODO: Declare cellForRowAtIndexPath here:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        if cell.senderUsername.text == Auth.auth().currentUser?.email as String! {
           cell.avatarImageView.backgroundColor = UIColor.flatMint()
           cell.messageBackground.backgroundColor = UIColor.flatLime()
        } else {
            cell.avatarImageView.backgroundColor = UIColor.flatRed()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        }
        
        
        
        return cell
        
    }
    
    
    //TODO: Declare numberOfRowsInSection here:
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return
//    }
    //TODO: Declare tableViewTapped here:
     @objc func tableViewTapped(){
        messageTextfield.endEditing(true)
    }
   
    
    //TODO: Declare configureTableView here:
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    

    
    //TODO: Declare textFieldDidBeginEditing here:
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5){
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    //TODO: Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5){
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
            
        }
        
    }

    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        
        
        let messagesDB = Database.database().reference().child("Messages")
        
        let messageDic = ["Sender" : Auth.auth().currentUser?.email,
                          "MessageBody" : messageTextfield.text!]
        
        messagesDB.childByAutoId().setValue(messageDic){
            (error, reference) in
            
            if error != nil {
                print(error!)
            } else {
                print("Message have been successfully saved")
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            }
        }
    }
    
    //TODO: Create the retrieveMessages method here:
    func retrieveMessages(){
        
        // whenever there is a new message added, bring it back here.
        let messageDB = Database.database().reference().child("Messages")
        messageDB.observe(.childAdded) { (snapshot) in
            
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            
            let messageObj = Message()
            messageObj.messageBody = text
            messageObj.sender = sender
            self.messageArray.append(messageObj)
            
            self.configureTableView()
            self.messageTableView.reloadData()
            
            
           
        }
    }
    @IBAction func logOutPressed(_ sender: AnyObject) {
        do {
            try Auth.auth().signOut()
            // This will send the user back to the main page after they logout. 
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print("error, cannot log out.. ")
        }
        
    }
    


}
