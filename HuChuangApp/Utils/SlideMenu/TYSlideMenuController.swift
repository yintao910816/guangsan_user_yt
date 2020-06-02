//
//  TYSlideMenuController.swift
//  HuChuangApp
//
//  Created by sw on 2019/9/27.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit
import RxSwift

class TYSlideMenuController: UIViewController {

    private var headerMenu: TYSlideMenu!
    private var pageCtrl: UIPageViewController!
    
    private var currentPage: Int = 0
    
    private var pendingCtrl: UIViewController?
        
    public var pageScroll: ((Int)->())?
    public let pageScrollSubject = PublishSubject<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        headerMenu = TYSlideMenu()
        headerMenu.backgroundColor = .white
        view.addSubview(headerMenu)
        
        headerMenu.datasource = menuItems
        headerMenu.menuSelect = { [weak self] page in
            guard let strongSelf = self else { return }
            strongSelf.selectedPage(page: page, needCallBack: true)
        }
        
        pageCtrl = UIPageViewController.init(transitionStyle: .scroll,
                                             navigationOrientation: .horizontal,
                                             options: [UIPageViewController.OptionsKey.interPageSpacing : 0])
        pageCtrl.dataSource = self
        pageCtrl.delegate = self
        addChild(pageCtrl)
        view.addSubview(pageCtrl.view)
    }
         
    public func selectedPage(page: Int, needCallBack: Bool, needMenuScroll: Bool = false) {
        if page == currentPage || page >= menuCtrls.count { return }
        
        pageCtrl.setViewControllers([menuCtrls[page]],
                                               direction: page > currentPage ? .forward : .reverse,
                                               animated: true) { if $0 {  } }
        
        currentPage = page
        
        if needCallBack {
            pageScroll?(page)
            pageScrollSubject.onNext(page)
        }
        
        if needMenuScroll {
            headerMenu.setMenu(index: page)
        }
    }
    
    public var menuCtrls: [HCSlideItemController] = [] {
        didSet {
                        
            if menuCtrls.count > currentPage {
                let ctrl = menuCtrls[currentPage]
                ctrl.view.frame = pageCtrl.view.bounds
                pageCtrl.setViewControllers([ctrl],
                                            direction: .reverse,
                                            animated: false,
                                            completion: nil)
            }else {
                pageCtrl.setViewControllers(nil,
                                            direction: .reverse,
                                            animated: false,
                                            completion: nil)
            }
        }
    }
    
    public var menuItems: [TYSlideItemModel] = [] {
        didSet {
            headerMenu.datasource = menuItems
        }
    }

    public func reloadList(listMode: [Any], page: Int) {
        if menuCtrls.count > page {
            menuCtrls[page].reloadData(data: listMode)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        headerMenu.frame = .init(x: 0, y: 0, width: view.width, height: 50)
        pageCtrl.view.frame = .init(x: 0, y: headerMenu.frame.maxY, width: view.width, height: view.height - headerMenu.height)
    }
}

extension TYSlideMenuController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    // 获取上一页
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if menuCtrls.count > (currentPage - 1) && currentPage > 0 {
            currentPage -= 1
            let ctrl = menuCtrls.first(where: { $0.pageIdx == currentPage })
            ctrl?.view.frame = pageCtrl.view.bounds
            
            return ctrl
        }
        
        return nil
    }
    
    // 获取下一页
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if menuCtrls.count > (currentPage + 1) {
            currentPage += 1
            let ctrl = menuCtrls.first(where: { $0.pageIdx == currentPage })
            
            ctrl?.view.frame = pageCtrl.view.bounds

            return ctrl
        }
        
        return nil
    }
    
    //MARK: - UIPageViewControllerDelegate
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        pendingCtrl = pendingViewControllers.first
    }
    
    // 动画过渡完成 - previousViewControllers为过渡之前的视图控制器
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        for idx in 0..<menuCtrls.count {
            // //判断视图控制器是否与正在转换的视图控制器为同一个
            if pendingCtrl == menuCtrls[idx] {
                currentPage = idx
                                
                headerMenu.setMenu(index: currentPage)
                pageScroll?(currentPage)
                pageScrollSubject.onNext(currentPage)
                break
            }
        }
    }
}

//MARK: -- TYSlideMenu
class TYSlideMenu: UIView {
    
    private var collectionView: UICollectionView!
    private var lastSelected: Int = 0
    public var menuSelect: ((Int)->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView.init(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        addSubview(collectionView)
        
        collectionView.register(TYSlideCell.self, forCellWithReuseIdentifier: UICollectionViewCell_identifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setMenu(index: Int) {
        datasource[index].isSelected = true
        datasource[lastSelected].isSelected = false
        collectionView.reloadData()
        
        lastSelected = index
    }
    
    fileprivate var datasource: [TYSlideItemModel] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.frame = bounds
    }
}

extension TYSlideMenu: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewCell_identifier, for: indexPath) as! TYSlideCell)
        cell.model = datasource[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: datasource[indexPath.row].contentWidth, height: collectionView.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        menuSelect?(indexPath.row)

        if lastSelected != indexPath.row {
            datasource[indexPath.row].isSelected = true
            datasource[lastSelected].isSelected = false
            collectionView.reloadData()
            
            lastSelected = indexPath.row
        }
    }
}

//MARK: -- Cell
private let UICollectionViewCell_identifier = "UICollectionViewCell"
class TYSlideCell: UICollectionViewCell {
    private var titleLabel: UILabel!
    private var bottomLine: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel = UILabel()
        titleLabel.backgroundColor = .clear
        titleLabel.textAlignment = .center
        titleLabel.font = .font(fontSize: 14)
        addSubview(titleLabel)
        
        bottomLine = UIView()
        insertSubview(bottomLine, aboveSubview: titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var model: TYSlideItemModel! {
        didSet {
            titleLabel.text = model.dataModel.name
            
            titleLabel.textColor = model.isSelected ? model.selectedTextColor : model.textColor
            bottomLine.backgroundColor = model.lineColor
            bottomLine.isHidden = !model.isSelected
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.frame = bounds
        bottomLine.frame = .init(x: 0, y: height - 2, width: width, height: 2)
    }
}
