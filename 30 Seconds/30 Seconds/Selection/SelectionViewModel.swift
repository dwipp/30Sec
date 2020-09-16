//
//  SelectionViewModel.swift
//  30 Seconds
//
//  Created by Dwi Putra on 16/09/20.
//  Copyright © 2020 Dwi Putra. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

protocol SelectionModelProtocol {
    var action:SelectionActionProtocol? {get set}
    func cropVideo(_ videoUrl:URL, start:Double, end:Double, completion:@escaping (URL?)->())
    func getDuration(_ videoUrl:URL) -> Double
    func saveToPhotoLibrary(_ outputURL:URL, type:Type, completion:@escaping (URL?)->())
}

protocol SelectionActionProtocol {
    
}

enum Type {
    case record
    case album
}

class SelectionViewModel: SelectionModelProtocol {
    var action: SelectionActionProtocol?
    
    func cropVideo(_ videoUrl: URL, start: Double, end: Double, completion:@escaping (URL?) -> ()) {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]

        let asset = AVAsset(url: videoUrl)
        let length = Float(asset.duration.value) / Float(asset.duration.timescale)
        print("video length: \(length) seconds")

        var outputURL = documentDirectory.appendingPathComponent("output")
        do {
            try fileManager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            outputURL = outputURL.appendingPathComponent("\(videoUrl.lastPathComponent).mov")
        }catch let error {
            print(error)
            completion(nil)
        }

        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mov

        let timeRange = CMTimeRange(start: CMTime(seconds: start, preferredTimescale: 1000),
                                    end: CMTime(seconds: end, preferredTimescale: 1000))

        exportSession.timeRange = timeRange
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                print("exported at \(outputURL)")
                self.saveToPhotoLibrary(outputURL, type: .album) { (url) in
                    completion(url)
                }
            case .failed:
                print("failed \(exportSession.error.debugDescription)")
                completion(nil)
            case .cancelled:
                print("cancelled \(exportSession.error.debugDescription)")
                completion(nil)
            default:
                completion(nil)
                break
            }
        }
    }
    
    func saveToPhotoLibrary(_ outputURL:URL, type:Type, completion:@escaping (URL?)->()){
        var localId:String?
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
            localId = request?.placeholderForCreatedAsset?.localIdentifier
        }) { saved, error in
            if saved {
                if let localId = localId {
                    let result = PHAsset.fetchAssets(withLocalIdentifiers: [localId], options: nil).firstObject
                    result?.getURL(completionHandler: { (url) in
                        if type == .album {
                            try? FileManager.default.removeItem(at: outputURL)
                        }
                        completion(url)
                    })
                }else {
                    completion(nil)
                }
            }else {
                completion(nil)
            }
        }
    }
    
    func getDuration(_ videoUrl: URL) -> Double {
        let asset = AVAsset(url: videoUrl)
        let duration = asset.duration
        let durationTime = CMTimeGetSeconds(duration)
        let rounded = Double(round(durationTime*100)/100)
        return rounded
    }
    
}
