//
//  MKCollectionViewController.swift
//  RongXT
//
//  Created by yoctech on 2025/2/19.
//

import UIKit
import DZNEmptyDataSet
import TextAttributes

class MKCollectionViewController<Element>: MKBaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    /// 总页数
    var totalPage = 0
    /// 总数据数
    var totalCount = 0
    /// 数据源
    var dataSource: [Element] = []
    /// 当前页数
    var page: Int = 0
    
    var layout = UICollectionViewLayout()
    
    ///
    lazy var collectionView: UICollectionView! = {
        
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = true
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(-safeAreaBottom)
        }
        return collectionView
    }()
    /// cell类型
    var cellType: KKCollectionCell.Type! {
        didSet {
            collectionView.register(cellType: cellType)
        }
    }
    /// 是否显示空白页
    var allowEmpty: Bool = false {
        didSet {
            collectionView.emptyDataSetSource = allowEmpty ? self : nil
            collectionView.emptyDataSetDelegate = allowEmpty ? self : nil
        }
    }
    /// 空白页文字
    var emptyTitle = "暂无数据"
    var emptyImage = MKBridge.UI.tableViewEmptyImage
    
    var tapEmptyRefresh = false
    
    var allowRefresh: Bool = false {
        didSet {
            if allowRefresh {
                collectionView.mj_header = RefreshHeader.init(refreshingBlock: { [weak self] in
                    self?.requestFirstPageData()
                })
            } else {
                collectionView.mj_header = nil
            }
        }
    }
    
    var allowLoading = false {
        didSet {
            if allowLoading {
                collectionView.mj_footer = RefreshFooter.init(refreshingBlock: { [weak self] in
                    self?.requestData()
                })
            } else {
                collectionView.mj_footer = nil
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        cellType = KKCollectionCell.self
        allowEmpty = true
    }
     
    /// 下拉刷新
    func requestFirstPageData() {
        page = 0
        requestData()
    }
    
    /// 上拉加载
    func requestData() { }
    
    /// 即将刷新，这个方法在reload(response:)方法结束时执行
    func willReloadData() { }
    
    func reloadData() {
        willReloadData()
        endRefresh()
        collectionView.reloadData()
    }
    
    /// 结束刷新组件
    /// 设置是否显示footer，如果page达到totalpage，并且数据源数量达到totalCount，就不显示
    func endRefresh(list: [Any]? = nil) {
        if allowRefresh {
            collectionView.mj_header?.endRefreshing()
        }
        
        if allowLoading {
            let hideFooter = (page >= totalPage && totalPage > 0) || (list ?? dataSource).count >= totalCount
            if hideFooter {
                collectionView.mj_footer?.endRefreshingWithNoMoreData()
            } else {
                collectionView.mj_footer?.endRefreshing()
            }
        }
    }
    
    // MARK: - CollectionView Delegate
    dynamic func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    dynamic func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.count
    }
    
    dynamic func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(type: cellType, at: indexPath)
        cell.set(model: dataSource[indexPath.row])
        return cell
    }
    
    dynamic func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    dynamic func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        .zero
    }
    
    dynamic func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        .zero
    }
    
    dynamic func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        .init()
    }
    
    dynamic func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
//    dynamic func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return .zero
//    }

    // MARK: - Empty Source
    dynamic func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return emptyImage
    }

    dynamic func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return .init(string: emptyTitle, attributes: TextAttributes.init().font(.systemFont(ofSize: 12)).foregroundColor(.textColorLightGray).alignment(.center))
    }

    dynamic func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        if tapEmptyRefresh {
            requestFirstPageData()
        }
    }
    
    dynamic func emptyDataSetShouldFade(in scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    dynamic func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    dynamic func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -40
    }
}

