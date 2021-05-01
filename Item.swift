//
//  Item.swift
//  CheckList app
//
//  Created by Jonggi Hong on 4/22/19.
//  Copyright © 2019 Jaina Gandhi. All rights reserved.
//

import Foundation

class Item {
    let itemName: String
    let itemDate: String
    let relativeDate: String
    let date: Date // This is for sorting the items according to the time they were taken
    //let image: String
    init( itemName: String, itemDate: String, relativeDate: String, date: Date, image: String){
        self.itemName = itemName
        self.itemDate = itemDate
        self.relativeDate = relativeDate
        self.date = date
        //self.image = image
    }
}
