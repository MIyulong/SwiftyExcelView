//
//  ViewController.swift
//  AKExcelDemo
//
//  Created by 吴莎莉 on 2017/5/31.
//  Copyright © 2017年 alasku. All rights reserved.
//

import UIKit

let AKScreenWidth = UIScreen.main.bounds.size.width
let AKScreenHeight = UIScreen.main.bounds.size.height


class ViewController: UIViewController , AKExcelViewDelegate {

    var excelView : AKExcelView?
    var testButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "我的统计"
        if #available(iOS 11.0, *) {
            
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }

        addReloadButton()
        addExcelView()
    }
    
    func addReloadButton() {
        let btn = UIButton(frame: CGRect(x: UIScreen.main.bounds.width-10-70, y: UIScreen.main.bounds.height-80-45, width: 70, height: 45))
        btn.setTitle("Reload", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor = UIColor.red
        btn.addTarget(self, action: #selector(reloadTaped), for: .touchUpInside)
        view.addSubview(btn)
        testButton = btn
    }
    
    @objc func reloadTaped(){
        excelView?.removeFromSuperview()
        addExcelView()
    }
    
    func addExcelView() {
        let excelView : AKExcelView = AKExcelView.init(frame: CGRect.init(x: 0, y: 20, width: AKScreenWidth, height: AKScreenHeight - 20))
        // 自动滚到最近的一列
        excelView.autoScrollToNearItem = true
        // 设置表头背景色
        excelView.headerBackgroundColor = UIColor.white
        // 设置表头
        excelView.headerTitles = ["货号","品名","规格","数量","说明"]
        // 设置间隙
        excelView.textMargin = 20
        // 设置左侧冻结栏数
        excelView.leftFreezeColumn = 0
        // 设置对应模型里面的属性  按顺序
        excelView.properties = ["productNo","productName","specification","quantity","note"]
        excelView.delegate = self
        // 指定列 设置 指定宽度  [column:width,...]
//        excelView.columnWidthSetting = [3:180]
        excelView.itemHeight = 30
        excelView.headerHeight = 60
        excelView.showNoDataView = true
        var arrM = [Model]()
        autoreleasepool {
            for i in 0 ..< 200 {
                let model = Model()
                model.productNo = String.init("货号 - \(i)")
                model.productName = String.init("品名 - \(i)")
                model.specification = String.init("规格  - \(i)")
                model.quantity = String.init("数量 - \(i)")
                model.note = String.init("说明说明说明说明说明说明说明说明 - \(i)")
                model.pro = "others ..."
                
                arrM.append(model)
            }
        }
        excelView.contentData = arrM
        view.insertSubview(excelView, belowSubview: testButton!)
        
        //excelView.reloadData()
        
        excelView.reloadDataCompleteHandler {
            print(" reload complete")
            
        }
        
        self.excelView = excelView
    }
}

//MARK: - AKExcelViewDelegate

extension UIViewController {
    // 代理方法 点击cell
    @objc func excelView(_ excelView: AKExcelView, didSelectItemAt indexPath: IndexPath) {
        print("section: \(indexPath.section)  -  item: \(indexPath.item)")
        
        let alertVc = UIAlertController.init(title: "Title", message: "tap section: \(indexPath.section)  -  item: \(indexPath.item)", preferredStyle: .alert)
        let action = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        alertVc.addAction(action)
        self.present(alertVc, animated: true, completion: nil)
    }
    
    // 自定义指定indepath的cell
    @objc func excelView(_ excelView: AKExcelView, viewAt indexPath: IndexPath) -> UIView? {
        if indexPath.section == 5 && indexPath.row == 3 {

            let customView = UIView()
            customView.backgroundColor = UIColor.blue

            return customView
        }
        return nil
    }
    
}




