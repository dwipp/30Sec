//
//  SelectionViewModel.swift
//  30 Seconds
//
//  Created by Dwi Putra on 16/09/20.
//  Copyright © 2020 Dwi Putra. All rights reserved.
//

import UIKit

protocol SelectionModelProtocol {
    var action:SelectionActionProtocol? {get set}
    func openCamera()
    func openAlbum()
}

protocol SelectionActionProtocol {
    
}

class SelectionViewModel: SelectionModelProtocol {
    var action: SelectionActionProtocol?
    
    func openCamera() {
        
    }
    
    func openAlbum() {
        
    }
    
}
