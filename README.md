# TOR Mobile Application
<a href="https://jonggi.github.io"><img src="https://img.shields.io/badge/contact-Jonggi Hong-blue.svg?style=flat" alt="Contact"/></a>
<a href="LICENSE.md"><img src="https://img.shields.io/badge/license-TBD-red.svg?style=flat" alt="License: TBD"/></a>
<img src="https://img.shields.io/badge/platform-ios-green"/> 
<img src="https://img.shields.io/badge/language-swift 4.0-lightblue"/>

The Swift 4.0 codes of the TOR app. The TOR mobile application includes user interfaces and communication with the Amorgos server in the IAM Lab.
The user interfaces consists of main screen, training, scanning, and a list of items as shown below. The user interface of the app was designed based on the screen size of iPhone 8.

<p align="center">
  <img src="Docs/overview.jpg" alt="Overview of the TOR app">
</p>

## Requirements
In order to run the TOR app, you will need to meet the following requirements:
```
- A Mac with Xcode 13.0 or later
- Git command line tools or a git source control client like Tower. 
- iOS 12.1 or later
- Download and run the TOR Server codes
```
TOR Server codes are [here](https://github.com/IAMLabUMD/TORApp-Server).

## Getting started
To build and run the TOR app, please follow these steps,
1. Clone the repository
2. Open the project in Xcode by selecting `TOR-Mobile.xcworkspace`
3. Set your Apple account as a developer of the app in the Signing & Capabilities tab. Add and select your Apple account for 'Team' and use any name for 'Bundle identifier' (see the example below).

<p align="center">
  <img src="Docs/signing.png" alt="Signing and capabilities">
</p>

4. Connect an iPhone to your computer
5. Run the app

<p align="center">
  <img src="Docs/run.png" alt="Signing and capabilities">
</p>

## Structure of the app
The source codes are organized based on their functionalities (i.e., main screen, teach, scan, list of items, communication with the server, and logging). 

### Main screen
`MainViewController.swift`

<img src="Docs/Screenshots/main.PNG" width="25%" alt="main screen">

 


### Teach



`Teach TORVCs/ARViewController.swift`

`Teach TORVCs/ReviewTraining.swift`

`Teach TORVCs/TrainingVC.swift`

<img src="Docs/Screenshots/main.PNG" width="25%" alt="main screen"> <img src="Docs/Screenshots/main.PNG" width="25%" alt="main screen"> <img src="Docs/Screenshots/main.PNG" width="25%" alt="main screen">

### Scan
`MainViewController.swift`: 

### List of items
`View ItemVCs/ChecklistViewController2.swift`

`View ItemVCs/ItemAttrAndInfoVC.swift`

### Communication with the server
`Model/HTTPController.swift`

### Logging
`Utilities/Log.swift`

## Publications
Under review

## Contact
Jonggi Hong <jhong12@umd.edu>

Ernest Essuah Mensah <ernest.mensah27@icloud.com>