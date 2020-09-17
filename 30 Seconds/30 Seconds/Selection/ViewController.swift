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
import Photos

class ViewController: UIViewController, SelectionActionProtocol {
    private var viewmodel: SelectionModelProtocol
    private let lblVideoDuration = UILabel()
    private let lblTrimmedDuration = UILabel()
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
        
        view.addSubview(lblTrimmedDuration)
        lblTrimmedDuration.alpha = 0.0
        lblTrimmedDuration.snp.makeConstraints { (make) in
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
        lblTrimmedDuration.alpha = 0.0
        videoUrl = nil
    }
    
    fileprivate func showVideoProperties(){
        guard let url = videoUrl else {return}
        let duration = viewmodel.getDuration(url)
        lblVideoDuration.text = "Video duration: \(duration) seconds"
        lblVideoDuration.alpha = 1.0
        btnPlay.alpha = 1.0
        if duration > 30.0 {
            self.viewmodel.trimVideo(url, start: 0, end: 30.0)
        }
        
    }
    
    func afterTrimmed(_ url: URL?) {
        guard let trimmedUrl = url else {
            self.popupAlert(title: "Error", msg: "We got error when try to trim the video. Please try again", action: nil)
            return
        }
        self.videoUrl = trimmedUrl
        DispatchQueue.main.async {
            self.separator.alpha = 1.0
            let duration = self.viewmodel.getDuration(trimmedUrl)
            self.lblTrimmedDuration.text = "Trimmed duration: \(duration) seconds"
            self.lblTrimmedDuration.alpha = 1.0
            self.popupAlert(title: "Video Trimmed!", msg: "Your video has been trimmed to 30 seconds. Play the video?", action: UIAlertAction(title: "Yes", style: .default, handler: { [weak self] (action) in
                self?.didTapPlay(nil)
            }))
        }
    }
    
    @objc func didTapPlay(_ sender: UIButton?){
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
            self?.photoLibraryPermission(type: .album)
        }))
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] (action) in
            print("Camera")
            self?.photoLibraryPermission(type: .record)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openMedia(type:Type){
        if type == .album {
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                hideVideoProperties()
                picker.sourceType = .savedPhotosAlbum
                picker.mediaTypes = ["public.movie"]
                self.present(picker, animated: true, completion: nil)
            }else {
                popupAlert(title: "Error", msg: "We have trouble when open your Photo Library", action: nil)
            }
        }else {
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                hideVideoProperties()
                picker.sourceType = .camera
                picker.mediaTypes = ["public.movie"]
                picker.videoMaximumDuration = 30
                self.present(picker, animated: true, completion: nil)
            }else {
                popupAlert(title: "Error", msg: "We have trouble when open your Camera", action: nil)
            }
        }
    }
    
    func cameraPermission(){
        let videoPermission = AVCaptureDevice.authorizationStatus(for: .video)
        let audioPermission = AVCaptureDevice.authorizationStatus(for: .audio)
        if videoPermission == .denied || audioPermission == .denied {
            permissionDeniedHandler()
        }else {
            openMedia(type: .record)
        }
    }
    
    func photoLibraryPermission(type:Type){
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            if type == .album {
                openMedia(type: type)
            }else {
                cameraPermission()
            }
            break
        case .denied:
            permissionDeniedHandler()
            break
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] (newStatus) in
                if newStatus == .authorized {
                    DispatchQueue.main.async {
                        if type == .album {
                            self?.openMedia(type: type)
                        }else {
                            self?.cameraPermission()
                        }
                    }
                }
            }
            break
        default:
            break
        }
    }
    
    private func permissionDeniedHandler(){
        popupAlert(title: "Permission denied", msg: "Please open your setting to give us permission before use this feature", action: UIAlertAction(title: "Settings", style: .default, handler: { (action) in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)")
                })
            }
        }))
    }
    
    func popupAlert(title:String?, msg:String, action:UIAlertAction?){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        if let newAction = action {
            alert.addAction(newAction)
        }
        present(alert, animated: true, completion: nil)
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
