//
//  TimeSectionSelectViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 7/8/16.
//  Copyright © 2016 Windward. All rights reserved.
//
// swiftlint:disable force_unwrapping

import UIKit

class TimeSectionSelectViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var startTimeLabel: UILabel!
    @IBOutlet fileprivate weak var endTimeLabel: UILabel!
    @IBOutlet fileprivate weak var startTimeButton: UIButton!
    @IBOutlet fileprivate weak var endTimeButton: UIButton!
    @IBOutlet fileprivate weak var startTimeBg: UIView!
    @IBOutlet fileprivate weak var endTimeBg: UIView!
    
    @IBOutlet fileprivate weak var filterAllButton: UIButton!
    @IBOutlet fileprivate weak var filterLastThreeDayButton: UIButton!
    @IBOutlet fileprivate weak var filterLastWeekButton: UIButton!
    @IBOutlet fileprivate weak var filterLastMonthButton: UIButton!
    @IBOutlet fileprivate weak var filterLastThreeMonthButton: UIButton!
    @IBOutlet fileprivate weak var filterLastYearButton: UIButton!
    
    @IBOutlet fileprivate weak var bottomFilterButton: UIButton!
    
    @IBOutlet fileprivate weak var txtField: UITextField!
    
    fileprivate var inputStartTime: Bool = true
    
    fileprivate var timeView: UIDatePicker!
    fileprivate let bgView: UIView = UIView()
    
    var navTitle: String?
    
    var startTime: String?
    var endTime: String?
    var timeSectionSelected: TimeSectionPart = .undefined
    
    var completeBlock: ((TimeSectionPart, String?, String?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.commonBgColor()
        if let navTitle = navTitle {
            navigationItem.title = navTitle
        } else {
            navigationItem.title = "选择日期"
        }
        for btn in [startTimeButton, endTimeButton] {
            btn?.addTarget(self, action: #selector(self.selectTime(_:)), for: .touchUpInside)
        }
        for view in [startTimeBg, endTimeBg] {
            view?.layer.masksToBounds = true
            view?.layer.cornerRadius = 8
        }
        
        for btn in [filterAllButton, filterLastThreeDayButton, filterLastWeekButton, filterLastMonthButton, filterLastThreeMonthButton, filterLastYearButton] {
            btn?.layer.masksToBounds = true
            btn?.layer.cornerRadius = 8
            
            btn?.setTitleColor(.black, for: UIControlState())
            btn?.setTitleColor(.white, for: .selected)
            btn?.setBackgroundImage(Utility.createImageWithColor(.white), for: UIControlState())
            btn?.setBackgroundImage(UIImage(named: "CommonBlueBg"), for: .selected)
            btn?.addTarget(self, action: #selector(self.selectTimeSectionAction(_:)), for: .touchUpInside)
        }
        
        bottomFilterButton.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
        let timeViewBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 240 + 44))
        timeViewBg.backgroundColor = UIColor.commonBgColor()
        
        let timeConfirmBtn = UIButton(type: .custom)
        timeConfirmBtn.setTitle("确认", for: UIControlState())
        timeConfirmBtn.setTitleColor(UIColor.commonBlueColor(), for: UIControlState())
        timeConfirmBtn.frame = CGRect(x: screenWidth - 80, y: 0, width: 80, height: 44)
        timeConfirmBtn.addTarget(self, action: #selector(self.confirmTimeAction), for: .touchUpInside)
        timeViewBg.addSubview(timeConfirmBtn)
        
        timeView = UIDatePicker(frame: CGRect(x: 0, y: 44, width: screenWidth, height: 240))
        timeView.datePickerMode = .date
        timeView.backgroundColor = UIColor.white
        timeViewBg.addSubview(timeView)
        
        txtField.inputView = timeViewBg
        txtField.delegate = self
        
        bgView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        bgView.backgroundColor = UIColor.black
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.resignTxtFiled)))
        bgView.alpha = 0.7
        startTimeLabel.text = Date().toString()
        endTimeLabel.text = Date().toString()
        switch timeSectionSelected {
        case .undefined:
            guard var startTime = startTime else {return}
            guard var endTime = endTime else {return}
            if !startTime.isEmpty && endTime.isEmpty {
                startTimeLabel.text = startTime
                endTimeLabel.text = endTime
            } else {
                startTime = Date().toString()
                endTime = Date().toString()
            }
        case .all:
            filterAllButton.isSelected = true
        case .lastThreeDays:
            filterLastThreeDayButton.isSelected = true
        case .lastWeek:
            filterLastWeekButton.isSelected = true
        case .lastMonth:
            filterLastMonthButton.isSelected = true
        case .lastThreeMonths:
            filterLastThreeMonthButton.isSelected = true
        case .lastYear:
            filterLastYearButton.isSelected = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func resignTxtFiled() {
        txtField.resignFirstResponder()
        bgView.removeFromSuperview()
    }
    
    func selectTime(_ btn: UIButton) {
        if btn == startTimeButton {
            inputStartTime = true
        } else if btn == endTimeButton {
            inputStartTime = false
        }
        txtField.becomeFirstResponder()
    }
    
    func clearButtonSelection() {
        timeSectionSelected = .undefined
        
        for btn in [filterAllButton, filterLastThreeDayButton, filterLastWeekButton, filterLastMonthButton, filterLastThreeMonthButton, filterLastYearButton] {
            btn?.isSelected = false
        }
    }
    
    func selectTimeSectionAction(_ btn: UIButton) {
        clearButtonSelection()
        btn.isSelected = true
        
        switch btn {
        case filterAllButton:
            timeSectionSelected = .all
        case filterLastThreeDayButton:
            timeSectionSelected = .lastThreeDays
        case filterLastWeekButton:
            timeSectionSelected = .lastWeek
        case filterLastMonthButton:
            timeSectionSelected = .lastMonth
        case filterLastThreeMonthButton:
            timeSectionSelected = .lastThreeMonths
        case filterLastYearButton:
            timeSectionSelected = .lastYear
        default:
            break
        }
    }
    
    func confirmTimeAction() {
        clearButtonSelection()
        
        Utility.sharedInstance.dateFormatter.dateFormat = "yyyy-MM-dd"
        if inputStartTime {
            startTime = Utility.sharedInstance.dateFormatter.string(from: timeView.date)
            startTimeLabel.text = startTime
        } else {
            endTime = Utility.sharedInstance.dateFormatter.string(from: timeView.date)
            endTimeLabel.text = endTime
        }
        
        resignTxtFiled()
    }
    
    func confirmAction() {
        if let block =  completeBlock {
            if timeSectionSelected == .undefined {
                 Utility.sharedInstance.dateFormatter.dateFormat = "yyyy-MM-dd"
                guard let sTime = Utility.sharedInstance.dateFormatter.date(from: startTimeLabel.text ?? "") else {return}
                guard let eTime = Utility.sharedInstance.dateFormatter.date(from: endTimeLabel.text ?? "") else {return}
                if sTime.compare(eTime) == ComparisonResult.orderedDescending {
                    Utility.showAlert(self, message: "结束时间不可早于开始时间")
                    return
                }
                block(timeSectionSelected, startTimeLabel.text ?? "", endTimeLabel.text ?? "")
            } else {
                    block(timeSectionSelected, startTime, endTime)
            }            
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
}

extension TimeSectionSelectViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        //        textField.inputView = timeView
        //        textField.reloadInputViews()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        view.addSubview(bgView)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //        let timeViewBg = txtField.inputView as! UIDatePicker
        
        //        Utility.sharedInstance.dateFormatter.dateFormat = "HH:mm"
        //        textField.text = Utility.sharedInstance.dateFormatter.stringFromDate(timeView.date)
        
    }
    
}
