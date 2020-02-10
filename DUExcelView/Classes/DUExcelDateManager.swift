//
//  AKExcelDateManager.swift
//  YunYingSwift
//
//  Created by AlasKu on 17/2/10.
//  Copyright © 2017年 innostic. All rights reserved.
//

import UIKit

class AKExcelDataManager: NSObject {
    
    //MARK: - Properties
    /// excelView
    weak var excelView : DUExcelView?
    /// AllExcel Data
    var dataArray : [[String]]?
    /// freezeCollection Width
    var freezeWidth : CGFloat = 0
    /// freezeColectionView cells Size
    var freezeItemSize = [String]()
    /// slideCollectionView Cells Size
    var slideItemSize = [String]()
    /// slideCollectionView Cells Size
    var slideWidth : CGFloat = 0
    /// headFreezeCollectionView Data
    var headFreezeData = [String]()
    /// headSlideCollectionView Data
    var headSlideData = [String]()
    /// contentFreezeCollectionView Data
    var contentFreezeData = [[String]]()
    /// contentSlideCollectionView Data
    var contentSlideData = [[String]]()
    /// slideItemOffSetX
    var slideItemOffSetX = [CGFloat]()
    
    //MARK: - Private Method
    private func loadData() {
        if var datas = excelView?.contentTexts, var titles = excelView?.headerTitles {
            var arrM = [[String]]()
            let c = (datas.first?.count ?? 0) - titles.count
            // 检测到titles少于每行contentData个数时，则用空串补齐tiltes
            if c > 0 {
                for _ in 0..<c {
                    titles.append("")
                }
                // 更新titles
                excelView?.headerTitles = titles
            } else if c < 0 {
                // 则用空串补齐datas
                var emptyStrs: [String] = []
                for _ in 0..<abs(c) {
                    emptyStrs.append("")
                }
                datas = datas.map { return $0 + emptyStrs }
            }
            arrM.append(titles)
            dataArray = arrM
            dataArray! += datas
        }
    }
    
    private func configData() {
        var freezeData = [[String]]()
        var slideData = [[String]]()
        let count = dataArray!.count
        
        for i in 0 ..< count {
            var freezeArray = [String]()
            var slideArray = [String]()
            
            let arr : [String] = dataArray![i]
            let cou = arr.count
            
            for j in 0 ..< cou {
                let value = arr[j];
                if (j < (excelView?.leftFreezeColumn)!) {
                    freezeArray.append(value)
                } else {
                    slideArray.append(value)
                }
            }
            freezeData.append(freezeArray)
            slideData.append(slideArray)
        }
        
        if ((excelView?.headerTitles) != nil) {
            headFreezeData = (dataArray?.first)!
            headSlideData = (dataArray?.first)!
            
            let fArray = Array(freezeData[1..<freezeData.count])
            let sArray = Array(slideData[1..<slideData.count])
            
            contentFreezeData = fArray
            contentSlideData = sArray
        } else {
            contentFreezeData = freezeData;
            contentSlideData = slideData;
        }
    }
    
    private func caculateWidths() {
        var fItemSize = [String]()
        var sItemSize = [String]()
        
        let col = dataArray?.first?.count
        
        for i in 0..<col! {
            var colW = CGFloat()
            for j in 0 ..< (dataArray?.count)! {
                let value = dataArray?[j][i]
                var size = value?.getTextSize(font: (excelView?.contentTextFontSize)!, size: CGSize.init(width: (excelView?.itemMaxWidth)!, height: (excelView?.itemHeight)!))
                if j == 0 {
                    size = value?.getTextSize(font: (excelView?.headerTextFontSize)!, size: CGSize.init(width: (excelView?.itemMaxWidth)!, height: (excelView?.itemHeight)!))
                }
                
                if ((excelView?.columnWidthSetting) != nil) {
                    if let setWidth = excelView?.columnWidthSetting?[i] {
                        size = CGSize.init(width: setWidth, height: (excelView?.itemHeight)!)
                    }
                }
                
                let targetWidth = (size?.width)! + 2 * (excelView?.textMargin)!;
                
                if targetWidth >= colW {
                    colW = targetWidth;
                }
                
                colW = max((excelView?.itemMinWidth)!, min((excelView?.itemMaxWidth)!, colW))
            }
            
            // 滑动scroll节点
            slideItemOffSetX.append(slideWidth)
            
            if (i < (excelView?.leftFreezeColumn)!) {
                fItemSize.append(NSCoder.string(for: CGSize.init(width: colW, height: (excelView?.itemHeight)! - 1)))
                freezeWidth += colW
                
            } else {
                sItemSize.append(NSCoder.string(for: CGSize.init(width: colW, height: (excelView?.itemHeight)! - 1)))
                slideWidth += colW
            }
            
        }
        freezeItemSize = fItemSize
        slideItemSize = sItemSize
    }
    
    //MARK: - Public Method
    func caculateData() {
        loadData()
        configData()
        caculateWidths()
    }
}

//MARK: - String Extension
extension String {
    
    func getTextSize(font:UIFont,size:CGSize) -> CGSize {
        let dic = NSDictionary(object: font, forKey: NSAttributedString.Key.font as NSCopying)
        let stringSize = self.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [NSAttributedString.Key : Any] , context:nil).size
        return stringSize
    }
}
