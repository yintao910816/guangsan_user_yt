//
//  HomeFunctionContentCell.swift
//  HuChuangApp
//
//  Created by yintao on 2020/5/20.
//  Copyright © 2020 sw. All rights reserved.
//

import UIKit

public let HomeFunctionContentCell_identifier = "HomeFunctionContentCell"

class HomeFunctionContentCell: UITableViewCell {

    @IBOutlet weak var contnetBgView: UIView!
    @IBOutlet weak var shadowBgView: UIView!
    @IBOutlet weak var firstBottomLine: UIView!
    @IBOutlet weak var secondBottomLine: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    public var itemDidSelected:((HomeFunctionModel)->())?
    
    @IBAction func actions(_ sender: UIButton) {
        changeSelected(index: sender.tag - 100)
        collectionView.setContentOffset(.init(x: collectionView.width * CGFloat(sender.tag - 100), y: 0), animated: true)
    }
    
    private func changeSelected(index: Int) {
        (contentView.viewWithTag(index) as? UIButton)?.isSelected = true
        (contentView.viewWithTag(1 - index) as? UIButton)?.isSelected = false
        
        firstBottomLine.isHidden = index != 0
        secondBottomLine.isHidden = index == 0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let w = (PPScreenW - 30 * 3 - 15*2 - 10 * 2) / 4.0

        let layout = HomeFunctionContentFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = .init(top: 15, left: 10, bottom: 20, right: 10)
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 30
        layout.itemSize = .init(width: w, height: 69)
        
        collectionView.collectionViewLayout = layout
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib.init(nibName: "HomeFunctionItemCell", bundle: nil),
                                forCellWithReuseIdentifier: HomeFunctionItemCell_identifier)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        shadowBgView.setCornerAndShaow(shadowRadius: 1, shadowOpacity: 0.02)
    }
    
    public var models: [HomeFunctionSectionModel] = [] {
        didSet {
            if models.count >= 2 {
                (contentView.viewWithTag(100) as? UIButton)?.setTitle(models.first?.name, for: .normal)
                (contentView.viewWithTag(100) as? UIButton)?.setTitle(models.first?.name, for: .selected)

                (contentView.viewWithTag(101) as? UIButton)?.setTitle(models[1].name, for: .normal)
                (contentView.viewWithTag(101) as? UIButton)?.setTitle(models.first?.name, for: .selected)
                
            }else {
                (contentView.viewWithTag(100) as? UIButton)?.setTitle(models.first?.name, for: .normal)
                (contentView.viewWithTag(100) as? UIButton)?.setTitle(models.first?.name, for: .selected)

                (contentView.viewWithTag(101) as? UIButton)?.setTitle(nil, for: .normal)
                (contentView.viewWithTag(101) as? UIButton)?.setTitle(nil, for: .selected)
            }
            
            collectionView.reloadData()
        }
    }
    
    static func cellHeight(for line: Int) ->CGFloat {
        if line == 0 {
            return 5 + 35
        }else {
            return 5 + 35 + CGFloat(69 * line) + CGFloat(15*(line - 1)) + 20.0
        }
    }
    
}

extension HomeFunctionContentCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return min(2, models.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models[section].functions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeFunctionItemCell_identifier, for: indexPath) as! HomeFunctionItemCell
        cell.model = models[indexPath.section].functions[indexPath.row]
        return cell
    }
       
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        itemDidSelected?(models[indexPath.section].functions[indexPath.row])
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        changeSelected(index: Int(scrollView.contentOffset.x / scrollView.width))
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            changeSelected(index: Int(scrollView.contentOffset.x / scrollView.width))
        }
    }
}
