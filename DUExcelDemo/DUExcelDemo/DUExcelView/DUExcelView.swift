//
//  ExcelViewSwifty.swift
//  YunYingSwift
//
//  Created by AlasKu on 17/2/10.
//  Copyright © 2017年 innostic. All rights reserved.
//
import UIKit

let AKCollectionViewCellIdentifier = "AKCollectionView_Cell"
let AKCollectionViewHeaderIdentifier = "AKCollectionView_Header"

@objc protocol DUExcelViewDelegate: NSObjectProtocol {
    
    @objc optional func excelView(_ excelView: DUExcelView, didSelectItemAt indexPath: IndexPath)
    @objc optional func excelView(_ excelView: DUExcelView, viewAt indexPath: IndexPath) -> UIView?
    @objc optional func excelView(_ excelView: DUExcelView, attributedStringAt indexPath: IndexPath) -> NSAttributedString?
}

class DUExcelView: UIView , UICollectionViewDelegate , UICollectionViewDataSource , UIScrollViewDelegate , UICollectionViewDelegateFlowLayout{
    
    /// Delegate
    weak var delegate: DUExcelViewDelegate?
    /// CellTextMargin
    var textMargin: CGFloat = 5
    /// Cell Max width
    var itemMaxWidth: CGFloat = 200
    /// cell Min width
    var itemMinWidth: CGFloat = 50
    /// cell heihth
    var itemHeight: CGFloat = 44
    /// header Height
    var headerHeight: CGFloat = 44
    /// header BackgroundColor
    var headerBackgroundColor: UIColor = UIColor.lightGray
    /// header Text Color
    var headerTextColor: UIColor = UIColor.black
    /// header Text Font
    var headerTextFontSize: UIFont = UIFont.systemFont(ofSize: 15)
    /// contenTCell TextColor
    var contentTextColor: UIColor = UIColor.black
    /// 奇数行背景颜色
    var oddLineBackgroundColor: UIColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 249/255.0, alpha: 1)
    /// 偶数行背景颜色
    var evenLineBackgroundColor: UIColor = UIColor.white
    /// content backgroung Color, 设置内容背景颜色后，会自动同步奇偶行背景
    var contentBackgroundColor: UIColor = UIColor.black {
        didSet {
            oddLineBackgroundColor = contentBackgroundColor
            evenLineBackgroundColor = contentBackgroundColor
        }
    }
    /// content Text Font
    var contentTextFontSize: UIFont = UIFont.systemFont(ofSize: 13)
    /// letf freeze column
    var leftFreezeColumn: Int = 1
    /// header Titles
    var headerTitles: Array<String>?
    /// content Data
    var contentData: Array<NSObject>?
    /// set Column widths
    var columnWidthSetting: Dictionary<Int, CGFloat>?
    /// CelledgeInset
    var itemInsets: UIEdgeInsets?
    /// showsProperties
    var properties: Array<String>?
    /// autoScrollItem default is false
    var autoScrollToNearItem: Bool = false
    /// showNoDataView default is false
    var showNoDataView: Bool = false {
        didSet{
            self.addSubview(alertLabel)
            alertLabel.center = self.center
        }
    }
    var noDataDescription: String = " - 暂无数据 - " {
        didSet{
            alertLabel.text = noDataDescription
        }
    }
    var alertLabel: UILabel = {
        let alertLabel = UILabel()
        alertLabel.text = " - 暂无数据 - "
        alertLabel.textColor = .lightGray
        alertLabel.sizeToFit()
        return alertLabel
    }()
    
    fileprivate lazy var veritcalShadow: CAShapeLayer = {
        let s = CAShapeLayer()
        s.strokeColor = UIColor.lightGray.cgColor;
        s.shadowColor = UIColor.black.cgColor;
        s.shadowOffset = CGSize.init(width: 0, height: -3)
        s.shadowOpacity = 1;
        return s
    }()
    
    //MARK: - Public Method
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setUpFrames()
    }
    
    func reloadData() {
        reloadDataCompleteHandler()
    }
    
    func reloadDataCompleteHandler(complete:(() -> Void)? = nil) {
        DispatchQueue.global().async {
            self.dataManager.caculateData()
            DispatchQueue.main.async {
                self.headFreezeCollectionView.reloadData()
                self.headMovebleCollectionView.reloadData()
                self.contentFreezeCollectionView.reloadData()
                self.contentMoveableCollectionView.reloadData()
                
                self.setUpFrames()
                complete?()
            }
        }
    }
    
    func sizeForItem(item: Int) -> CGSize {
        if item < leftFreezeColumn {
            return NSCoder.cgSize(for: self.dataManager.freezeItemSize[item]);
        } else {
            return NSCoder.cgSize(for: self.dataManager.slideItemSize[item - leftFreezeColumn]);
        }
    }
    
    //MARK: - Private Method
    private func setup() {
        dataManager.excelView = self
        clipsToBounds = true
        addSubview(contentFreezeCollectionView)
        addSubview(contentScrollView)
        addSubview(headFreezeCollectionView)
        
        contentScrollView.addSubview(contentMoveableCollectionView)
        contentScrollView.addSubview(headMovebleCollectionView)
        
        contentMoveableCollectionView.contentInset = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0)
        contentFreezeCollectionView.contentInset = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0)
        
        contentScrollView.layer.addSublayer(veritcalShadow)
    }
    
    fileprivate func showVerticalDivideShadowLayer() {
        if veritcalShadow.path == nil {
            let path = UIBezierPath()
            let heigh = contentScrollView.contentSize.height + headFreezeCollectionView.contentSize.height
            path.move(to: CGPoint.init(x: 0, y:0))
            path.addLine(to: CGPoint.init(x: 0, y: heigh))
            path.lineWidth = 0.5
            veritcalShadow.path = path.cgPath
        }
    }
    
    fileprivate func dismissVerticalDivideShadowLayer() {
        veritcalShadow.path = nil
    }
    
    fileprivate func setUpFrames() {
        let width = bounds.size.width
        let height = bounds.size.height
        
        if headerTitles != nil {
            headFreezeCollectionView.frame = CGRect.init(x: 0, y: 0, width: dataManager.freezeWidth, height: headerHeight)
            contentFreezeCollectionView.frame = CGRect.init(x: 0, y: headerHeight, width: dataManager.freezeWidth, height: height - headerHeight)
            
            contentScrollView.frame = CGRect.init(x: dataManager.freezeWidth, y: 0, width: width - dataManager.freezeWidth, height: height)
            contentScrollView.contentSize = CGSize.init(width: dataManager.slideWidth, height: height)
            
            headMovebleCollectionView.frame = CGRect.init(x: 0, y: 0, width: dataManager.slideWidth, height: headerHeight)
            contentMoveableCollectionView.frame = CGRect.init(x: 0, y: headerHeight, width: dataManager.slideWidth, height: height - headerHeight)
            // 添加阴影，此时frame已确定
            headFreezeCollectionView.addShoadowToBottomSide()
            headMovebleCollectionView.addShoadowToBottomSide()
            
        } else {
            
            contentFreezeCollectionView.frame = CGRect.init(x: 0, y: 0, width: dataManager.freezeWidth, height: height - headerHeight)
            
            contentScrollView.frame = CGRect.init(x: dataManager.freezeWidth, y: 0, width: width - dataManager.freezeWidth, height: height)
            contentScrollView.contentSize = CGSize.init(width: dataManager.slideWidth, height: height)
            
            contentMoveableCollectionView.frame = CGRect.init(x: 0, y: 0, width: dataManager.slideWidth, height: height - headerHeight)
        }
        if showNoDataView {
            self.alertLabel.isHidden = self.contentData?.count == 0 ? false: true
        }
    }
    
    //MARK: - 懒加载
    fileprivate let dataManager: AKExcelDataManager = AKExcelDataManager()
    
    fileprivate lazy var headFreezeCollectionView = UICollectionView.init(delelate: self, datasource: self)
    fileprivate lazy var headMovebleCollectionView = UICollectionView.init(delelate: self, datasource: self)
    fileprivate lazy var contentFreezeCollectionView = UICollectionView.init(delelate: self, datasource: self)
    fileprivate lazy var contentMoveableCollectionView = UICollectionView(delelate: self, datasource: self)
    
    fileprivate lazy var contentScrollView: UIScrollView = {
        let slideScrollView = UIScrollView()
        slideScrollView.bounces = false
        slideScrollView.showsHorizontalScrollIndicator = true
        slideScrollView.delegate = self
        
        return slideScrollView
    }()
    
}

//MARK: - UICollectionView Delegate & DataSource & collectionPrivate
extension DUExcelView {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == headMovebleCollectionView || collectionView == headFreezeCollectionView {
            return 1
        }
        return (contentData?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == headFreezeCollectionView || collectionView == contentFreezeCollectionView {
            return leftFreezeColumn
        } else {
            if let firstBodyData = self.contentData?.first {
                
                if let pros = properties {
                    return pros.count - leftFreezeColumn
                }
                let slideColumn = (firstBodyData.propertyNames().count) - leftFreezeColumn;
                return slideColumn
            }else{
                return 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AKCollectionViewCellIdentifier, for: indexPath) as! AKExcelCollectionViewCell
        cell.horizontalMargin = self.textMargin
        self.configCells(collectionView: collectionView, cell: cell, indexPath: indexPath)
        
        return cell
    }
    
    private func configCells(collectionView:UICollectionView ,cell:AKExcelCollectionViewCell ,indexPath: IndexPath) {
        var targetIndexPath = indexPath
        
        if collectionView == headFreezeCollectionView {
            cell.textLabel.text = headerTitles?[leftFreezeColumn - 1]
            cell.backgroundColor = headerBackgroundColor
            cell.textLabel.font = headerTextFontSize
        } else if collectionView == headMovebleCollectionView {
            if indexPath.item + leftFreezeColumn < (headerTitles?.count)! {
                cell.backgroundColor = headerBackgroundColor
                cell.textLabel.text = headerTitles?[indexPath.item + leftFreezeColumn]
                cell.textLabel.font = headerTextFontSize
                targetIndexPath = NSIndexPath.init(item: indexPath.item + leftFreezeColumn, section: indexPath.section) as IndexPath
                
            }
        } else if (collectionView == contentFreezeCollectionView) {
            let text = dataManager.contentFreezeData[indexPath.section][indexPath.item];
            cell.textLabel.text = text;
            cell.textLabel.textColor = contentTextColor;
            cell.textLabel.font = contentTextFontSize;
            cell.contentBackgroundColor = indexPath.section % 2 == 0 ? oddLineBackgroundColor: evenLineBackgroundColor
            targetIndexPath = NSIndexPath.init(item: indexPath.item, section: indexPath.section + 1) as IndexPath
            
        } else {
            let text = dataManager.contentSlideData[indexPath.section][indexPath.item];
            cell.textLabel.text = text;
            cell.textLabel.textColor = contentTextColor;
            cell.textLabel.font = contentTextFontSize;
            cell.contentBackgroundColor = indexPath.section % 2 == 0 ? oddLineBackgroundColor: evenLineBackgroundColor
            targetIndexPath = NSIndexPath.init(item: indexPath.item + leftFreezeColumn, section: indexPath.section + 1) as IndexPath
        }
        
        customViewInCell(cell: cell, indexPath: targetIndexPath)
        attributeStringInCell(cell: cell, indexPath: targetIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == headFreezeCollectionView, dataManager.freezeItemSize.count > 0 {
            let size = NSCoder.cgSize(for: dataManager.freezeItemSize[indexPath.item]);
            return CGSize(width: size.width, height: headerHeight)
        } else if collectionView == headMovebleCollectionView, dataManager.slideItemSize.count > 0 {
            let size = NSCoder.cgSize(for: dataManager.slideItemSize[indexPath.item]);
            return CGSize(width: size.width, height: headerHeight)
        } else if collectionView == contentFreezeCollectionView, dataManager.freezeItemSize.count > 0 {
            return NSCoder.cgSize(for: dataManager.freezeItemSize[indexPath.item]);
        } else if dataManager.slideItemSize.count > 0 {
            return NSCoder.cgSize(for: dataManager.slideItemSize[indexPath.item]);
        } else {
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var targetIndexPath = indexPath
        if collectionView == headFreezeCollectionView {
            
        } else if (collectionView == headMovebleCollectionView) {
            targetIndexPath = NSIndexPath.init(item: indexPath.item + leftFreezeColumn, section: indexPath.section) as IndexPath
        } else if (collectionView == contentFreezeCollectionView) {
            targetIndexPath = NSIndexPath.init(item: indexPath.item, section: indexPath.section + 1) as IndexPath
        } else {
            targetIndexPath = NSIndexPath.init(item: indexPath.item + leftFreezeColumn, section: indexPath.section + 1) as IndexPath
        }
        self.delegate?.excelView?(self, didSelectItemAt: targetIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if itemInsets != nil {
            return itemInsets!
        }
        return UIEdgeInsets.zero
    }
}

//MARK: - UISCrollViewDelegate
extension DUExcelView {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView != contentScrollView {
            contentFreezeCollectionView.contentOffset = scrollView.contentOffset
            contentMoveableCollectionView.contentOffset = scrollView.contentOffset
        } else {
            
            if (scrollView.contentOffset.x > 0) {
                showVerticalDivideShadowLayer()
            } else {
                dismissVerticalDivideShadowLayer()
            }
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            veritcalShadow.transform = CATransform3DMakeTranslation(scrollView.contentOffset.x, 0, 0)
            CATransaction.commit()
        }
    }
}

//MARK: - CollectionView Extension
extension UICollectionView {
    
    /**
     *  遍历构造函数
     */
    convenience init(delelate: UICollectionViewDelegate , datasource: UICollectionViewDataSource){
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.headerReferenceSize = CGSize.init(width: UIScreen.main.bounds.size.width, height: 1)
        
        self.init(frame: CGRect.zero, collectionViewLayout: flowLayout)
        dataSource = datasource
        delegate = delelate
        register(AKExcelCollectionViewCell.self, forCellWithReuseIdentifier: AKCollectionViewCellIdentifier)
        backgroundColor = UIColor.white
        showsVerticalScrollIndicator = false
        translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            self.contentInsetAdjustmentBehavior = .never
        }
    }
}

//MARK: - DUExcelView Delegate Implemention
extension DUExcelView {
    
    fileprivate func customViewInCell(cell: AKExcelCollectionViewCell , indexPath: IndexPath) {
        let customView = delegate?.excelView?(self, viewAt: indexPath)
        cell.customView = customView
    }
    
    fileprivate func attributeStringInCell(cell: AKExcelCollectionViewCell , indexPath: IndexPath) {
        let attributeString = delegate?.excelView?(self, attributedStringAt: indexPath)
        if attributeString != nil {
            cell.textLabel.attributedText = attributeString
        }
    }
}

extension UIView {
    
    /// 设置view单边底部阴影，此种设置方法不会产生其他边阴影偏移
    /// - Parameter color: 阴影颜色
    /// - Parameter opacity: 阴影透明度
    /// - Parameter radius: 阴影半径
    /// - Parameter offsetY: 底部阴影偏移量
    func addShoadowToBottomSide(color: UIColor = UIColor.black,
                                opacity: Float = 0.5,
                                radius: CGFloat = 3,
                                offset: CGFloat = 3) {
        layer.masksToBounds = false
        backgroundColor = UIColor.white
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowOffset = CGSize(width: 0, height: offset)
        let bezierPath2 = UIBezierPath(rect: CGRect(x: 0, y: bounds.height-offset/2, width: bounds.width, height: offset))
        layer.shadowPath = bezierPath2.cgPath
    }
}

