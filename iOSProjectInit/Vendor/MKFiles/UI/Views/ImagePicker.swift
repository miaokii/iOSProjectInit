//
//  ImagePicker.swift
//  SwiftLib
//
//  Created by yoctech on 2023/3/17.
//

import Foundation
import UIKit
import CoreServices
import PhotosUI

typealias ImagePickClosure = ([(image:UIImage, path:String)])->Void

enum ImageSource {
    case camera
    case library
    case both
}

class ImagePicker: NSObject {
    
    fileprivate static let shared = ImagePicker()
    fileprivate var count = 1
    fileprivate weak var formController: UIViewController!
    fileprivate var imagePickedBlock: ImagePickClosure?
    
    // 打开相机
    private func camera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {

            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = ["public.image"]
            imagePicker.modalPresentationStyle = .fullScreen
            kAppDelegate.present(controller: imagePicker)
        }
        else {
            alertAction()
        }
    }
    
    // 打开相册
    private func photoLibrary(){
        
        var configuration = PHPickerConfiguration.init(photoLibrary: .shared())
        configuration.selectionLimit = count
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen
        kAppDelegate.present(controller: picker)
    }
    
    // 错误提示
    private func alertAction(){
        let alertController = UIAlertController(title: "错误", message: "设备不支持", preferredStyle: UIAlertController.Style.actionSheet)
        let action = UIAlertAction(title: "确定", style: .cancel, handler: nil)
        alertController.addAction(action)
        kAppDelegate.present(controller: alertController)
    }
}

extension ImagePicker {
    /// 弹出选择
    /// - Parameters:
    ///   - vc: 从次vc弹出
    ///   - count: 选择数量
    ///   - source: 来源
    ///   - pickedComplete: 回调
    static func pickImage(count: Int = 1, source: ImageSource = .both, pickedComplete: @escaping ImagePickClosure){
        
        shared.imagePickedBlock = pickedComplete
        shared.count = count
        
        switch source {
        case .both:
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "相机", style: .default, handler: { (alert:UIAlertAction) -> Void in
                shared.camera()
            }))
            actionSheet.addAction(UIAlertAction(title: "相册", style: .default, handler: { (alert:UIAlertAction) -> Void in
                shared.photoLibrary()
            }))
            actionSheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            kWindow.topController?.present(actionSheet, animated: true)
            
        case .camera:
            shared.camera()
        case .library:
            shared.photoLibrary()
        }
    }
}

extension ImagePicker: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard results.count > 0 else {
            imagePickedBlock = nil
            return
        }
        
        let group = DispatchGroup.init()
        var backTrupes = [(UIImage, String)]()
        
        for item in results {
            if (item.itemProvider.canLoadObject(ofClass: UIImage.self)) {
                group.enter()
                item.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    
                    guard let image = image as? UIImage else {
                        group.leave()
                        return
                    }
                    
                    let data = image.jpegData(compressionQuality: image.size.width > 0 ? UIScreen.main.bounds.size.width / image.size.width : 1)
                   
                    let imageName = "\(Date().timeIntervalSince1970).jpg"
                    let imagePath = Sandbox.share.filePath(name: imageName)
                    let write = (data as NSData?)?.write(toFile: imagePath, atomically: false) ?? false
                    
                    if write {
                        backTrupes.append((image, imagePath))
                    }
                    
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            self.imagePickedBlock?(backTrupes)
            self.imagePickedBlock = nil
        }
    }
}

//扩展
extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let originImage = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage else { return }
        
        let data = originImage.jpegData(compressionQuality: originImage.size.width > 0 ? UIScreen.main.bounds.size.width / originImage.size.width : 1)
       
        
        let imageName = "\(Date().timeIntervalSince1970).jpg"
        let imagePath = Sandbox.share.filePath(name: imageName)
        
        let write = (data as NSData?)?.write(toFile: imagePath, atomically: false) ?? false
        
        if write {
            imagePickedBlock?([(originImage, imagePath)])
            imagePickedBlock = nil
        }
        else{
            print("something went wrong")
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
