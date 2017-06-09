//
//  AdQuestionDetailViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 6/27/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class AdQuestionDetailViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    var adDetailModel: AdDetailModel = AdDetailModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "用户参与方式"
        
        tableView.backgroundColor = UIColor.commonBgColor()
        tableView.register(UINib(nibName: "DefaultTxtTableViewCell", bundle: nil), forCellReuseIdentifier: "DefaultTxtTableViewCell")
        tableView.register(UINib(nibName: "CenterTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "CenterTxtFieldTableViewCell")
        tableView.register(UINib(nibName: "RightTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "RightTxtFieldTableViewCell")
        tableView.register(UINib(nibName: "RightImageTableViewCell", bundle: nil), forCellReuseIdentifier: "RightImageTableViewCell")
        tableView.register(UINib(nibName: "NormalDescTableViewCell", bundle: nil), forCellReuseIdentifier: "NormalDescTableViewCell")
        tableView.register(UINib(nibName: "AdAddAnswerTableViewCell", bundle: nil), forCellReuseIdentifier: "AdAddAnswerTableViewCell")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}

extension AdQuestionDetailViewController {
    func backAction() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    //用户参与方式
    func cellWay(_ cell: UITableViewCell) {
        guard let _cell = cell as? DefaultTxtTableViewCell else {return}
        _cell.leftTxtLabel.text = "用户参与方式"
        _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
        _cell.rightTxtLabel.text = "问答"
        _cell.selectionStyle = UITableViewCellSelectionStyle.none
        
    }
    
    //提示
    func cellPrompt(_ cell: UITableViewCell) {
        guard let _cell = cell as? NormalDescTableViewCell else {return}
        _cell.accessoryType = .none
        _cell.txtLabel.textColor = UIColor.commonGrayTxtColor()
        _cell.txtLabel.text = "请输入问题内容"
        if adDetailModel.question.isEmpty == false {
            _cell.txtLabel.text = self.adDetailModel.question
        }
        _cell.txtLabel.textColor = UIColor.commonGrayTxtColor()
    }
    
    //答案A
    func cellAnswerA(_ cell: UITableViewCell) {
        guard let _cell = cell as? AdAddAnswerTableViewCell else {return}
        _cell.selectionStyle = .none
        _cell.isRight = false
        _cell.leftTxtLabel.text = "答案A"
        //        _cell.detailTxtField.placeholder = "请输入答案(必填)"
        _cell.config(self.adDetailModel.answer.answerA)
        _cell.detailTxtView.textColor = UIColor.commonGrayTxtColor()
        
    }
    
    //答案B
    func cellAnswerB(_ cell: UITableViewCell) {
        guard let _cell = cell as? AdAddAnswerTableViewCell else {return}
        _cell.selectionStyle = .none
        _cell.isRight = false
        _cell.leftTxtLabel.text = "答案B"
        //        _cell.detailTxtField.placeholder = "请输入答案(必填)"
        _cell.config(self.adDetailModel.answer.answerB)
        _cell.detailTxtView.textColor = UIColor.commonGrayTxtColor()
        
    }
    
    //答案C
    func cellAnswerC(_ cell: UITableViewCell) {
        guard let _cell = cell as? AdAddAnswerTableViewCell else {return}
        _cell.selectionStyle = .none
        _cell.isRight = false
        _cell.leftTxtLabel.text = "答案C"
        //        _cell.detailTxtField.placeholder = "请输入答案"
        _cell.config(self.adDetailModel.answer.answerC)
        _cell.detailTxtView.textColor = UIColor.commonGrayTxtColor()
        
    }
    
    //答案D
    func cellAnswerD(_ cell: UITableViewCell) {
        guard let _cell = cell as? AdAddAnswerTableViewCell else {return}
        _cell.selectionStyle = .none
        _cell.isRight = false
        _cell.leftTxtLabel.text = "答案D"
        //        _cell.detailTxtField.placeholder = "请输入答案"
        _cell.config(self.adDetailModel.answer.answerD)
        _cell.detailTxtView.textColor = UIColor.commonGrayTxtColor()
        
    }
}

extension AdQuestionDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 2:
            
            return (adDetailModel.answer.answerA.text.isEmpty ? 0 : 1)
                + (adDetailModel.answer.answerB.text.isEmpty ? 0 : 1)
                + (adDetailModel.answer.answerC.text.isEmpty ? 0 : 1)
                + (adDetailModel.answer.answerD.text.isEmpty ? 0 : 1)
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (tableView, indexPath.section, indexPath.row) {
        case (self.tableView, 1, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalDescTableViewCell", for: indexPath)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        case (self.tableView, 2, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdAddAnswerTableViewCell", for: indexPath)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension AdQuestionDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == tableView {
        }
        switch section {
        case 0:
            return CGFloat.leastNormalMagnitude
        case 1:
            return 35
        case 2:
            return 35
        default:
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 1:
            return 68
        case 2:
            return 70
        default:
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == self.tableView {
            if section == 1 {
                let attrLabel = UILabel(frame: CGRect(x: 10, y: 15, width: screenWidth, height: 15))
                attrLabel.text = "设置问题"
                attrLabel.font = UIFont.systemFont(ofSize: 13)
                attrLabel.textColor = UIColor.commonGrayTxtColor()
                let attrBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 35))
                attrBg.addSubview(attrLabel)
                return attrBg
            }
            if section == 2 {
                let attrLabel = UILabel(frame: CGRect(x: 10, y: 15, width: screenWidth, height: 15))
                attrLabel.text = "设置问题答案, 标准答案请打勾"
                attrLabel.font = UIFont.systemFont(ofSize: 13)
                attrLabel.textColor = UIColor.commonGrayTxtColor()
                let attrBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 35))
                attrBg.addSubview(attrLabel)
                return attrBg
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        switch (indexPath.section, indexPath.row) {
        case (0, _):
            cellWay(cell)
        case (1, _):
            cellPrompt(cell)
        case (2, _):
            switch indexPath.row {
            case 0:
                cellAnswerA(cell)
            case 1:
                cellAnswerB(cell)
            case 2:
                cellAnswerC(cell)
            case 3:
                cellAnswerD(cell)
            default:
                break
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
