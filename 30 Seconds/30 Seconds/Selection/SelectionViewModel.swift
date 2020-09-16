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
    
}

protocol SelectionActionProtocol {
    
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

        //Remove existing file
        try? fileManager.removeItem(at: outputURL)

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
                var localId:String?
                PHPhotoLibrary.shared().performChanges({
                    let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
                    localId = request?.placeholderForCreatedAsset?.localIdentifier
                }) { saved, error in
                    if saved {
                        if let localId = localId {

                            let result = PHAsset.fetchAssets(withLocalIdentifiers: [localId], options: nil).firstObject
                            print("duration: \(result?.duration)")
                            print("size: \(result?.fileSize)")
                            result?.getURL(completionHandler: { (url) in
                                try? fileManager.removeItem(at: outputURL)
                                completion(url)
                            })
                            
                            
//                            let assets = result.objectsAtIndexes(NSIndexSet(indexesInRange: NSRange(location: 0, length: result.count)) as IndexSet) as? [PHAsset] ?? []

//                            if let asset = assets.first {
//                                // Do something with result
//                            }
                        }else {
                            completion(nil)
                        }
                        
                        /*
                        let fetchOptions = PHFetchOptions()
                        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

                        let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).firstObject
                        // fetchResult is your latest video PHAsset
                        // To fetch latest image  replace .video with .image
                        print("duration: \(fetchResult?.duration)")
                        print("size: \(fetchResult?.fileSize)")
                        fetchResult?.getURL(completionHandler: { (url) in
                            completion(url)
                        })*/
                    }else {
                        completion(nil)
                    }
                }
//
//                completion(outputURL)
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
    
}
