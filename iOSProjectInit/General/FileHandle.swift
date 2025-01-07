//
//  FileHandle.swift
//  RXCSaaS
//
//  Created by yoctech on 2024/1/16.
//

import UIKit
import SKPhotoBrowser
import Kingfisher

class FileHandle: NSObject {

    static let shared = FileHandle()
    
    fileprivate var images = [Any]()
    
    static func browser(images: [Any], index: Int) {
        
        var photos = [SKPhoto]()
        
        if let images = images as? [UIImage] {
            photos = images.map{ SKPhoto.photoWithImage($0) }
        }
        else if let urls = images as? [String] {
            photos = urls.compactMap{ ossFullUrl($0) }.map{ SKPhoto.photoWithImageURL($0.absoluteString) }
        }
        
        guard photos.count > 0 else {
            return
        }
        
        shared.images = images
        
        photos.forEach{ $0.shouldCachePhotoURLImage = true }
        
        SKPhotoBrowserOptions.displayStatusbar = true
        SKPhotoBrowserOptions.displayHorizontalScrollIndicator = false
        SKPhotoBrowserOptions.displayVerticalScrollIndicator = false
        SKPhotoBrowserOptions.displayCounterLabel = true
        SKPhotoBrowserOptions.displayPagingHorizontalScrollIndicator = true
        SKPhotoBrowserOptions.displayAction = true
        SKPhotoBrowserOptions.actionButtonTitles = ["保存"]
        SKPhotoBrowserOptions.swapCloseAndDeleteButtons = true
        SKPhotoBrowserOptions.displayBackAndForwardButton = true
        let browser = SKPhotoBrowser.init(photos: photos, initialPageIndex: index)
        browser.delegate = shared
        kAppDelegate.present(controller: browser, presentationStyle: .overFullScreen)
    }
}

extension FileHandle: SKPhotoBrowserDelegate {
    func didDismissActionSheetWithButtonIndex(_ buttonIndex: Int, photoIndex: Int) {
        guard images.notEmpty else {
            return
        }
        
        let image = images[photoIndex]
        if let image = image as? UIImage {
            image.saveToAlbum()
        }
        else if let path = image as? String, let url = ossFullUrl(path) {
            ImageDownloader.default.downloadImage(with: url) { imageResult in
                switch imageResult {
                case .success(let result):
                    result.image.saveToAlbum()
                case .failure(let error):
                    HUD.flash(error: error)
                }
            }
        }
    }
    
    func didDismissAtPageIndex(_ index: Int) {
        images.removeAll()
    }
}
