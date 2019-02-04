//
//  MeasurementController.swift
//  AngleMeasure_seniorDesign
//
//  Created by Nathan Greene on 1/18/19.
//  Copyright © 2019 Nathan Greene. All rights reserved.
//

import UIKit
import Charts

class MeasurementController: BaseGraphController {
    
    var measurement: Measurement?
    
    lazy var chartView: LineChartView = {
        let chartView = LineChartView()
        chartView.delegate = self
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = true
        chartView.translatesAutoresizingMaskIntoConstraints = false
        return chartView
    }()
    
//    lazy var sliderX : UISlider = {
//        let slider = UISlider()
//        slider.translatesAutoresizingMaskIntoConstraints = false
//        slider.addTarget(self, action: #selector(slidersValueChanged), for: .valueChanged)
//        return slider
//    }()
//    lazy var sliderY : UISlider = {
//        let slider = UISlider()
//        slider.translatesAutoresizingMaskIntoConstraints = false
//        slider.addTarget(self, action: #selector(slidersValueChanged), for: .valueChanged)
//        return slider
//    }()
//    @objc func slidersValueChanged() {
//        print(sliderX.value)
//        sliderTextX.text = "\(Int(sliderX.value))"
//        sliderTextY.text = "\(Int(sliderY.value))"
//
//        self.updateChartData()
//    }
    
//    var sliderTextX: UITextField = {
//        let tf = UITextField()
//        tf.translatesAutoresizingMaskIntoConstraints = false
//        return tf
//    }()
//    var sliderTextY: UITextField = {
//        let tf = UITextField()
//        tf.translatesAutoresizingMaskIntoConstraints = false
//        return tf
//    }()
    
    lazy var rangeOfMotionLabel: UILabel = {
        let label = UILabel()
        if let rangeOfMotion = measurement?.rangeOfMotion {
            let formattedRoM = String(format: "%.2f", rangeOfMotion)
            label.text = "Range of Motion: \(formattedRoM)"
        } else {
            label.text = "Range of Motion: n/a)"
        }
        label.textColor = .darkBrown
        return label
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Information"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupChart()
        updateChartData()
    }
    func setupUI() {
        
        view.backgroundColor = .white
//        let paleBlueBackground = setupPaleBlueBackground(height: 500)
        
        view.addSubview(rangeOfMotionLabel)
        _ = rangeOfMotionLabel.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 50)
        
//        view.addSubview(sliderX)
//        _ = sliderX.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 4, leftConstant: 8, bottomConstant: 8, rightConstant: 8, widthConstant: 0, heightConstant: 50)
        
        view.addSubview(chartView)
        _ = chartView.anchor(rangeOfMotionLabel.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    func setupChart() {
        self.options = [.toggleValues,
                        .toggleFilled,
                        .toggleCircles,
                        .toggleCubic,
                        .toggleHorizontalCubic,
                        .toggleIcons,
                        .toggleStepped,
                        .toggleHighlight,
                        .animateX,
                        .animateY,
                        .animateXY,
                        .saveToGallery,
                        .togglePinchZoom,
                        .toggleAutoScaleMinMax,
                        .toggleData]
        
        // x-axis limit line
        let llXAxis = ChartLimitLine(limit: 10, label: "Index 10")
        llXAxis.lineWidth = 4
        llXAxis.lineDashLengths = [10, 10, 0]
        llXAxis.labelPosition = .rightBottom
        llXAxis.valueFont = .systemFont(ofSize: 10)
        
        chartView.xAxis.gridLineDashLengths = [10, 10]
        chartView.xAxis.gridLineDashPhase = 0
        
        let ll1 = ChartLimitLine(limit: 150, label: "Upper Limit")
        ll1.lineWidth = 4
        ll1.lineDashLengths = [5, 5]
        ll1.labelPosition = .rightTop
        ll1.valueFont = .systemFont(ofSize: 10)
        
        let ll2 = ChartLimitLine(limit: -30, label: "Lower Limit")
        ll2.lineWidth = 4
        ll2.lineDashLengths = [5,5]
        ll2.labelPosition = .rightBottom
        ll2.valueFont = .systemFont(ofSize: 10)
        
        let leftAxis = chartView.leftAxis
        leftAxis.removeAllLimitLines()
        leftAxis.addLimitLine(ll1)
        leftAxis.addLimitLine(ll2)
        leftAxis.axisMaximum = 200
        leftAxis.axisMinimum = -50
        leftAxis.gridLineDashLengths = [5, 5]
        leftAxis.drawLimitLinesBehindDataEnabled = true
        
        chartView.rightAxis.enabled = false
        
        //[_chartView.viewPortHandler setMaximumScaleY: 2.f];
        //[_chartView.viewPortHandler setMaximumScaleX: 2.f];
        
        let marker = BalloonMarker(color: UIColor(white: 180/255, alpha: 1),
                                   font: .systemFont(ofSize: 12),
                                   textColor: .white,
                                   insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        marker.chartView = chartView
        marker.minimumSize = CGSize(width: 80, height: 40)
        chartView.marker = marker
        
        chartView.legend.form = .line
        
//        sliderX.value = 45
//        sliderY.value = 100
//        slidersValueChanged()
        
        chartView.animate(xAxisDuration: 2.5)
    }
    
    override func updateChartData() {
        if self.shouldHideData {
            chartView.data = nil
            return
        }
        
        self.setDataCount(Int(40), range: UInt32(100)) // count and range
    }
    
    func setDataCount(_ count: Int, range: UInt32) {
        let values = (0..<count).map { (i) -> ChartDataEntry in
            let val = Double(arc4random_uniform(range) + 3)
            let icon = NSUIImage(named: "plus")
            return ChartDataEntry(x: Double(i), y: val, icon: icon)
        }
        
        let set1 = LineChartDataSet(values: values, label: "DataSet 1")
        set1.drawIconsEnabled = false
        
        set1.lineDashLengths = [5, 2.5]
        set1.highlightLineDashLengths = [5, 2.5]
        set1.setColor(.black)
        set1.setCircleColor(.black)
        set1.lineWidth = 1
        set1.circleRadius = 3
        set1.drawCircleHoleEnabled = false
        set1.valueFont = .systemFont(ofSize: 9)
        set1.formLineDashLengths = [5, 2.5]
        set1.formLineWidth = 1
        set1.formSize = 15
        
        let gradientColors = [ChartColorTemplates.colorFromString("#00ff0000").cgColor,
                              ChartColorTemplates.colorFromString("#ffff0000").cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        
        set1.fillAlpha = 1
        set1.fill = Fill(linearGradient: gradient, angle: 90) //.linearGradient(gradient, angle: 90)
        set1.drawFilledEnabled = true
        
        let data = LineChartData(dataSet: set1)
        
        chartView.data = data
    }
    
    override func optionTapped(_ option: Option) {
        switch option {
        case .toggleFilled:
            for set in chartView.data!.dataSets as! [LineChartDataSet] {
                set.drawFilledEnabled = !set.drawFilledEnabled
            }
            chartView.setNeedsDisplay()
            
        case .toggleCircles:
            for set in chartView.data!.dataSets as! [LineChartDataSet] {
                set.drawCirclesEnabled = !set.drawCirclesEnabled
            }
            chartView.setNeedsDisplay()
            
        case .toggleCubic:
            for set in chartView.data!.dataSets as! [LineChartDataSet] {
                set.mode = (set.mode == .cubicBezier) ? .linear : .cubicBezier
            }
            chartView.setNeedsDisplay()
            
        case .toggleStepped:
            for set in chartView.data!.dataSets as! [LineChartDataSet] {
                set.mode = (set.mode == .stepped) ? .linear : .stepped
            }
            chartView.setNeedsDisplay()
            
        case .toggleHorizontalCubic:
            for set in chartView.data!.dataSets as! [LineChartDataSet] {
                set.mode = (set.mode == .cubicBezier) ? .horizontalBezier : .cubicBezier
            }
            chartView.setNeedsDisplay()
            
        default:
            super.handleOption(option, forChartView: chartView)
        }
    }
    
//    func slidersValueChanged(_ sender: Any?) {
//        sliderTextX.text = "\(Int(sliderX.value))"
//        sliderTextY.text = "\(Int(sliderY.value))"
//
//        self.updateChartData()
//    }
}
