//
//  CarouselView.swift
//  ComicsReader
//
//  Created by 尹涛 on 2018/5/22.
//  Copyright © 2018年 yintao. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

class CarouselView: UIView {

    private var scroll: UIScrollView!
    private var pageContrl: UIPageControl!
    
    // 上一个
    private var lastImageView: UIImageView!
    // 此imageView始终为当前显示的
    private var currentImageView: UIImageView!
    // 下一个
    private var nextImageView: UIImageView!
    
    private var tapGesture: UITapGestureRecognizer!

    private let dataControl = CarouselDatasource.init()
    
    private var timer: Timer?
    
    public var tapCallBack: ((CarouselSource) ->Void)?
    
    public var timeInterval: TimeInterval = 4.0 {
        didSet {
            resetTimer()
            timer?.fireDate = Date.init(timeIntervalSinceNow: timeInterval)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func setData<T: CarouselSource>(source: [T]) {
        if source.count > 0 {
            tapGesture.isEnabled = true
            scroll.isUserInteractionEnabled = true

            dataControl.dataSource = source
            
            pageContrl.numberOfPages = source.count
            scroll.isScrollEnabled = !(source.count <= 1)
            
            setCarouselImage()
            
            resetTimer()
            timer?.fireDate = Date.init(timeIntervalSinceNow: timeInterval)
        }
    }
    
    private func setCarouselImage() {
        lastImageView.setImage(dataControl.itemModel(.last)?.url)
        currentImageView.setImage(dataControl.itemModel(.current)?.url)
        nextImageView.setImage(dataControl.itemModel(.next)?.url)
    
        scroll.setContentOffset(CGPoint.init(x: width, y: 0), animated: false)
    }
    
    private func setupView() {
        scroll = UIScrollView.init()
        scroll.isPagingEnabled = true
        scroll.isUserInteractionEnabled = false
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.delegate = self
        
        lastImageView = UIImageView.init()
        lastImageView.contentMode = .scaleAspectFill
        lastImageView.clipsToBounds = true
        
        currentImageView = UIImageView.init()
        currentImageView.contentMode = .scaleAspectFill
        currentImageView.clipsToBounds = true

        nextImageView = UIImageView.init()
        nextImageView.contentMode = .scaleAspectFill
        nextImageView.clipsToBounds = true
        
        pageContrl = UIPageControl.init()
        pageContrl.currentPage = 0
        pageContrl.currentPageIndicatorTintColor = HC_MAIN_COLOR
        pageContrl.pageIndicatorTintColor = .white

        addSubview(scroll)
        scroll.addSubview(lastImageView)
        scroll.addSubview(currentImageView)
        scroll.addSubview(nextImageView)
        addSubview(pageContrl)
        bringSubviewToFront(pageContrl)
        
        scroll.setContentOffset(CGPoint.init(x: width, y: 0), animated: false)
        
        tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapCarousel(_:)))
        tapGesture.isEnabled = false
        addGestureRecognizer(tapGesture)
    }
        
    @objc private func timerAction() {
        scroll.setContentOffset(CGPoint.init(x: width * 2, y: 0), animated: true)
    }
    
    @objc private func tapCarousel(_ tap: UITapGestureRecognizer) {
        tapCallBack?(dataControl.itemModel()!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scroll.snp.makeConstraints { $0.edges.equalTo(self).inset(UIEdgeInsets.zero) }
        
        lastImageView.snp.makeConstraints {
            $0.left.equalTo(scroll)
            $0.top.equalTo(scroll)
            $0.size.equalTo(CGSize.init(width: width, height: height))
        }
        
        currentImageView.snp.makeConstraints {
            $0.left.equalTo(scroll).offset(width)
            $0.top.equalTo(scroll)
            $0.size.equalTo(CGSize.init(width: width, height: height))
        }
        
        nextImageView.snp.makeConstraints {
            $0.left.equalTo(scroll).offset(2 * width)
            $0.top.equalTo(scroll)
            $0.size.equalTo(CGSize.init(width: width, height: height))
        }

        pageContrl.snp.makeConstraints {
            $0.right.equalTo(self).offset(-20)
            $0.bottom.equalTo(self)
        }
        
        scroll.contentSize = .init(width: scroll.width * 3, height: scroll.height)
    }
    
    deinit {
        dellocTimer()
        PrintLog("计时器释放了 -- \(self)")
    }
}

extension CarouselView: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        timer?.fireDate = Date.distantFuture
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        dataControl.scrollEnd(scroll: scrollView) { [unowned self] page in self.pageContrl.currentPage = page }
        
        setCarouselImage()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidEndDecelerating(scrollView)
        }
        
        timer?.fireDate = Date.init(timeIntervalSinceNow: timeInterval)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDidEndDecelerating(scrollView)
    }
    
}

extension CarouselView {
    
    private func resetTimer() {
        dellocTimer()
        
        timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                     target: self,
                                     selector: #selector(timerAction),
                                     userInfo: nil,
                                     repeats: true)
        timer?.fireDate = Date.distantFuture
    }

    private func dellocTimer() {
        timer?.invalidate()
        timer = nil
    }
}
