//
//  TableViewController.swift
//  MuYunControl
//
//  Created by miaokii on 2023/2/26.
//

import UIKit
import DZNEmptyDataSet

import TextAttributes

typealias MKTableViewControllerAny = MKTableViewController<Any>

class MKTableViewController<Element>: MKBaseViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    /// 总页数
    var totalPage = 0
    /// 总数据数
    var totalCount = 0
    /// 数据源
    var dataSource: [Element] = []
    /// 当前页数
    var page: Int = 0
    ///
    lazy var tableView: UITableView! = {
        let table = UITableView.init(frame: .zero, style: tableStyle)
        table.tableFooterView = .init()
        table.separatorStyle = .none
        table.backgroundColor = .background
        table.delegate = self
        table.dataSource = self
        return table
    }()
    /// cell类型
    var cellType: KKTableCell.Type! {
        didSet {
            tableView.register(cellType.classForCoder(), forCellReuseIdentifier: cellType.reuseID)
        }
    }
    /// 是否显示空白页
    var allowEmpty: Bool = false {
        didSet {
            tableView.emptyDataSetSource = allowEmpty ? self : nil
            tableView.emptyDataSetDelegate = allowEmpty ? self : nil
        }
    }
    /// 空白页文字
    var emptyTitle = "暂无数据"
    var emptyImage = MKBridge.UI.tableViewEmptyImage
    
    var tapEmptyRefresh = false
    
    var allowRefresh: Bool = false {
        didSet {
            if allowRefresh {
                tableView.mj_header = RefreshHeader.init(refreshingBlock: { [weak self] in
                    self?.requestFirstPageData()
                })
            } else {
                tableView.mj_header = nil
            }
        }
    }
    
    var allowLoading = false {
        didSet {
            if allowLoading {
                tableView.mj_footer = RefreshFooter.init(refreshingBlock: { [weak self] in
                    self?.requestData()
                })
            } else {
                tableView.mj_footer = nil
            }
        }
    }
    
    var tableStyle = UITableView.Style.plain
    var groupRound = false
    
    convenience init(style: UITableView.Style = .plain) {
        self.init()
        self.tableStyle = style
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if tableStyle == .grouped {
            tableView.tableHeaderView = .init(frame: .init(x: 0, y: 0, width: screenWidth, height: 0.001))
        }
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        view.addSubview(tableView)
        
        cellType = KKTableCell.self
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(view)
        }
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
        tableView.reloadData()
    }
    
    /// 结束刷新组件
    /// 设置是否显示footer，如果page达到totalpage，并且数据源数量达到totalCount，就不显示
    func endRefresh() {
        if allowRefresh {
            tableView.mj_header?.endRefreshing()
        }
        
        if allowLoading {
            let hideFooter = (page >= totalPage && totalPage > 0) || dataSource.count >= totalCount
            if hideFooter {
                tableView.mj_footer?.endRefreshingWithNoMoreData()
            } else {
                tableView.mj_footer?.endRefreshing()
            }
        }
    }
    
    func groupRound(cell: UIView, at indexPath: IndexPath, radii: CGFloat = 10) {
        
        let rowCount = tableView.numberOfRows(inSection: indexPath.section)
        
        if rowCount == 1 {
            let path = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radii, height: radii)).cgPath
            let layer = CAShapeLayer()
            layer.path = path
            cell.layer.mask = layer
        } else if indexPath.row == 0 {
            let path = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: radii, height: radii)).cgPath
            let layer = CAShapeLayer()
            layer.path = path
            cell.layer.mask = layer
        } else if indexPath.row == rowCount - 1 {
            let path = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: radii, height: radii)).cgPath
            let layer = CAShapeLayer()
            layer.path = path
            cell.layer.mask = layer
        } else {
            cell.layer.mask = nil
        }
    }
    
    // MARK: - Table Delegate
    dynamic func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    dynamic func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    dynamic func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellType.reuseID, for: indexPath) as! KKTableCell
        cell.set(model: dataSource[indexPath.row])
        return cell
    }
    
    dynamic func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    dynamic func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    dynamic func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    dynamic func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    dynamic func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    dynamic func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    dynamic func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    dynamic func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
    dynamic func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }

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
        if let header = tableView.tableHeaderView {
            return header.frame.height / 2 - 40
        }
        return -40
    }
}

