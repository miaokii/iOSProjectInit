//
//  AttachmentFilePicker.swift
//  RXCSaaS
//
//  Created by yoctech on 2024/1/8.
//

import UIKit
import UniformTypeIdentifiers
import SafariServices

typealias FilePickerCallBack = (([(fileName:String, data:Data)])->Void)

class AttachmentFilePicker: NSObject, UIDocumentPickerDelegate {
    private static let shared = AttachmentFilePicker()
    /// 文件数
    private var count = 1
    /// 从哪里弹出
    private var fromController: UIViewController? = nil
    /// 回调
    private var filePickCallBack:FilePickerCallBack?

    private lazy var documentPicker: UIDocumentPickerViewController! = {
        let types = allUTITypes
        let picker = UIDocumentPickerViewController.init(forOpeningContentTypes: types, asCopy: true)
        picker.delegate = self
        return picker
    }()

    static func pickFile(from: UIViewController?, count: Int = 1, callback: FilePickerCallBack?) {
        shared.fromController = from
        shared.documentPicker.allowsMultipleSelection = count > 1
        shared.filePickCallBack = callback
        shared.documentPicker.modalPresentationStyle = .overFullScreen
        from?.present(shared.documentPicker, animated: true)
    }

    // MARK: - 存储到沙盒
    private func storeFile(urls: [URL]) {
        guard urls.notEmpty else {
            return
        }
        
        var fileDatas = [(String, Data)]()
        
        for url in urls {
            let fileCoordinator = NSFileCoordinator.init()
            var errorPointer: AutoreleasingUnsafeMutablePointer<NSError?>?
            fileCoordinator.coordinate(readingItemAt: url, error: errorPointer) { newUrl in
                let fileName = newUrl.lastPathComponent
                if let fileData = try? NSData.init(contentsOf: newUrl, options: .mappedIfSafe) {
                    fileDatas.append((fileName, fileData as Data))
                }
            }
        }
        filePickCallBack?(fileDatas)
    }
    
    // MARK: - 预览附件
    static func interactionAttachmentFile(url: URL, fromController: UIViewController) {
        shared.fromController = fromController
//        let controller = UIDocumentInteractionController.init(url: url)
//        controller.delegate = shared
//        controller.presentPreview(animated: true)
//        let webView = MKWebviewController.init()
//        webView.url = url
//        shared.fromController?.push(vc: webView)
        
        let vc = SFSafariViewController.init(url: url)
        shared.fromController?.present(vc, animated: true)
    }

    // MARK: - UIDocumentPickerDelegate
    /// 选中附件
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        storeFile(urls: urls)
        fromController = nil
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("取消选择附件")
        filePickCallBack = nil
        fromController = nil
    }
}

extension AttachmentFilePicker: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        fromController ?? kWindow.topController!
    }
    
    func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
        (fromController ?? kWindow.topController)?.view
    }
    
    func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
        (fromController ?? kWindow.topController)?.view.frame ?? UIScreen.main.bounds
    }
    
    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        fromController = nil
    }
}

fileprivate extension AttachmentFilePicker {
var allUTITypes: [UTType] {
    let types : [UTType] =
                [.item,
     .content,
     .compositeContent,
     .diskImage,
     .data,
     .directory,
     .resolvable,
     .symbolicLink,
     .executable,
     .mountPoint,
     .aliasFile,
     .urlBookmarkData,
     .url,
     .fileURL,
     .text,
     .plainText,
     .utf8PlainText,
     .utf16ExternalPlainText,
     .utf16PlainText,
     .delimitedText,
     .commaSeparatedText,
     .tabSeparatedText,
     .utf8TabSeparatedText,
     .rtf,
     .html,
     .xml,
     .yaml,
     .sourceCode,
     .assemblyLanguageSource,
     .cSource,
     .objectiveCSource,
     .swiftSource,
     .cPlusPlusSource,
     .objectiveCPlusPlusSource,
     .cHeader,
     .cPlusPlusHeader]
    
    let types_1: [UTType] =
    [.script,
     .appleScript,
     .osaScript,
     .osaScriptBundle,
     .javaScript,
     .shellScript,
     .perlScript,
     .pythonScript,
     .rubyScript,
     .phpScript,
     .json,
     .propertyList,
     .xmlPropertyList,
     .binaryPropertyList,
     .pdf,
     .rtfd,
     .flatRTFD,
     .webArchive,
     .image,
     .jpeg,
     .tiff,
     .gif,
     .png,
     .icns,
     .bmp,
     .ico,
     .rawImage,
     .svg,
     .livePhoto,
     .heif,
     .heic,
     .webP,
     .threeDContent,
     .usd,
     .usdz,
     .realityFile,
     .sceneKitScene,
     .arReferenceObject,
     .audiovisualContent]
    
    let types_2: [UTType] =
    [.movie,
     .video,
     .audio,
     .quickTimeMovie,
     UTType("com.apple.quicktime-image"),
     .mpeg,
     .mpeg2Video,
     .mpeg2TransportStream,
     .mp3,
     .mpeg4Movie,
     .mpeg4Audio,
     .appleProtectedMPEG4Audio,
     .appleProtectedMPEG4Video,
     .avi,
     .aiff,
     .wav,
     .midi,
     .playlist,
     .m3uPlaylist,
     .folder,
     .volume,
     .package,
     .bundle,
     .pluginBundle,
     .spotlightImporter,
     .quickLookGenerator,
     .xpcService,
     .framework,
     .application,
     .applicationBundle,
     .applicationExtension,
     .unixExecutable,
     .exe,
     .systemPreferencesPane,
     .archive,
     .gzip,
     .bz2,
     .zip,
     .appleArchive,
     .spreadsheet,
     .presentation,
     .database,
     .message,
     .contact,
     .vCard,
     .toDoItem,
     .calendarEvent,
     .emailMessage,
     .internetLocation,
     .internetShortcut,
     .font,
     .bookmark,
     .pkcs12,
     .x509Certificate,
     .epub,
     .log]
        .compactMap({ $0 })
    
    return types + types_1 + types_2
}
}
