//
//  Person.swift
//  Project10
//
//  Created by iMac on 25.02.2021.
//

import UIKit

class Person: NSObject, Codable {
    
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }

}
