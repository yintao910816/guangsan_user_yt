//
//  ScrollTextView.swift
//  HuChuangApp
//
//  Created by sw on 02/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit

class TYScrollTextView: UIView {

    private var noticeImg: UIImageView!
    private var tableView: UITableView!
    private var arrowImg: UIImageView!
    
    private var timer: Timer!
    private var scrolToRow: Int = 0
    
    public var cellDidScroll: ((Int) ->())?
    public var cellDidSelected: ((IndexPath) ->())?

    var datasourceModel: [ScrollTextModel] = [] {
        didSet {
            tableView.reloadData()
            
            beginScroll()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        noticeImg = UIImageView(image: UIImage.init(named: "home_notice"))
        noticeImg.clipsToBounds = true
        noticeImg.contentMode = .scaleAspectFill

        tableView = UITableView.init(frame: .init(x: 30, y: 0, width: width - 30, height: height), style: .plain)
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.register(ScrollTextCell.self, forCellReuseIdentifier: "ScrollTextCellID")

        arrowImg = UIImageView(image: UIImage.init(named: "mine_jiantou"))
        arrowImg.clipsToBounds = true
        arrowImg.contentMode = .scaleAspectFill

        addSubview(noticeImg)
        addSubview(tableView)
        addSubview(arrowImg)
    }
    
    private func beginScroll() {
        if datasourceModel.count < 2 { return }
        
        timerRemove()
        
        timer = Timer.scheduledTimer(timeInterval: 3,
                                     target: self,
                                     selector: #selector(cellScroll),
                                     userInfo: nil,
                                     repeats: true)
        timer?.fireDate = Date.init(timeIntervalSinceNow: 3)
    }

    @objc private func cellScroll() {
        scrolToRow += 1
        var scrolIndexPath: IndexPath = IndexPath.init(row: 0, section: 0)
        if scrolToRow >= datasourceModel.count {
            scrolToRow = 0
            scrolIndexPath = IndexPath.init(row: scrolToRow, section: 0)
            tableView.scrollToRow(at: scrolIndexPath, at: .top, animated: true)
            cellDidScroll?(scrolToRow)
        }else {
            scrolIndexPath = IndexPath.init(row: scrolToRow, section: 0)
            tableView.scrollToRow(at: scrolIndexPath, at: .top, animated: true)
            cellDidScroll?(scrolToRow)
        }
    }
    
    private func timerPause() {
        timer.fireDate = Date.distantFuture
    }
    
    private func timerStar() {
        if timer != nil {
            timer.fireDate = Date()
        }else {
            beginScroll()
            timer.fireDate = Date()
        }
    }
    
    private func timerRemove() {
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
    
    deinit {
        timerRemove()
        PrintLog("计时器释放了")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        var imgSize = noticeImg.image?.size ?? CGSize.init(width: 30, height: 30)
        noticeImg.frame = .init(x: 0, y: (height - imgSize.height) / 2.0, width: imgSize.width, height: imgSize.height)
        
        imgSize = arrowImg.image?.size ?? CGSize.init(width: 20, height: 20)
        arrowImg.frame = .init(x: width - imgSize.width, y: (height - imgSize.height) / 2.0, width: imgSize.width, height: imgSize.height)
        
        tableView.frame = .init(x: noticeImg.frame.maxX + 10, y: 0, width: arrowImg.frame.minX - noticeImg.frame.maxX - 20, height: height)
    }
}

extension TYScrollTextView {
    
    
}

extension TYScrollTextView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasourceModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScrollTextCellID") as! ScrollTextCell
        cell.model = datasourceModel[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return datasourceModel[indexPath.row].height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellDidSelected?(indexPath)
    }
}

class ScrollTextCell: UITableViewCell {
    
    private var titleLable: UILabel!
    
    var model: ScrollTextModel! {
        didSet{
            titleLable.text = model.textContent
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupUI(){
        selectionStyle = .none
        
        titleLable = UILabel()
        titleLable.font = UIFont.systemFont(ofSize: 14)
        titleLable.textColor = RGB(65, 65, 65)
        titleLable.textAlignment = .center
        contentView.addSubview(titleLable)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = titleLable.sizeThatFits(.init(width: CGFloat(MAXFLOAT), height: 20.0))
        titleLable.frame = .init(x: 0, y: (height - size.height) / 2.0, width: min(size.width, width), height: size.height)
    }
    
}

protocol ScrollTextModel {
    
    var textContent: String { get }
    
    var height: CGFloat { get }
}
