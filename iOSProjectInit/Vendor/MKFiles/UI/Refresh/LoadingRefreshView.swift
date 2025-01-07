//
//  ESLoadingRefreshView.swift
//  RXCSaaS
//
//  Created by yoctech on 2023/11/30.
//

import UIKit
import MJRefresh

class LoadingRefreshView: MJRefreshStateHeader {
    var insets: UIEdgeInsets = .zero
    var view: UIView { self }
    var trigger: CGFloat = 50
    var executeIncremental: CGFloat = 50
    
    override var state: MJRefreshState {
        didSet {
            guard loadingView != nil else {
                return
            }
            
            if state == .idle, loadingView.transform != .identity {
                loadingView.transform = .identity
            }
            if state == .refreshing {
                loadingView.startAnimation()
            } else {
                loadingView.stopAnimation()
            }
        }
    }
    
    private var loadingView: LoadingIndicatorView!
    private var color: UIColor = .theme
    private var loadingType: LoadingIndicatorType = .ballPulse
    
    override func prepare() {
        super.prepare()
        mj_h = 50
        lastUpdatedTimeLabel?.isHidden = true
        stateLabel?.isHidden = true
    }
    
    override func placeSubviews() {
        super.placeSubviews()
        if loadingView == nil {
            let rect = CGRect.init(x: (frame.width-50)/2, y: (frame.height-50)/2, width: 50, height: 50)
            loadingView = LoadingIndicatorView.init(frame: rect, type: loadingType, color: color, padding: 5)
            addSubview(loadingView)
        }
    }
}
