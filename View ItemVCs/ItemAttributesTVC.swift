//
//  ItemAttributesTVC.swift
//  CheckList app
//
//  Created by Ernest Essuah Mensah on 10/7/20.
//  Copyright © 2020 Jaina Gandhi. All rights reserved.
//

import UIKit

class ItemAttributesTVC: UITableViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var objectImageView: UIImageView!
    @IBOutlet weak var objectNameLabel: UILabel!
    @IBOutlet weak var proceedButton: UIButton!
    var httpController = HTTPController()
    
    var var_attributes = ["Background variation", "Side variation", "Distance variation"]
    var attributes = ["Hand in image", "Cropped", "Blurry", "Small"]
    var item: Item?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        navigationItem.titleView = Functions.createHeaderView(title: "")
        tableView.delaysContentTouches = false
        proceedButton.roundButton(withBackgroundColor: .clear, opacity: 0)
    }
    
    var backgroundVariation = "N/A"
    var sideVariation = "N/A"
    var distanceVariation = "N/A"
    var cnt_hand = 0
    var cnt_blurry = 0
    var cnt_crop = 0
    var cnt_small = 0
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .white
        
        if let item = item {
            
            let name = Functions.separateWords(name: item.itemName)
            objectNameLabel.text = name
            
            let imgPath = Util().userDirectory.appendingPathComponent("\(item.itemName)/1.jpg")
            //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            if let data = try? Data(contentsOf: imgPath) {
                objectImageView.image = UIImage(data: data)
            }
            objectImageView.layer.cornerRadius = 12
            
            httpController.getSetDescriptor(obj_name: name) { (response) in
                print(response)
                let output_components = response.components(separatedBy: ",")
                if output_components.count != 7 {
                    print("The response is not valid. Response: \"\(response)\"...\(output_components.count)")
                } else {
                    self.backgroundVariation = output_components[0]=="True" ? "Yes": "No"
                    self.sideVariation = output_components[1]=="True" ? "Yes": "No"
                    self.distanceVariation = output_components[2]=="True" ? "Yes": "No"
                    self.cnt_hand = Int(output_components[3])!
                    self.cnt_blurry = Int(output_components[4])!
                    self.cnt_crop = Int(output_components[5])!
                    self.cnt_small = Int(output_components[6])!
                    
                    print("\(self.backgroundVariation), \(self.sideVariation), \(self.distanceVariation)")
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 1
        } else if section == 1 {
            return var_attributes.count
        }
        
        return attributes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = SwitchTableViewCell()
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "attributesCell", for: indexPath) as! ItemAttributeTableViewCell

        // Configure the cell...
        if indexPath.section == 1 {
            cell.attributeLabel.text = var_attributes[indexPath.row]
        } else if indexPath.section == 2 {
            cell.attributeLabel.text = attributes[indexPath.row]
        }
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell.level.text = backgroundVariation
            } else if indexPath.row == 1 {
                cell.level.text = sideVariation
            } else if indexPath.row == 2 {
                cell.level.text = distanceVariation
            }
        }
        else if indexPath.section == 2 {
            if indexPath.row == 0 {
                cell.level.text = "\(cnt_hand) out of 30"
            } else if indexPath.row == 1 {
                cell.level.text = "\(cnt_blurry) out of 30"
            } else if indexPath.row == 2 {
                cell.level.text = "\(cnt_crop) out of 30"
            } else if indexPath.row == 3 {
                cell.level.text = "\(cnt_small) out of 30"
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 32))
        headerView.roundButton(withBackgroundColor: .clear, opacity: 0.2)
        
        let headerLabel = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.width, height: 40))
        
        if section == 0 {
            headerLabel.text = "VOICEOVER"
        } else if section == 1 {
           headerLabel.text = "GROUP-LEVEL ATTRIBUTES"
        } else {
            headerLabel.text = "PHOTO-LEVEL ATTRIBUTES"
        }
        
        headerLabel.textColor = .lightGray
        headerLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        headerLabel.textAlignment = .left
        
        headerView.addSubview(headerLabel)
        return headerView
    }
    

    @IBAction func handleProceedButtonTapped(_ sender: UIButton) {
        let vc = ItemAudioVC()
        vc.objectName = item?.itemName ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

}


class ItemAttributeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var attributeLabel: UILabel!
    @IBOutlet weak var level: UILabel!
    
}


class SwitchTableViewCell: UITableViewCell {
    
    var verbositySwitch = UISwitch()
    
    
    func setup() {
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 24))
        label.text = "Verbose"
        label.textColor = .darkGray
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        label.textAlignment = .left
        
        self.contentView.setupView(viewToAdd: label, leadingView: self.contentView, shouldSwitchLeading: false, leadingConstant: 24, trailingView: nil, shouldSwitchTrailing: false, trailingConstant: 0, topView: self.contentView, shouldSwitchTop: false, topConstant: 0, bottomView: self.contentView, shouldSwitchBottom: false, bottomConstant: 0)
        
        self.contentView.setupView(viewToAdd: verbositySwitch, leadingView: nil, shouldSwitchLeading: false, leadingConstant: 0, trailingView: self.contentView, shouldSwitchTrailing: false, trailingConstant: -16, topView: self.contentView, shouldSwitchTop: false, topConstant: 8, bottomView: self.contentView, shouldSwitchBottom: false, bottomConstant: 8)
    }
    
    override func layoutSubviews() {
        self.contentView.backgroundColor = .white
        setup()
        
    }
}
