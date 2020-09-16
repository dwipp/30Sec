//
//  Extenstions.swift
//  30 Seconds
//
//  Created by Dwi Putra on 17/09/20.
//  Copyright © 2020 Dwi Putra. All rights reserved.
//

import Foundation
import Photos
import UIKit

extension PHAsset {
    var fileSize: Double {
        get {
            let resource = PHAssetResource.assetResources(for: self)
            let imageSizeByte = resource.first?.value(forKey: "fileSize") as? Double ?? 0
            let imageSizeMB = imageSizeByte / (1024.0*1024.0)
            return imageSizeMB
        }
    }
    
    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
}

extension UIButton {
    func inStyle(){
        self.setTitleColor(.systemBlue, for: .normal)
        self.layer.cornerRadius = 8
        self.layer.borderColor = UIColor.systemBlue.cgColor
        self.layer.borderWidth = 1
    }
}
