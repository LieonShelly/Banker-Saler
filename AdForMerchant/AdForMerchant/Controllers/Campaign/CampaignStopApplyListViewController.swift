//
//  CampaignStopApplyListViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 7/6/16.
//  Copyright © 2016 Windward. All rights reserved.
//

class CampaignStopApplyListViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    internal var applyInfoArray: [CampaignStopApplyInfo]! = []    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "申请中止履历列表"
        
        tableView.backgroundColor = UIColor.commonBgColor()
        tableView.register(UINib(nibName: "DefaultTxtTableViewCell", bundle: nil), forCellReuseIdentifier: "DefaultTxtTableViewCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    // MARK: - Action
    
    // MARK: - Http request
    
}

extension CampaignStopApplyListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return applyInfoArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       guard let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath) as? DefaultTxtTableViewCell else { return UITableViewCell() }
        cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
        return cell
    }
}

extension CampaignStopApplyListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        let info = applyInfoArray[indexPath.row]
        guard let _cell = cell as? DefaultTxtTableViewCell else { return }
        _cell.leftTxtLabel.text = "申请时间:" + info.applyDate
        _cell.rightTxtLabel.text = info.statusName
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
