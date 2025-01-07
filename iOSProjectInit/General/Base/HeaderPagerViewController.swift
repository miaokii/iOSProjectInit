//
//  HeaderPagerViewController.swift
//  RXCSaaS
//
//  Created by yoctech on 2023/11/9.
//

#if canImport(JXSegmentedView)
import UIKit
import JXSegmentedView
import SnapKit

extension JXPagingListContainerView: JXSegmentedViewListContainer {}

protocol HeaderPagerLoadingProtocol {
    /// 设置应用和操作类型
    func set(application: SaaSApp, appHandelType: SaaSAppHandleType, workID: String)
    /// 设置客户详情
    func set(workInfo: AFParam)
    /// 加载新数据，加载后调用completion
    func headerPagerloading(completion: @escaping (String?)->Void)
}

extension HeaderPagerLoadingProtocol {
    func set(application: SaaSApp, appHandelType: SaaSHandleType, workID: String) {}
    func headerPagerloading(completion: @escaping (String?)->Void) {}
    func set(workInfo: AFParam) {}
}

class HeaderPagerViewController: BaseViewController {
    
    /// 指示器
    var indicatorView = JXSegmentedIndicatorLineView()
    /// 标题控件
    var titleDataSource = JXSegmentedTitleDataSource()
    var segmentedView = JXSegmentedView()
    lazy var pagingView: JXPagingView! = {
        let pagingView = JXPagingView.init(delegate: self, listContainerType: .collectionView)
        view.addSubview(pagingView)
        return pagingView
    }()
    
    /// 是否添加到导航栏
    var isAddToNav = false
    /// 标题
    var titles = [String]()
    /// 显示指示器
    var needIndicator = true
    /// 子视图
    var controllers = [JXPagingViewListViewDelegate & HeaderPagerLoadingProtocol]()
    /// 头视图
    var headContainer = UIView()
    var segmentedViewHeight = 45
    
    var headerHeight: CGFloat {
        headContainer.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    }
    
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
        titleDataSource.itemWidth = JXSegmentedViewAutomaticDimension
    }
    
    override func viewDidLoad() {
        setDefault()
        super.viewDidLoad()
        
        view.backgroundColor = .white
        segmentedView.frame = .init(x: 0, y: 0, width: screenWidth, height: CGFloat(segmentedViewHeight))
        segmentedView.dataSource = titleDataSource
        segmentedView.isContentScrollViewClickTransitionAnimationEnabled = true
        segmentedView.indicators = needIndicator ? [indicatorView] : []
        segmentedView.backgroundColor = .white
        view.addSubview(segmentedView)
        
        pagingView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(-safeAreaBottom)
        }
        segmentedView.listContainer = pagingView.listContainerView
        
        refreshTitleControllers()
    }
    
    func refreshTitleControllers() {
        guard !titles.isEmpty, !controllers.isEmpty else {
            return
        }
        
        titleDataSource.titles = titles
        pagingView.reloadData()
        segmentedView.reloadData()
        
        headContainer.frame = .init(x: 0, y: 0, width: screenWidth, height: headerHeight)
    }
}

extension HeaderPagerViewController: JXPagingViewDelegate {
    func tableHeaderViewHeight(in pagingView: JXPagingView) -> Int {
        Int(headerHeight)
    }
    
    func tableHeaderView(in pagingView: JXPagingView) -> UIView {
        headContainer
    }
    
    func heightForPinSectionHeader(in pagingView: JXPagingView) -> Int {
        segmentedViewHeight
    }
    
    func viewForPinSectionHeader(in pagingView: JXPagingView) -> UIView {
        segmentedView
    }
    
    func pagingView(_ pagingView: JXPagingView, initListAtIndex index: Int) -> JXPagingViewListViewDelegate {
        return controllers[index]
    }
    
    func numberOfLists(in pagingView: JXPagingView) -> Int {
        if let dataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return dataSource.dataSource.count
        }
        return 0
    }
}


class HeaderPagerListController<Element>: MKTableViewController<Element>, JXPagingViewListViewDelegate, HeaderPagerLoadingProtocol {
    
    var listViewDidScrollCallback: ((UIScrollView) -> ())?
    var workID = ""
    var workInfo = AFParam()
    var application: SaaSApp!
    var appHandleType: SaaSAppHandleType = .other
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.snp.remakeConstraints { make in
            make.edges.equalTo(0)
        }
    }
    
    deinit {
        listViewDidScrollCallback = nil
    }
        
    func listView() -> UIView {
        view
    }
    
    func listScrollView() -> UIScrollView {
        tableView
    }
    
    func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> ()) {
        listViewDidScrollCallback = callback
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        listViewDidScrollCallback?(scrollView)
    }
    
    func headerPagerloading(completion: @escaping (String?) -> Void) {
        
    }
    
    func set(application: SaaSApp, appHandelType: SaaSAppHandleType, workID: String) {
        self.workID = workID
        self.application = application
        self.appHandleType = appHandelType
    }
    
    func set(workInfo: AFParam) {
        self.workInfo = workInfo
    }
}
#endif
