//
//  ScrollTextView.swift
//  HuChuangApp
//
//  Created by sw on 02/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit

class ScrollTextView: UITableView {

    private var timer: Timer!
    private var scrolToRow: Int = 0
    
    public var cellDidScroll: ((Int) ->())?
    public var cellDidSelected: ((IndexPath) ->())?

    var datasourceModel: [ScrollTextModel]! {
        didSet {
            reloadData()
            
            beginScroll()
        }
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: .plain)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupUI() {
        register(ScrollTextCell.self, forCellReuseIdentifier: "ScrollTextCellID")
        
        isScrollEnabled = false
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        dataSource = self
        delegate   = self
    }
    
    private func beginScroll() {
        if datasourceModel.count < 2 { return }
        
        timerRemove()
        
        if #available(iOS 10.0, *) {
            timer = Timer.init(fire: Date.init(timeIntervalSinceNow: 3),
                               interval: TimeInterval(3),
                               repeats: true,
                               block: { [unowned self] timer in
                                self.cellScroll()
            })
        } else {
            timer = Timer.init(fireAt: Date.init(timeIntervalSinceNow: 3),
                               interval: TimeInterval(3),
                               target: self,
                               selector: #selector(cellScroll),
                               userInfo: nil,
                               repeats: true)
            timer.fireDate = Date()
        }
        
        RunLoop.main.add(timer, forMode: RunLoop.Mode.default)
    }

    @objc private func cellScroll() {
        scrolToRow += 1
        var scrolIndexPath: IndexPath!
        if scrolToRow >= datasourceModel.count {
            scrolToRow = 0
            scrolIndexPath = IndexPath.init(row: scrolToRow, section: 0)
            scrollToRow(at: scrolIndexPath, at: .top, animated: true)
            cellDidScroll?(scrolToRow)
        }else {
            scrolIndexPath = IndexPath.init(row: scrolToRow, section: 0)
            scrollToRow(at: scrolIndexPath, at: .top, animated: true)
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

}

extension ScrollTextView {
    
    
}

extension ScrollTextView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasourceModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: "ScrollTextCellID") as! ScrollTextCell
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
//    private var pointView: UIView!
    
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
    
    func setupUI(){
        selectionStyle = .none
        
//        pointView = UIView()
//        pointView.layer.cornerRadius = 3
//        pointView.clipsToBounds = true
//        pointView.backgroundColor = HC_MAIN_COLOR

        titleLable = UILabel()
        titleLable.font = UIFont.systemFont(ofSize: 13)
        titleLable.numberOfLines = 2
        titleLable.lineBreakMode = .byCharWrapping
        titleLable.textColor = RGB(65, 65, 65)
        
//        contentView.addSubview(pointView)
        contentView.addSubview(titleLable)
        
//        pointView.snp.makeConstraints { make in
//            make.left.equalTo(contentView).offset(15)
//            make.top.equalTo(contentView).offset(12)
//            make.size.equalTo(CGSize.init(width: 6, height: 6))
//        }
        
        titleLable.snp.makeConstraints { make in
            make.left.equalTo(contentView).offset(15)
            make.right.equalTo(contentView).offset(-15)
            make.top.equalTo(contentView)
            make.bottom.equalTo(contentView)
        }
    }
    
}

protocol ScrollTextModel {
    
    var textContent: String { get }
    
    var height: CGFloat { get }
}
