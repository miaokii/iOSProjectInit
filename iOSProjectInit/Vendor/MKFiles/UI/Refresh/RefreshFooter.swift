//
//  RefreshFooter.swift
//  DoctorProject
//
//  Created by Ly on 2020/8/24.
//  Copyright © 2020 Ly. All rights reserved.
//

import UIKit
import MJRefresh

class RefreshFooter: MJRefreshBackNormalFooter {
    /**
     * 重写父类prepare方法
     * 做一个初始化配置，比如添加子控件
     */
    override func prepare() {
        super.prepare()
        mj_h = 60
        arrowView?.image = nil
        loadingView?.transform = .init(scaleX: 0.8, y: 0.8)
        labelLeftInset = 15
    }
    
    override var state: MJRefreshState {
        
        didSet {
            switch state {
            case .idle:
                stateLabel?.text = "准备加载"
            case .pulling:
                stateLabel?.text = "松开加载更多"
            case .refreshing:
                stateLabel?.text = "正在加载数据"
            case .noMoreData:
                stateLabel?.text = "暂无更多数据"
            default:
                break
            }
        }
    }
}
