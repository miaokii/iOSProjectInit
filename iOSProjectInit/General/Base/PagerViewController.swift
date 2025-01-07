//
//  PagerViewController.swift
//  RXCSaaS
//
//  Created by yoctech on 2023/11/6.
//

#if canImport(JXSegmentedView)
import UIKit
import JXSegmentedView

class PagerViewController: BaseViewController, JXSegmentedViewDelegate, JXSegmentedListContainerViewDataSource {
    /// 指示器
    var indicatorView = JXSegmentedIndicatorLineView()
    /// 标题控件
    var titleDataSource = JXSegmentedTitleDataSource()
    var segmentedView = JXSegmentedView()
    
    lazy var listContainerView: JXSegmentedListContainerView! = {
        JXSegmentedListContainerView.init(dataSource: self)
    }()
    
    ///
    var headerView: UIView?
    ///
    var headerHeight: CGFloat = 0
    
    /// 是否添加到导航栏
    var isAddToNav = false
    /// 标题
    var titles = [String]()
    /// 显示指示器
    var needIndicator = true
    /// 视图
    var controllers = [JXSegmentedListContainerViewListDelegate]()
    var segmentedViewHeight = 45
    
    func setDefault() {
        indicatorView.indicatorWidth = JXSegmentedViewAutomaticDimension
        indicatorView.indicatorColor = .theme
        indicatorView.indicatorHeight = 2
        indicatorView.indicatorCornerRadius = 1
        
        titleDataSource.isTitleColorGradientEnabled = true
        titleDataSource.titleSelectedColor = .theme
        titleDataSource.isTitleZoomEnabled = true
        titleDataSource.titleSelectedZoomScale = 1.2
        titleDataSource.isTitleStrokeWidthEnabled = true
        titleDataSource.isSelectedAnimable = true
        titleDataSource.titleNormalFont = .regular(15)
    }
    
    override func viewDidLoad() {
        setDefault()
        super.viewDidLoad()
        
        if isAddToNav {
            segmentedViewHeight = Int(navBarHeight)
        }
        
        view.backgroundColor = .white
        segmentedView.dataSource = titleDataSource
        segmentedView.delegate = self
        view.addSubview(segmentedView)
        
        segmentedView.listContainer = listContainerView
        view.addSubview(listContainerView)
        
        segmentedView.indicators = needIndicator ? [indicatorView] : []
        
        segmentedView.frame = .init(x: 0, y: 0, width: screenWidth, height: CGFloat(segmentedViewHeight))
        listContainerView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(isAddToNav ? view : segmentedView.snp.bottom)
        }
        
        if (isAddToNav) {
            navigationItem.titleView = segmentedView
        }
    }
    
    func refreshTitleControllers() {
        titleDataSource.titles = titles
        segmentedView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        
    }

    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let dataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return dataSource.dataSource.count
        }
        return 0
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        controllers[index]
    }
}

extension BaseViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        view
    }
}

#endif
