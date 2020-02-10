# DUExcelView
- This library fork from [SwiftyExcelView](https://github.com/AlasKuNull/SwiftyExcelView.git)，and update for Duapp 
- The example project shows a way to show A Form like Excel in Swift.


## Installation

DUExcelView is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DUExcelView'
```

## Useage
Drag DUExcelCollectionViewCell.swift , DUExcelDateManager.swift and DUExcelView.swift into your project.
Demo shows detail how to use this.

```swift
        let excelView : DUExcelView = DUExcelView(frame: CGRect(x: 0, y: 20, width: DUScreenWidth, height: DUScreenHeight - 20))
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
        //excelView.properties = ["productNo","productName","specification","quantity","note"]
        excelView.delegate = self
        // 指定列 设置 指定宽度  [column:width,...]
        excelView.columnWidthSetting = [3:180]
        excelView.itemHeight = 30
        excelView.headerHeight = 60
        excelView.showNoDataView = true
        var arrM = [[String]]()
        autoreleasepool {
            for i in 0 ..< 200 {
                let str1 = String.init("货号 - \(i)")
                let str2 = String.init("规格  - \(i)")
                let str3 = String.init("品名 - \(i)")
                let str4 = String.init("数量 - \(i)")
                let str5 = String.init("说明说明说明说明说明说明说明说明 - \(i)")
                let str6 = "others ..."
                
                arrM.append([str1, str2, str3, str4, str5, str6])
            }
        }
        excelView.contentTexts = arrM
        view.insertSubview(excelView, belowSubview: testButton!)
        
        //excelView.reloadData()
        
        excelView.reloadDataCompleteHandler {
            print(" reload complete")
            
        }
        
        self.excelView = excelView
    }
        
```

## Author

yulong, 617352010@qq.com

## License

DUAdLauncher is available under the MIT license. See the LICENSE file for more info.
