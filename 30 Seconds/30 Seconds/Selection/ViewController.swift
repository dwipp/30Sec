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
import AVKit

class ViewController: UIViewController, SelectionActionProtocol {
    private var viewmodel: SelectionModelProtocol
    private let lblVideoDuration = UILabel()
    private let lblCroppedDuration = UILabel()
    private let btnPlay = UIButton()
    private let separator = UIView()
    
    fileprivate var videoUrl:URL?
    fileprivate let picker = UIImagePickerController()
    
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
        btnSelect.inStyle()
        btnSelect.addTarget(self, action: #selector(self.didTapSelection(_:)), for: .touchUpInside)
        btnSelect.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin).offset(-20)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(250)
        }
        
        view.addSubview(btnPlay)
        btnPlay.alpha = 0.0
        btnPlay.setTitle("Play", for: .normal)
        btnPlay.inStyle()
        btnPlay.addTarget(self, action: #selector(self.didTapPlay(_:)), for: .touchUpInside)
        btnPlay.snp.makeConstraints { (make) in
            make.right.equalTo(view.safeAreaLayoutGuide.snp.rightMargin).offset(-16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(20)
            make.width.equalTo(80)
            make.height.equalTo(40)
        }
        
        view.addSubview(lblVideoDuration)
        lblVideoDuration.alpha = 0.0
        lblVideoDuration.snp.makeConstraints { (make) in
        make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(20)
            make.right.equalTo(btnPlay.snp.left).offset(-8)
            make.left.equalTo(view.safeAreaLayoutGuide.snp.leftMargin).offset(16)
            make.height.equalTo(20)
            
        }
        
        view.addSubview(separator)
        separator.backgroundColor = .systemGray3
        separator.alpha = 0.0
        separator.snp.makeConstraints { (make) in
            make.top.equalTo(lblVideoDuration.snp.bottom).offset(8)
            make.left.equalTo(view.safeAreaLayoutGuide.snp.leftMargin).offset(16)
            make.right.equalTo(btnPlay.snp.left).offset(-8)
            make.height.equalTo(0.5)
        }
        
        view.addSubview(lblCroppedDuration)
        lblCroppedDuration.alpha = 0.0
        lblCroppedDuration.snp.makeConstraints { (make) in
            make.top.equalTo(separator.snp.bottom).offset(8)
            make.right.equalTo(btnPlay.snp.right).offset(-8)
            make.left.equalTo(view.safeAreaLayoutGuide.snp.leftMargin).offset(16)
            make.height.equalTo(20)
            
        }
        
        picker.delegate = self
    }
    
    private func hideVideoProperties(){
        lblVideoDuration.alpha = 0.0
        btnPlay.alpha = 0.0
        separator.alpha = 0.0
        lblCroppedDuration.alpha = 0.0
        videoUrl = nil
    }
    
    fileprivate func showVideoProperties(){
        guard let url = videoUrl else {return}
        let duration = viewmodel.getDuration(url)
        lblVideoDuration.text = "Video duration: \(duration) seconds"
        lblVideoDuration.alpha = 1.0
        btnPlay.alpha = 1.0
        if duration > 30.0 {
            self.viewmodel.cropVideo(url, start: 0, end: 30.0) { [weak self] (newUrl) in
                guard let croppedUrl = newUrl else {return}
                self?.videoUrl = croppedUrl
                DispatchQueue.main.async {
                    self?.separator.alpha = 1.0
                    let duration = self?.viewmodel.getDuration(croppedUrl) ?? 0
                    self?.lblCroppedDuration.text = "Cropped duration: \(duration) seconds"
                    self?.lblCroppedDuration.alpha = 1.0
                }
            }
        }
        
    }
    
    @objc func didTapPlay(_ sender: UIButton){
        guard let url = videoUrl else {return}
        let player = AVPlayer(url: url)
        let playerController = AVPlayerViewController()
        playerController.player = player
        self.present(playerController, animated: true) {
            player.play()
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
            self?.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openAlbum(){
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            hideVideoProperties()
            picker.sourceType = .savedPhotosAlbum
            picker.mediaTypes = ["public.movie"]
            self.present(picker, animated: true, completion: nil)
        }else {
            
        }
    }
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            hideVideoProperties()
            picker.sourceType = .camera
            picker.mediaTypes = ["public.movie"]
            picker.videoMaximumDuration = 30
            self.present(picker, animated: true, completion: nil)
        }else {
            
        }
    }
}


extension ViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        if picker.sourceType == .camera, let url = videoUrl {
            self.viewmodel.saveToPhotoLibrary(url, type: .record) { [weak self] (savedUrl) in
                DispatchQueue.main.async {
                    self?.videoUrl = savedUrl
                    self?.showVideoProperties()
                }
            }
        }else {
            self.showVideoProperties()
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
