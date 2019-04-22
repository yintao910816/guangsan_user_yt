//
//  HomeHeader.swift
//  HuChuangApp
//
//  Created by sw on 02/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class HomeHeaderView: UIView {
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var carouselView: CarouselView!
    @IBOutlet weak var functionView: UICollectionView!
    @IBOutlet weak var noticeView: ScrollTextView!
    @IBOutlet weak var noticeMessageTitleOutlet: UILabel!
    @IBOutlet weak var goodNewsView: ScrollTextView!
    // 今日知识
    @IBOutlet weak var colunmCollectionView: UICollectionView!
    @IBOutlet weak var goodNewsHeaderView: UIView!
    
    @IBOutlet weak var functionViewHeightCns: NSLayoutConstraint!
    @IBOutlet weak var noticeHeightCns: NSLayoutConstraint!
    @IBOutlet weak var goodNewsHeightCns: NSLayoutConstraint!

    @IBOutlet weak var ttHeightCns: NSLayoutConstraint!
    private var lastSelectedIndexPath: IndexPath?
    
    var bannerModelObser = Variable([HomeBannerModel]())
    var functionModelObser = Variable([HomeFunctionModel]())
    var noticeModelObser = Variable([HomeNoticeModel]())
    var goodNewsModelObser = Variable(HomeGoodNewsModel())
    var colunmModelObser = Variable(HomeColumnModel())
    var didSelectItemSubject = PublishSubject<HomeColumnItemModel>()
    
    public let noticeDidSelected = PublishSubject<Int>()
    public let goodnewsDidSelected = PublishSubject<Int>()

    public let functionDidSelected = PublishSubject<HomeFunctionModel>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView = (Bundle.main.loadNibNamed("HomeHeaderView", owner: self, options: nil)?.first as! UIView)
        addSubview(contentView)

        contentView.snp.makeConstraints{ $0.edges.equalTo(UIEdgeInsets.zero) }
       
        colunmCollectionView.register(UINib.init(nibName: "ColunmCollectionViewCell", bundle: Bundle.main),
                                      forCellWithReuseIdentifier: "ColunmCollectionViewCellID")
        
        setupUI()
        rxBind()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let width: CGFloat = (PPScreenW - 1) / 4.0
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: width, height: width)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .init(top: 0, left: 0, bottom: 10, right: 0)
        
        functionView.collectionViewLayout = layout
        functionView.register(UINib.init(nibName: "HomeFunctionCell", bundle: Bundle.main), forCellWithReuseIdentifier: "HomeFunctionCellID")
    }
    
    private func rxBind() {
        
        noticeView.cellDidScroll = { [weak self] row in
            print(row)
            self?.configNoticeTitle(model: self?.noticeModelObser.value[row])
        }
        
        bannerModelObser.asDriver()
            .drive(onNext: { [weak self] data in
                self?.carouselView.setData(source: data)
            })
            .disposed(by: disposeBag)
        
        noticeModelObser.asDriver()
            .drive(onNext: { [weak self] data in
                self?.configNoticeTitle(model: data.first)
                self?.noticeView.datasourceModel = data
            })
            .disposed(by: disposeBag)

        goodNewsModelObser.asDriver()
            .map{ $0.list }
            .drive(onNext: { [weak self] data in
                self?.goodNewsView.datasourceModel = data
            })
            .disposed(by: disposeBag)

        functionModelObser.asDriver()
            .drive(functionView.rx.items(cellIdentifier: "HomeFunctionCellID", cellType: HomeFunctionCell.self)){ (_, model, cell) in
                cell.model = model
            }
            .disposed(by: disposeBag)
        
        functionView.rx.modelSelected(HomeFunctionModel.self)
            .bind(to: functionDidSelected)
            .disposed(by: disposeBag)
        
        // 今日知识
        let columData = colunmModelObser.asDriver().map{ [weak self] model -> [HomeColumnItemModel] in
            self?.lastSelectedIndexPath = IndexPath.init(row: 0, section: 0)
            return model.content
        }
        columData.drive(colunmCollectionView.rx.items(cellIdentifier: "ColunmCollectionViewCellID", cellType: ColunmCollectionViewCell.self)) { _, model, cell in
            cell.model = model
            }
            .disposed(by: disposeBag)
        
        colunmCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        noticeView.cellDidSelected = { [weak self] indexPath in
            self?.noticeDidSelected.onNext(indexPath.row)
        }
        
        goodNewsView.cellDidSelected = { [weak self] indexPath in
            self?.goodnewsDidSelected.onNext(indexPath.row)
        }

    }
}

extension HomeHeaderView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return colunmModelObser.value.content[indexPath.row].cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let _lastSelectedIndexPath = lastSelectedIndexPath, indexPath != _lastSelectedIndexPath {
            let selectedModel = colunmModelObser.value.content[indexPath.row]
            let lastSelectedModel = colunmModelObser.value.content[_lastSelectedIndexPath.row]

            selectedModel.isSelected = true
            lastSelectedModel.isSelected = false
            
            didSelectItemSubject.onNext(selectedModel)
            
            var cell = collectionView.cellForItem(at: indexPath) as? ColunmCollectionViewCell
            cell?.updateUI()
            cell = collectionView.cellForItem(at: _lastSelectedIndexPath) as? ColunmCollectionViewCell
            cell?.updateUI()

            lastSelectedIndexPath = indexPath
        }
    }
}

extension HomeHeaderView {
    
    private func configNoticeTitle(model: HomeNoticeModel?) {
        if let title = model?.title {
            print(title)
            noticeMessageTitleOutlet.text = "通知提醒 | \(title)"
        }else {
            noticeMessageTitleOutlet.text = "通知提醒 | 最新消息"
        }
    }
}

extension HomeHeaderView {
    
    func headerHeight(functionDataCount: Int, noticeDataCount: Int, goodNewsDataCount: Int) ->CGFloat {
        ttHeightCns.constant = 0 // 测试使用，正式删掉,原本高度44
        
        var minHeight: CGFloat = 436 - 85 - 75 - 44
        if functionDataCount > 0 {
            let itemHeight: CGFloat = (PPScreenW - 1) / 4.0
            let height = CGFloat((functionDataCount / 4 + (functionDataCount % 4 == 0 ? 0 : 1))) * itemHeight + 10.0
            minHeight += height
            
            functionViewHeightCns.constant = height
        }else {
            functionViewHeightCns.constant = 0
        }
        
        if noticeDataCount > 0 {
            minHeight += 85
            noticeHeightCns.constant = 85
        }else {
            noticeHeightCns.constant = 0
        }

        if goodNewsDataCount > 0 {
            minHeight += 75
            goodNewsHeightCns.constant = 75
        }else {
            goodNewsHeightCns.constant = 0
        }

        return minHeight
    }
}
