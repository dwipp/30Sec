//
//  ViewController.swift
//  30 Seconds
//
//  Created by Dwi Putra on 16/09/20.
//  Copyright © 2020 Dwi Putra. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController, SelectionActionProtocol {
    private var viewmodel: SelectionModelProtocol
    
    
    init() {
        self.viewmodel = SelectionViewModel()
        super.init(nibName: nil, bundle: nil)
        self.viewmodel.action = self
    }
    
    required init?(coder: NSCoder) {
        self.viewmodel = SelectionViewModel()
        super.init(coder: coder)
        self.viewmodel.action = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup(){
        let btnSelect = UIButton()
        view.addSubview(btnSelect)
        btnSelect.setTitle("Select Video", for: .normal)
        btnSelect.setTitleColor(.systemBlue, for: .normal)
        btnSelect.addTarget(self, action: #selector(self.didTapSelection(_:)), for: .touchUpInside)
        btnSelect.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin).offset(-20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }
    }
    
    @objc func didTapSelection(_ sender: UIButton){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Album", style: .default, handler: { [weak self] (action) in
            print("Album")
            self?.viewmodel.openAlbum()
        }))
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] (action) in
            print("Camera")
            self?.viewmodel.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

