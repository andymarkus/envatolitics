//
//  ViewController.swift
//  Envatolitics
//
//  Created by Andre Podberezniak on 05/08/15.
//  Copyright © 2015 Transparent Ideas. All rights reserved.
//

import UIKit
import OAuthSwift
import Charts

class MainViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var salesButton: UIButton!
   
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var number = 0
    var sales = [EnvatoSale]()
    var monthlySales = [EnvatoSalesByMonth]()
    @IBOutlet weak var chartView: LineChartView!
    var dataSet: LineChartDataSet!
    
    
    fileprivate func graphUpdate(){
    
        let range = monthlySales.startIndex ..< monthlySales.endIndex.advanced(by: -13)
        
        monthlySales.removeSubrange(range)
        monthlySales.removeLast()
        
   
        var xValues: [String] = Array()
        dataSet = LineChartDataSet()
        dataSet.lineWidth = 0;
        dataSet.circleRadius = 0;
        dataSet.drawValuesEnabled = true
        dataSet.mode = LineChartDataSet.Mode.cubicBezier
        dataSet.cubicIntensity = 0.4
        dataSet.valueTextColor = UIColor.white
        dataSet.drawFilledEnabled = true
        dataSet.fillColor = UIColor(colorLiteralRed: 12, green: 135, blue: 133, alpha: 1.0)

        for (i, sale) in monthlySales.enumerated(){
            let formatter = DateFormatter();
            formatter.dateFormat = "MMM"
            dataSet.addEntry(ChartDataEntry.init(value: Double(sale.sales)!, xIndex: i, data: sale.earnings))
            xValues.append(formatter.string(from: sale.month))
        }
        

        
        
        if chartView != nil {
            chartView.data = LineChartData(xVals: xValues, dataSet: dataSet)
            chartView.animate(yAxisDuration: TimeInterval(2), easingOption: ChartEasingOption.easeInOutSine)
            
        }
    
    }
    
    let tokenStorage = UserDefaults.standard
    
    fileprivate func vibrancyEffectView(forBlurEffectView blurEffectView:UIVisualEffectView) -> UIVisualEffectView {
        let vibrancy = UIVibrancyEffect(blurEffect: blurEffectView.effect as! UIBlurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancy)
        vibrancyView.frame = blurEffectView.bounds
        vibrancyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return vibrancyView
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        chartView.delegate = self
        
        if (chartView != nil){
            chartView.backgroundColor = UIColor.clear
            chartView.drawGridBackgroundEnabled = false
            chartView.xAxis.drawAxisLineEnabled = false
            chartView.xAxis.drawGridLinesEnabled = true
            chartView.xAxis.gridColor = UIColor(colorLiteralRed: 255, green: 255, blue: 255, alpha: 0.3)
            chartView.xAxis.gridLineDashPhase = 1
            chartView.xAxis.drawLabelsEnabled = true
            chartView.xAxis.enabled = true
            chartView.xAxis.labelTextColor = UIColor.white
            chartView.xAxis.labelPosition = .bottom
            chartView.xAxis.labelTextColor = UIColor.white
            chartView.drawBordersEnabled = false
            chartView.leftAxis.enabled = false
            chartView.leftAxis.drawAxisLineEnabled = false
            chartView.leftAxis.drawGridLinesEnabled = false
           
            chartView.descriptionText = "Sales by Months"
            chartView.descriptionTextColor = UIColor.white
            chartView.leftAxis.labelTextColor = UIColor.white
           
            chartView.rightAxis.enabled = false
            chartView.legend.enabled = false
        }
        
        salesButton.isEnabled = false;
        salesButton.layer.cornerRadius = 3
        salesButton.clipsToBounds = true
        NotificationCenter.default.addObserver(self, selector:"applicationWillResignActiveNotification", name:
            NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        self.navigationController?.isNavigationBarHidden = true
        
        let lightBlur = UIBlurEffect(style: .light)
        let lightBlurView = UIVisualEffectView(effect: lightBlur)
        self.view.addSubview(lightBlurView)
    
        let blurAreaAmount = self.view.bounds.height
        var remainder: CGRect
      
        (lightBlurView.frame, remainder) = self.view.bounds.divided(atDistance: blurAreaAmount, from: CGRectEdge.maxYEdge)
        lightBlurView.frame.makeIntegralInPlace()
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let svc = segue.destination as? SalesTableViewController{
            if let identifier = segue.identifier {
                switch identifier{
                case "showSales":
                    svc.sales = self.sales
                default : svc.sales = []
                }
            }
        }
        
        if let cvc = segue.destination as? ChartsViewController{
            if let identifier = segue.identifier {
                switch identifier{
                case "showCharts":
                    cvc.sales = self.monthlySales
                default:  cvc.sales = []
                }
            }
        }
    }
    
    func formatCurrency(_ string: String) -> String{
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        formatter.locale = Locale(localeIdentifier: "en_US")
        let numberFromField = (NSString(string: string).doubleValue)
        return formatter.string(from: numberFromField)!
    }
   
    func applicationWillResignActiveNotification() {
        
        if let expTime = tokenStorage.value(forKey: Authentication.constants.storageTokenExpirationTimeStamp) as? TimeInterval {
            
            if expTime <= ( Date().timeIntervalSince1970 ) {
                Authentication.authorize(showData)
            } else {
                showData()
            }
            
        } else {
            Authentication.authorize(showData)
        }
    }
    
    func ParseLatestSalesData(_ data: AnyObject){
        if let sales = data as? Array<AnyObject>{
            for sale in sales {
                self.sales.append(EnvatoSale(data: sale))
            }
        }
    }
    
    func ParseLatestSalesByMonthData(_ data: AnyObject){
        if let validData = data as? Dictionary<String, AnyObject>{
            if let salesByMonthData = validData["earnings-and-sales-by-month"] as? Array<AnyObject>{
                for sale in salesByMonthData {
                    self.monthlySales.append(EnvatoSalesByMonth(data: sale))
                }
                
            }
            
            self.graphUpdate()
            self.showUI()
            
        }
        
    }
    
    func showData(){
        DispatchQueue.main.async { () -> Void in
            Envato.getData(self.ParseAccountData)
        }
        
         DispatchQueue.main.async { () -> Void in
            Envato.getSales(self.ParseLatestSalesData)
        }
        
        DispatchQueue.main.async { () -> Void in
            Envato.getSalesByMonth(self.ParseLatestSalesByMonthData)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        Authentication.initialize();
        
        if let expTime = tokenStorage.value(forKey: Authentication.constants.storageTokenExpirationTimeStamp) as? TimeInterval {
            if expTime <= ( Date().timeIntervalSince1970 ) {
                Authentication.authorize(showData)
            } else {
                showData()
            }
            
        } else {
           Authentication.authorize(showData)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func connect(_ sender: AnyObject) {
        Authentication.authorize(showData)
    }
    
    
    func getDataFromUrl(_ urL:URL, completion: ((_ data: Data?) -> Void)) {
        URLSession.shared.dataTask(with: urL, completionHandler: { (data, response, error) in
            completion(data: data)
            }) .resume()
    }
    
    func downloadImage(_ url:URL){
        getDataFromUrl(url) { data in
            DispatchQueue.main.async {
                if let path = self.saveThumb(data!) {
                    self.tokenStorage.setValue(path, forKey: "pathForThumb")
                }
            }
        }
    }
    

    func saveThumb(_ data: Data) -> String?{
        if let thumbData = UIImagePNGRepresentation( UIImage(data: data)! ) {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0]
            let fileName = "\(documentsDirectory)/thumb.png"
            try? thumbData.write(to: URL(fileURLWithPath: fileName), options: [.atomic])
            self.avatarImageView.image = UIImage(contentsOfFile: fileName)
            return "thumb.png"
        }
        return ""
    }
    
    fileprivate func showUI(){
        salesButton.isEnabled = true;
        for view in self.view.subviews {
            if view.isKind(of: UIVisualEffectView.self){
                UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseOut, animations: {
                    view.alpha = 0
                    }, completion: { finished in
                        view.removeFromSuperview()
                })
            }
        }
    }
    
    func ParseAccountData(_ data:AnyObject){
        if let validData = data as? Dictionary<String, AnyObject>{
            
            if let readableData = validData["account"] as? Dictionary<String, String>{
                
                if let hm = readableData["firstname"] {
                    
                    self.nameLabel.text = hm + " " + readableData["surname"]!
                }
                if let amount = readableData["balance"] {
                    self.amountLabel.text = formatCurrency(amount)
                }
                
                print(readableData["image"])
                
                if let savedThumb = self.tokenStorage.value(forKey: "pathForThumb") {
                    
                    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                    let documentsDirectory = paths[0]
                    let fileName = "\(documentsDirectory)/\(savedThumb)"
                    
                    if (FileManager.default.fileExists(atPath: fileName)){
                        self.avatarImageView.image = UIImage(contentsOfFile: fileName)
                    } else {
                        if let imageURL = URL(string: readableData["image"]!){
                            self.downloadImage(imageURL)
                        }

                    }
                    
                } else if let imageURL = URL(string: readableData["image"]!){
                    self.downloadImage(imageURL)
                }
            }
            
            
            
        }
    }

}

