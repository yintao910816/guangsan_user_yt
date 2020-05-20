//
//  HomeFunctionContentFlowLayout.swift
//  HuChuangApp
//
//  Created by yintao on 2020/5/20.
//  Copyright © 2020 sw. All rights reserved.
//

import Foundation

class HomeFunctionContentFlowLayout: UICollectionViewFlowLayout {
    
    private var lastFrame: CGRect = .zero
    private var attributeArray: [UICollectionViewLayoutAttributes] = []
    
    override func prepare() {
        lastFrame = .zero
        attributeArray.removeAll()
        
        guard let col = collectionView else {
            return
        }
        
        let totalWidth: CGFloat = col.width
        let sections: Int = col.numberOfSections
        
        let edgeInsets: UIEdgeInsets = sectionInset
        let interSpace: CGFloat = minimumInteritemSpacing
        let lineSpacing: CGFloat = minimumLineSpacing
        let cellSize: CGSize = itemSize

        for section in 0..<sections {
            let rows = col.numberOfItems(inSection: section)
            for row in 0..<rows {
                var x: CGFloat = CGFloat(section) * col.width + edgeInsets.left
                var y: CGFloat = 0
                if row > 0 {
                    x = lastFrame.maxX + interSpace
                }
                
                if x + cellSize.width + edgeInsets.right > totalWidth * CGFloat(section + 1) {
                    // 需要换行
                    x = CGFloat(section) * col.width + edgeInsets.left
                    y = lastFrame.maxY + lineSpacing
                }else {
                    // 不需要换行
                    y = lastFrame.origin.y
                }
                
                let att = UICollectionViewLayoutAttributes.init(forCellWith: IndexPath.init(row: row, section: section))
                att.frame = .init(x: x, y: y, width: cellSize.width, height: cellSize.height)

                attributeArray.append(att)
                                
                lastFrame = att.frame
            }
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var resultArray: [UICollectionViewLayoutAttributes] = []
        for attributes in attributeArray {
            if rect.intersects(attributes.frame) {
                resultArray.append(attributes)
            }
        }
        
        return resultArray
    }
    
    override var collectionViewContentSize: CGSize {
        guard let col = collectionView else {
            return .zero
        }
        
        return .init(width: CGFloat(col.numberOfSections) * col.width, height: col.height)
    }

}
