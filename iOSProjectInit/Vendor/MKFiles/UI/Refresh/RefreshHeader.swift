//
//  RefreshHeader.swift
//  DoctorProject
//
//  Created by Ly on 2020/8/24.
//  Copyright © 2020 Ly. All rights reserved.
//

import UIKit
import MJRefresh

class RefreshHeader: MJRefreshNormalHeader {
    /**
     * 重写父类prepare方法
     * 做一个初始化配置，比如添加子控件
     */
    override func prepare() {
        super.prepare()
        // 设置高度
        mj_h = 60
        lastUpdatedTimeLabel?.isHidden = true
        arrowView?.image = nil
        labelLeftInset = 15
        loadingView?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
    override var state: MJRefreshState {
        didSet {
            switch state {
            case .idle:
                stateLabel?.text = "下拉刷新"
            case .willRefresh:
                stateLabel?.text = "即将刷新"
            case .pulling:
                stateLabel?.text = "松开刷新"
            case .refreshing:
                stateLabel?.text = "正在刷新"
            default:
                break
            }
            
            if state == .refreshing {
                loadingView?.startAnimating()
            } else {
                loadingView?.stopAnimating()
            }
        }
    }
    
    var stateColor: UIColor! {
        didSet {
            stateLabel?.textColor = stateColor
            loadingView?.color = stateColor
        }
    }
}
