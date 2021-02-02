//
//  TrainingVC.swift
//  CheckList app
//
//  Created by Ernest Essuah Mensah on 3/9/20.
//  Copyright © 2020 Jaina Gandhi. All rights reserved.
//

import UIKit
import AVFoundation

class TrainingVC: BaseItemAudioVC {
    
    var isRecording = false
    var recordedAudio = false
    
    var hasName = false
    var isTraining = true
    var object_name = "tmpobj"
    var trainChecker: Timer!
    var toastLabel: UILabel!
    var guideText = "You can add a personal note to the item by recording an audio description of the item. For example, my favorite almond, cashew and walnut nutbars from Kirkland."
    var olView: UIView!
    
    var recordingSession: AVAudioSession!
    let userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(ParticipantViewController.userName)")
    var httpController = HTTPController()
    var fileName = "recording-tmpobj.wav"
    
    var saveButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        view.accessibilityLabel = "Enter description"
        navigationItem.titleView = Functions.createHeaderView(title: "New Object")
        presentEnterNameVC()
        
        Log.writeToLog("\(Actions.enteredScreen.rawValue) \(Screens.editNewObjScreen.rawValue)")
        print("start TrainingVC")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Log.writeToLog("\(Actions.exitedScreen.rawValue) \(Screens.editNewObjScreen.rawValue)")
    }
    
    
    override func handleMainActionButton() {
        print("Overiding and action should be recording..")
        handleRecording()
    }
    
    override func handleSecondaryActionButton() {
        presentEnterNameVC()
    }
    
    func setupButtons() {
        
        // Set up the action buttons
        let playImage = #imageLiteral(resourceName: "record")
        
        mainActionButton.setImage(playImage, for: .normal)
        secondaryButton.setTitle("RENAME", for: .normal)
        tertiaryButton.setTitle("RESET", for: .normal)
        
        progressBar.isHidden = true
        elapsedLabel.isHidden = true
        remainingLabel.isHidden = true
        
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setTitleColor(.lightGray, for: .highlighted)
        saveButton.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 16)
        saveButton.setTitle("SAVE", for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        saveButton.accessibilityLabel = "Save \(objectName) to you items and begin training."
        saveButton.isHidden = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
    }
    
    @objc
    func saveButtonAction() {
        
        //TODO: Handle saving object to database and begin training..
        print("Saving.....")
        
        uploadPhotos()
        
        // upload arkit info
        httpController.sendARInfo(object_name: object_name) {(response) in
            print("Send AR Info: " + response)
        }

        Log.writeToLog("\(Actions.tappedOnBtn.rawValue) saveButton")
        navigationController?.popToRootViewController(animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            Functions.stopGyros()
        }
    }
    
    ///MARK: - This sends the photos to the database for training
    func uploadPhotos() {
        DispatchQueue.global(qos: .background).async {
            
            self.markTraining()
            let images = Functions.fetchImages(for: "tmpobj")
            
            for (index, image) in images.enumerated() {
                self.httpController.sendImage(object_name: self.object_name, index: index, image: image) {}
            }
            
            self.httpController.reqeustTrain {
                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, "Training ended.")
                print("Training ended.")
            }
            
            Functions.deleteImages(for: self.object_name)
            Functions.saveRecording(for: self.object_name)
        }
        
//       DispatchQueue.global(qos: .background).async{
//           //Time consuming task here
//           UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.toastLabel)
//           
//           self.markTraining()
//            
//           for i in 1...ParticipantViewController.itemNum {
//               self.httpController.sendImage(object_name: self.object_name, index: i){}
//           }
//           
//           self.httpController.reqeustTrain(){
//               //self.textToSpeech("Training ended.")
//               UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, "Training ended.")
//           }
//        
//        Functions.deleteImages(for: self.object_name)
//
//       }
    }
    
    func markTraining() {
        let file = "trainMark.txt" //this is the file. we will write to and read from it
        let text = "on"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            
            //writing
            do {
                try text.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {/* error handling here */}
        }
    }
    
    func openEnterNameView() {
        // custom view
        // https://medium.com/if-let-swift-programming/design-and-code-your-own-uialertview-ec3d8c000f0a
        let customAlert = storyboard?.instantiateViewController(withIdentifier: "EnterNameUI") as! EnterNameController
        //customAlert.delegate = self
        //customAlert.parentView = self
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(customAlert, animated: true, completion: nil)
    }
    
    func presentEnterNameVC() {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let enterNameVC = mainStoryboard.instantiateViewController(withIdentifier: "EnterNameUI") as! EnterNameController
        enterNameVC.modalPresentationStyle = .overCurrentContext
        enterNameVC.providesPresentationContextTransitionStyle = true
        enterNameVC.definesPresentationContext = true
        enterNameVC.modalTransitionStyle = .crossDissolve
        enterNameVC.trainingVC = self
        present(enterNameVC, animated: true, completion: nil)
        
    }
    
    func rename(newName: String) {
        ParticipantViewController.writeLog("TrainingView-rename-\(newName)")
        Log.writeToLog("\(Actions.renamedSavedObj.rawValue) new_name= \(newName)")
        httpController.requestRename(org_name: "tmpobj", new_name: newName){}
        print("---> Invoking rename function...")
        
//        do {
//            let fileManager = FileManager.init()
//            var isDirectory = ObjCBool(true)
//            if fileManager.fileExists(atPath: userDirectory.appendingPathComponent("tmpobj").appendingPathComponent("recording-tmpobj.wav").path, isDirectory: &isDirectory) {
//                try fileManager.moveItem(atPath: userDirectory.appendingPathComponent("tmpobj").appendingPathComponent("recording-tmpobj.wav").path, toPath: userDirectory.appendingPathComponent("tmpobj").appendingPathComponent("recording-\(newName).wav").path)
//                print("Saved audio file?")
//            } else {
//                print("Didn't save my G")
//            }
//
//            if fileManager.fileExists(atPath: userDirectory.appendingPathComponent("tmpobj").path, isDirectory: &isDirectory) {
//                try fileManager.moveItem(atPath: userDirectory.appendingPathComponent("tmpobj").path, toPath: userDirectory.appendingPathComponent(newName).path)
//            }
//        }
//        catch let error as NSError {
//            print("Ooops! Something went wrong: \(error)")
//        }
        
        self.title = object_name
        navigationItem.titleView = Functions.createHeaderView(title: newName)
        object_name = newName
        hasName = true
        saveButton.isHidden = false
    }
    
    
    /// -----------------------------------------------------------------------
    //  RECORDING FUNCTIONS
    /// -----------------------------------------------------------------------
    
    //var isRecorded = false
    func handleRecording() {
        
        if recordedAudio {
            
            progressBar.isHidden = false
            elapsedLabel.isHidden = false
            remainingLabel.isHidden = false
            
            if audioController.isAudioPlaying() {
                
                audioTimer.invalidate()
                audioController.stopAudio()
                progressBar.progress = 0.0
                
            } else {
                
                audioController.playFileSound(name: "recording-tmpobj.wav", delegate: nil)
                audioDuration = audioController.audioPlayer.duration - 0.3
                audioTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(checkAudioTime), userInfo: nil, repeats: true)
                remainingLabel.text = timeFloatToStr(audioDuration)
            }
            return
        }
        
        if isRecording {
            ParticipantViewController.writeLog("TrainRecordStop")
            print("Stop recording -----> ")
            
            audioController.stopRecording()
            
            isRecording = false
            recordedAudio = true
            mainActionButton.setImage(#imageLiteral(resourceName: "play_button"), for: .normal)
            
        } else {
            
            mainActionButton.setImage(#imageLiteral(resourceName: "recording"), for: .normal)
            ParticipantViewController.writeLog("TrainRecordStart")
            print("Recording -----> ")
            
            audioController.startRecording(fileName: "recording-tmpobj.wav", delegate: nil)
            isRecording = true
        }
    }
    
    @objc
    override func checkAudioTime() {
        let currTime = audioController.audioPlayer.currentTime
        if currTime >= audioDuration {
           audioController.stopAudio()
           audioTimer.invalidate()
           
           progressBar.progress = 0.0
           elapsedLabel.text = "0:00"
           remainingLabel.text = timeFloatToStr(audioDuration)
        } else {
           progressBar.progress = Float(currTime / audioDuration)
           elapsedLabel.text = timeFloatToStr(currTime)
           //remainingLabel.text = "-\(timeFloatToStr(Double(Int(audioDuration)) - currTime + 1.0))"
       }
    }
    
//    func textToSpeech(_ text: String) {
//        if synth.isSpeaking {
//            synth.stopSpeaking(at: AVSpeechBoundary.immediate)
//        }
//
//        print("tts: \(text)")
//        myUtterance = AVSpeechUtterance(string: text)
//        myUtterance.rate = AVSpeechUtteranceDefaultSpeechRate
//        myUtterance.volume = 1.0
//        synth.speak(myUtterance)
//    }
    

}

//extension TrainingVC: AVAudioRecorderDelegate {
//    
//    
//}
