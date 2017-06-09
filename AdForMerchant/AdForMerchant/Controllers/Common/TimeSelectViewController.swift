//
//  TableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 2/16/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit
import JTCalendar

class TimeSelectViewController: BaseViewController {
    
    @IBOutlet fileprivate var goPreviousArrowImage: UIImageView!
    @IBOutlet fileprivate var goNextArrowImage: UIImageView!
    @IBOutlet fileprivate var calendarMenuView: JTCalendarMenuView!
    @IBOutlet fileprivate var calendarContentView: JTHorizontalCalendarView!
    @IBOutlet fileprivate var txtField: UITextField!
    @IBOutlet fileprivate var confirmBtn: UIButton!
    @IBOutlet fileprivate weak var timeDetailView: UIView!
    
    var timeView: UIDatePicker!
    let bgView: UIView = UIView()
    
    var navTitle: String?
    
    var dateSelected: Date?
    var calendarManager: JTCalendarManager!
    var isTimeDetail: Bool! = true
    var isEndTime = true
    var completeBlock: ((Date) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.commonBgColor()
        if let navTitle = navTitle {
            navigationItem.title = navTitle
        } else {
            navigationItem.title = "选择日期"
        }
        
        confirmBtn.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
        
        calendarManager = JTCalendarManager()
        calendarManager.delegate = self
        
        calendarManager.menuView = calendarMenuView
        calendarManager.contentView = calendarContentView
        
        calendarManager.setDate(Date())
        
        let timeViewBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 240 + 44))
        timeViewBg.backgroundColor = UIColor.commonBgColor()
        
        let timeConfirmBtn = UIButton(type: .custom)
        timeConfirmBtn.setTitle("确认", for: UIControlState())
        timeConfirmBtn.setTitleColor(UIColor.commonBlueColor(), for: UIControlState())
        timeConfirmBtn.frame = CGRect(x: screenWidth - 80, y: 0, width: 80, height: 44)
        timeConfirmBtn.addTarget(self, action: #selector(self.confirmTimeAction), for: .touchUpInside)
        timeViewBg.addSubview(timeConfirmBtn)
        
        timeView = UIDatePicker(frame: CGRect(x: 0, y: 44, width: screenWidth, height: 240))
        timeView.datePickerMode = .time
        timeView.backgroundColor = UIColor.white
        let locale = Locale(identifier: "en_GB")
        timeView.locale = locale
        timeViewBg.addSubview(timeView)
        
        txtField.inputView = timeViewBg
        txtField.delegate = self
        
        bgView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        bgView.backgroundColor = UIColor.black
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.resignTxtFiled)))
        bgView.alpha = 0.7
        
        if let date = dateSelected {
             txtField.text = date.toString("HH:mm")
        } else {
           
        }
        if !isTimeDetail {
            self.timeDetailView.isHidden = true
        }
        
        goPreviousArrowImage.isUserInteractionEnabled = true
        goNextArrowImage.isUserInteractionEnabled = true
        goPreviousArrowImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.goToPreviousPageAction)))
        goNextArrowImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.goToNextPageAction)))
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calendarManager.reload()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

extension TimeSelectViewController {
    func resignTxtFiled() {
        txtField.resignFirstResponder()
        bgView.removeFromSuperview()
    }
    
    func confirmTimeAction() {
        Utility.sharedInstance.dateFormatter.dateFormat = "HH:mm"
        txtField.text = Utility.sharedInstance.dateFormatter.string(from: timeView.date)
        
        resignTxtFiled()
    }
    
    func confirmAction() {
        if let block = completeBlock {
            if dateSelected == nil {
                dateSelected = Date()
            }
            if let dateSelected = dateSelected {
                var day = dateSelected.toString("yyyy-MM-dd")
                Utility.sharedInstance.dateFormatter.dateFormat = "yyyy-MM-dd"
                
                if txtField.text != nil && !(txtField.text ?? "").isEmpty {
                    Utility.sharedInstance.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                    day += " " + (txtField.text ?? "")
                } else {
                    if isEndTime {
                        Utility.sharedInstance.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                        day += " " + "23:59"
                    }
                }
                guard let date = Utility.sharedInstance.dateFormatter.date(from: day) else { return }
                block(date)
            }
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    func goToPreviousPageAction() {
        calendarContentView.loadPreviousPageWithAnimation()
    }
    
    func goToNextPageAction() {
        calendarContentView.loadNextPageWithAnimation()
    }
}

extension TimeSelectViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        view.addSubview(bgView)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
}

extension TimeSelectViewController: JTCalendarDelegate {

    // MARK: - JT Calendar Delegate
    
    func calendar(_ calendar: JTCalendarManager!, prepareMenuItemView menuItemView: UIView!, date: Date!) {
        var text: String = ""
        if let date = date, let xcalendar = calendar.dateHelper.calendar() {
            let comps = xcalendar.dateComponents([.year, .month], from: date)
            if let year = comps.year, let month = comps.month {
                text = "\(year)年 \(month)月"
            }
        }
        
        (menuItemView as? UILabel)?.textColor = UIColor.commonBlueColor()
        (menuItemView as? UILabel)?.text = text
    }
    
    func calendar(_ calendar: JTCalendarManager!, prepareDayView dayView: UIView!) {
        dayView.isHidden = false
        
        guard let dView = dayView as? JTCalendarDayView else { return }
        
        // Test if the dayView is from another month than the page
        // Use only in month mode for indicate the day of the previous or next month
        let today = Date()

        if dView.isFromAnotherMonth {
            dView.isHidden = true
        }
        if calendarManager.dateHelper.date(today, isTheSameDayThan: dView.date) { // Today
            if let selectedDate = dateSelected, calendarManager.dateHelper.date(selectedDate, isTheSameDayThan: dView.date) {
                dView.circleView.isHidden = false
                dView.dotView.isHidden = true
                dView.circleView.backgroundColor = UIColor.commonBlueColor()
                dView.circleView.layer.borderWidth = 0
                dView.dotView.backgroundColor = UIColor.commonBlueColor()
                dView.textLabel.textColor = UIColor.white
            } else {
                dView.circleView.isHidden = false
                dView.dotView.isHidden = true
                dView.circleView.backgroundColor = UIColor.white
                dView.circleView.layer.borderWidth = 1.0
                dView.circleView.layer.borderColor = UIColor.commonBlueColor().cgColor
                dView.dotView.backgroundColor = UIColor.white
                dView.textLabel.textColor = UIColor.black
            }
        } else if calendarManager.dateHelper.date(today, isEqualOrAfter: dView.date) {
            if let selectedDate = dateSelected, calendarManager.dateHelper.date(selectedDate, isTheSameDayThan: dView.date) {
                dView.circleView.isHidden = false
                dView.dotView.isHidden = true
                dView.circleView.backgroundColor = UIColor.commonBlueColor()
                dView.circleView.layer.borderWidth = 0
                dView.dotView.backgroundColor = UIColor.commonBlueColor()
                dView.textLabel.textColor = UIColor.white
            } else {
                dView.circleView.isHidden = false
                dView.dotView.isHidden = true
                dView.circleView.backgroundColor = UIColor.white
                dView.circleView.layer.borderWidth = 0
                dView.dotView.backgroundColor = UIColor.white
                dView.textLabel.textColor = UIColor.lightGray
            }
        } else if let selectedDate = dateSelected, calendarManager.dateHelper.date(selectedDate, isTheSameDayThan: dView.date) {// Selected date
            dView.circleView.isHidden = false
            dView.dotView.isHidden = true
            dView.circleView.backgroundColor = UIColor.commonBlueColor()
            dView.circleView.layer.borderWidth = 0
            dView.dotView.backgroundColor = UIColor.commonBlueColor()
            dView.textLabel.textColor = UIColor.white
        } else {// Another day of the current month
            dView.circleView.isHidden = true
            dView.dotView.isHidden = true
            dView.dotView.backgroundColor = UIColor.red
            dView.textLabel.textColor = UIColor.black
        }
    }
    
    func calendar(_ calendar: JTCalendarManager!, didTouchDayView dayView: UIView!) {
        guard let dView = dayView as? JTCalendarDayView else { return }
        // Use to indicate the selected date
        
        if calendarManager.dateHelper.date(dView.date, isEqualOrAfter: Date()) {
            dateSelected = dView.date
        }
        
        // Animation for the circleView
        dView.circleView.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
        
        UIView.transition(with: dView,
            duration: 0.3,
            options: UIViewAnimationOptions(),
            animations: { () -> Void in
                dView.circleView.transform = CGAffineTransform.identity
                self.calendarManager.reload()
            }) { (complete) -> Void in
        }
        
        // Load the previous or next page if touch a day from another month
        
        if !calendarManager.dateHelper.date(calendarContentView.date, isTheSameMonthThan: dView.date) {
            if calendarContentView.date.compare(dView.date) == ComparisonResult.orderedAscending {
                calendarContentView.loadNextPageWithAnimation()
            } else {
                calendarContentView.loadPreviousPageWithAnimation()
            }
        }
    }
}
