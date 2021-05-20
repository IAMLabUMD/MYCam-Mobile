//
//  ReviewTrainingVC.swift
//  TOR-Mobile
//
//  Created by Jonggi Hong on 3/8/21.
//  Copyright © 2021 Jaina Gandhi. All rights reserved.
//

import Foundation

class ReviewTrainingVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var objectImageView: UIImageView!
    @IBOutlet weak var objectNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var item: Item?
    
    var attributes = ["Background variation", "Side variation", "Distance variation", "Small object", "Cropped object", "Blurry", "Hand in image"]
//    var var_attributes = ["Background variation", "Side variation", "Distance variation"]
    
    var backgroundVariation = 0.0
    var sideVariation = 0.0
    var distanceVariation = 0.0
    var cnt_hand = 0
    var cnt_blurry = 0
    var cnt_crop = 0
    var cnt_small = 0
    var verbose = true
    var train_id: String?
    
    var httpController = HTTPController()
    var switchCell = SwitchTableViewCellRT()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Log.writeToLog("\(Actions.enteredScreen.rawValue) \(Screens.reviewScreen.rawValue)")
        
        if let item = item {
            switchCell.initCell()
            switchCell.myView = self
            
            _ = Functions.separateWords(name: item.itemName)
            objectNameLabel.text = "Training quality"
            
            
            let imgPath = Log.userDirectory.appendingPathComponent("tmpobj/1.jpg")
            if let data = try? Data(contentsOf: imgPath) {
                objectImageView.image = UIImage(data: data)
            }
            
            objectImageView.layer.cornerRadius = 12
            objectNameLabel.font = .rounded(ofSize: 21, weight: .bold)
            
            httpController.getSetDescriptorForReview (train_id: train_id!) { (response) in
                print(response)
                let output_components = response.components(separatedBy: ",")
                if output_components.count != 7 {
                    print("The response is not valid. Response: \"\(response)\"...\(output_components.count)")
                } else {
                    self.backgroundVariation = Double(output_components[0])!
                    self.sideVariation = Double(output_components[1])!
                    self.distanceVariation = Double(output_components[2])!
                    self.cnt_hand = Int(output_components[3])!
                    self.cnt_blurry = Int(output_components[4])!
                    self.cnt_crop = Int(output_components[5])!
                    self.cnt_small = Int(output_components[6])!

                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.layer.cornerRadius = 12
        tableView.backgroundColor = .white
        tableView.tableFooterView = UIView()
        view.backgroundColor = .themeBackground
        objectImageView.layer.cornerRadius = 12
        objectImageView.layer.masksToBounds = true
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, objectNameLabel)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Log.writeToLog("\(Actions.exitedScreen.rawValue) \(Screens.reviewScreen.rawValue)")
    }
    
    @IBAction func OKButtonAction(_ sender: Any) {
        let vc = TrainingVC()
        vc.train_id = train_id
        vc.objectName = "tmpobj"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func RetrainButtonAction(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc
    func handleNextButton() {
        let vc = ItemAudioVC()
        vc.objectName = item?.itemName ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return attributes.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
//            let cell = SwitchTableViewCell()
            
            return switchCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "attributesCell", for: indexPath) as! ItemAttributeTableViewCellRT

        // Configure the cell...
        if indexPath.section == 1 {
            cell.attributeLabel.text = attributes[indexPath.row]
        }
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                let varVal = min(backgroundVariation/0.15*100, 100)
                if ReviewTrainingVC.VERBOSITY == ReviewTrainingVC.verbosityLevels[0] {
                    cell.level.text = String(format: "%.1f%%", varVal)
                } else if ReviewTrainingVC.VERBOSITY == ReviewTrainingVC.verbosityLevels[1] {
                    if varVal >= 75 {
                        cell.level.text = "High"
                    } else if varVal >= 25 {
                        cell.level.text = "Medium"
                    } else {
                        cell.level.text = "Low"
                    }
                } else {
                    cell.level.text = backgroundVariation > 0.1 ? "High": "Low"
                }

            } else if indexPath.row == 1 {
                let varVal = min(sideVariation*0.15*100, 100)
                if ReviewTrainingVC.VERBOSITY == ReviewTrainingVC.verbosityLevels[0] {
                    cell.level.text = String(format: "%.1f%%", varVal)
                } else if ReviewTrainingVC.VERBOSITY == ReviewTrainingVC.verbosityLevels[1] {
                    if varVal >= 75 {
                        cell.level.text = "High"
                    } else if varVal >= 25 {
                        cell.level.text = "Medium"
                    } else {
                        cell.level.text = "Low"
                    }
                } else {
                    cell.level.text = sideVariation > 1 ? "High": "Low"
                }

            } else if indexPath.row == 2 {

                let varVal = min(distanceVariation/0.15*100, 100)
                if ReviewTrainingVC.VERBOSITY == ReviewTrainingVC.verbosityLevels[0] {
                    cell.level.text = String(format: "%.1f%%", varVal)
                } else if ReviewTrainingVC.VERBOSITY == ReviewTrainingVC.verbosityLevels[1] {
                    if varVal >= 75 {
                        cell.level.text = "High"
                    } else if varVal >= 25 {
                        cell.level.text = "Medium"
                    } else {
                        cell.level.text = "Low"
                    }
                } else {
                    cell.level.text = distanceVariation > 0.1 ? "High": "Low"
                }
            } else if indexPath.row == 3 {
                if ReviewTrainingVC.VERBOSITY == ReviewTrainingVC.verbosityLevels[0] {
                    cell.level.text = "\(cnt_small) out of 30"
                } else if ReviewTrainingVC.VERBOSITY == ReviewTrainingVC.verbosityLevels[1] {
                    if cnt_small >= 20 {
                        cell.level.text = "High"
                    } else if cnt_small >= 6 {
                        cell.level.text = "Medium"
                    } else {
                        cell.level.text = "Low"
                    }
                } else {
                    cell.level.text = cnt_small > 5 ? "High": "Low"
                }
                
            } else if indexPath.row == 4 {
                if ReviewTrainingVC.VERBOSITY == ReviewTrainingVC.verbosityLevels[0] {
                    cell.level.text = "\(cnt_crop) out of 30"
                } else if ReviewTrainingVC.VERBOSITY == ReviewTrainingVC.verbosityLevels[1] {
                    if cnt_crop >= 20 {
                        cell.level.text = "High"
                    } else if cnt_crop >= 6 {
                        cell.level.text = "Medium"
                    } else {
                        cell.level.text = "Low"
                    }
                } else {
                    cell.level.text = cnt_crop > 5 ? "High": "Low"
                }
                
            } else if indexPath.row == 5 {
                if ReviewTrainingVC.VERBOSITY == ReviewTrainingVC.verbosityLevels[0] {
                    cell.level.text = "\(cnt_blurry) out of 30"
                } else if ReviewTrainingVC.VERBOSITY == ReviewTrainingVC.verbosityLevels[1] {
                    if cnt_blurry >= 20 {
                        cell.level.text = "High"
                    } else if cnt_blurry >= 6 {
                        cell.level.text = "Medium"
                    } else {
                        cell.level.text = "Low"
                    }
                } else {
                    cell.level.text = cnt_blurry > 5 ? "High": "Low"
                }
                
            } else if indexPath.row == 6 {
                
                if ReviewTrainingVC.VERBOSITY == ReviewTrainingVC.verbosityLevels[0] {
                    cell.level.text = "\(cnt_hand) out of 30"
                } else if ReviewTrainingVC.VERBOSITY == ReviewTrainingVC.verbosityLevels[1] {
                    if cnt_hand >= 20 {
                        cell.level.text = "High"
                    } else if cnt_hand >= 6 {
                        cell.level.text = "Medium"
                    } else {
                        cell.level.text = "Low"
                    }
                } else {
                    cell.level.text = cnt_hand > 5 ? "High": "Low"
                }
            }
        }

        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 77
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 72))
        headerView.backgroundColor = .themeBackground
        
        let headerLabel = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.width, height: 40))
        
        if section == 0 {
            headerLabel.text = "Verbosity"
        } else if section == 1 {
            headerLabel.text = "Attributes"
        }
        
        headerLabel.textColor = .darkGray
        headerLabel.font = .rounded(ofSize: 16, weight: .heavy)
        headerLabel.textAlignment = .left
        
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    static let verbosityLevels = ["Percentage", "Intensity", "Severity"]
    static var VERBOSITY = "Percentage"
    func updateVerbosity(v: String) {
        ReviewTrainingVC.VERBOSITY = v
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}




class ItemAttributeTableViewCellRT: UITableViewCell {
    
    @IBOutlet weak var attributeLabel: UILabel!
    @IBOutlet weak var level: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        attributeLabel.font = .rounded(ofSize: 16, weight: .bold)
        attributeLabel.textColor = .darkGray
        
        level.font = .rounded(ofSize: 16, weight: .bold)
        level.textColor = .lightGray
    }
}


class SwitchTableViewCellRT: UITableViewCell {
//    var verbositySwitch = UISwitch()
    var myView: ReviewTrainingVC?
    var verbosityLabel: UILabel!
    
    func initCell() {
        self.contentView.backgroundColor = .white
        verbosityLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 160, height: 24))
        verbosityLabel.text = "Verbosity"
        verbosityLabel.textColor = .darkGray
        verbosityLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        verbosityLabel.textAlignment = .left
        
//        verbositySwitch.isOn = ReviewTrainingVC.VERBOSE
//        verbositySwitch.addTarget(self, action: #selector(switchIsChanged), for: UIControlEvents.valueChanged)
        let verbosityControl = UISegmentedControl(items: ReviewTrainingVC.verbosityLevels)
        verbosityControl.selectedSegmentIndex = 0
        verbosityControl.addTarget(self, action: #selector(verbosityIsChanged), for: UIControlEvents.valueChanged)
        
        self.contentView.setupView(viewToAdd: verbosityLabel, leadingView: self.contentView, shouldSwitchLeading: false, leadingConstant: 24, trailingView: nil, shouldSwitchTrailing: false, trailingConstant: 0, topView: self.contentView, shouldSwitchTop: false, topConstant: 0, bottomView: self.contentView, shouldSwitchBottom: false, bottomConstant: 0)
        
        self.contentView.setupView(viewToAdd: verbosityControl, leadingView: nil, shouldSwitchLeading: false, leadingConstant: 0, trailingView: self.contentView, shouldSwitchTrailing: false, trailingConstant: -20, topView: self.contentView, shouldSwitchTop: false, topConstant: 20, bottomView: nil, shouldSwitchBottom: false, bottomConstant: 0)
    }
    
    func setup() {
    }
    
    @objc func verbosityIsChanged(verbosityControl: UISegmentedControl) {
        myView?.updateVerbosity(v: ReviewTrainingVC.verbosityLevels[verbosityControl.selectedSegmentIndex])
    }
}
