//
//  ViewController.swift
//  30 Seconds
//
//  Created by Dwi Putra on 16/09/20.
//  Copyright © 2020 Dwi Putra. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation
//impo

class ViewController: UIViewController, SelectionActionProtocol {
    private var viewmodel: SelectionModelProtocol
    fileprivate let lblVideoSize = UILabel()
    fileprivate let lblVideoDuration = UILabel()
    fileprivate var videoData = Data()
    fileprivate var videoUrl:URL?
    
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
        self.title = "30 Seconds"
        
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
        
        view.addSubview(lblVideoSize)
        lblVideoSize.alpha = 0.0
        lblVideoSize.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(20)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(20)
        }
        
        view.addSubview(lblVideoDuration)
        lblVideoDuration.alpha = 0.0
        lblVideoDuration.snp.makeConstraints { (make) in
            make.top.equalTo(lblVideoSize.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(20)
            
        }
    }
    
    fileprivate func showVideoProperties(){
        let size = Double(videoData.count / 1048576)
        lblVideoSize.text = "File size: \(size) MB"
        lblVideoSize.alpha = 1.0
        
        if let url = videoUrl {
            let asset = AVAsset(url: url)
            let duration = asset.duration
            let durationTime = CMTimeGetSeconds(duration)
            let rounded = Double(round(durationTime*100)/100)
            lblVideoDuration.text = "Video duration: \(rounded) seconds"
            lblVideoDuration.alpha = 1.0
        }
        
        
    }
    
    @objc func didTapSelection(_ sender: UIButton){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Album", style: .default, handler: { [weak self] (action) in
            print("Album")
            self?.openAlbum()
        }))
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] (action) in
            print("Camera")
            self?.viewmodel.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openAlbum(){
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .savedPhotosAlbum
            picker.mediaTypes = ["public.movie"]
            self.present(picker, animated: true, completion: nil)
        }else {
            
        }
    }
}


extension ViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        if let videoURL = videoUrl {
            do {
                self.videoData = try Data(contentsOf: videoURL)
                self.showVideoProperties()
                
                
            }catch {
                
            }
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
}
