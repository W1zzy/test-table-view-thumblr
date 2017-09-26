//
//  SearchPhotoDatasourceItem.swift
//  TestApplication
//
//  Created by Антон Братчик on 25.09.17.
//  Copyright © 2017 Антон Братчик. All rights reserved.
//

import Foundation
import UIKit

struct SearchPhotoDatasourceItem {
    var photoURL: URL
    var image: UIImage?
    var imageResized: UIImage?
    
    init(photoURL: URL) {
        self.photoURL = photoURL
    }
}
