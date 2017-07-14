//
//  ChartsViewController.swift
//  Envatolitics
//
//  Created by Andre Podberezniak on 19/09/15.
//  Copyright © 2015 Transparent Ideas. All rights reserved.
//

import UIKit
import OAuthSwift
import Charts

class ChartsViewController: UIViewController, ChartViewDelegate {
   
    
    @IBOutlet weak var chartView: LineChartView!
    var dataSet: LineChartDataSet!
    
    var sales: [EnvatoSalesByMonth] = [EnvatoSalesByMonth]()
    
    override func viewDidLoad() {
        chartView.delegate = self
        
        let range = sales.startIndex ..< sales.endIndex.advanced(by: -13)
        
        sales.removeSubrange(range)
        sales.removeLast()
        
        var entries: [ChartDataEntry] = Array()
        var xValues: [String] = Array()
        
        for (i, sale) in sales.enumerated(){
            let formatter = DateFormatter();
            formatter.dateFormat = "MMM"
            entries.append(ChartDataEntry.init(value: Double(sale.sales)!, xIndex: i, data: sale.earnings))
            xValues.append(formatter.string(from: sale.month))
        }
        
        dataSet = LineChartDataSet(yVals: entries, label: "First unit test data")
        
        dataSet.lineWidth = 0;
        dataSet.circleRadius = 0;
        
        dataSet.drawValuesEnabled = true
        dataSet.drawCubicEnabled = true
        dataSet.cubicIntensity = 0.05
        dataSet.drawFilledEnabled = true
        dataSet.fillColor = UIColor.blue
        dataSet.fillAlpha = 0.3
        
        if chartView != nil {
            chartView.drawGridBackgroundEnabled = false
            chartView.xAxis.drawAxisLineEnabled = false
            chartView.xAxis.drawGridLinesEnabled = false
            chartView.xAxis.drawLabelsEnabled = true
            chartView.xAxis.labelPosition = .bottom
            chartView.drawBordersEnabled = false
            chartView.leftAxis.enabled = false
            chartView.rightAxis.enabled = false
            chartView.legend.enabled = false
            chartView.data = LineChartData(xVals: xValues, dataSet: dataSet)
            chartView.animate(yAxisDuration: TimeInterval(2), easingOption: ChartEasingOption.easeInOutSine)
        }
        
    }
}
