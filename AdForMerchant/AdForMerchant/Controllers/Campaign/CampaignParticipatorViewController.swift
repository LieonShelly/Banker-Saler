//
//  CampaignParticipatorViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 3/1/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class ParticipatorCell: UITableViewCell {
    
    @IBOutlet fileprivate var userImageView: UIImageView!
    @IBOutlet fileprivate var userNameLbl: UILabel!
    @IBOutlet fileprivate var phoneNumLbl: UILabel!
    @IBOutlet fileprivate var timeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func config(_ img: String, user: String, phone: String, time: String) {
        
        userNameLbl.text = user
        phoneNumLbl.text = phone
        timeLbl.text = time
        
        userImageView.sd_setImage(with: URL(string: img), placeholderImage: UIImage(named: "PlaceHolderUserPortrait"))
    }
    
}

class CampaignParticipatorViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    var type: CampaignParticipatorListType = .appeared
    
    fileprivate var dataArray: [UserInfo] = []
    
    fileprivate var currentPage: Int = 0
    fileprivate var totalPage: Int = 0
    
    var campId: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch type {
        case .appointment:
            navigationItem.title = "预约者"
        case .appeared:
            navigationItem.title = "参与者"
        }
        
        tableView.backgroundColor = UIColor.commonBgColor()
        tableView.separatorColor = tableView.backgroundColor
        
        tableView.addTableViewRefreshHeader(self, refreshingAction: "requestListWithReload")
        tableView.addTableViewRefreshFooter(self, refreshingAction: "requestListWithAppend")
        
        requestList(1)
    }
}

extension CampaignParticipatorViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ParticipatorCell", for: indexPath) as? ParticipatorCell else { return  UITableViewCell()}
//        let v
        
        return cell
        
    }
}

extension CampaignParticipatorViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return CGFloat.leastNormalMagnitude
        default:
            return 10
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let data = dataArray[indexPath.row]
        guard  let cpCell = cell as? ParticipatorCell else { return }
        cpCell.config(data.avatar, user: data.name, phone: data.mobile, time: data.joinTime)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension CampaignParticipatorViewController {
    func requestListWithReload() {
        requestList(1)
    }
    
    func requestListWithAppend() {
        if currentPage >= totalPage {
            self.tableView.mj_footer.endRefreshingWithNoMoreData()
        } else {
            requestList(currentPage + 1)
        }
    }
    
    func requestList(_ page: Int) {
        var request: AFMRequest!
        let params: [String : Any] = ["page": page, "event_id": campId]
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        switch type {
        case .appeared:
            request = AFMRequest.placeEventUserlist(params, aesKey, aesIV)
        case .appointment:
            request = AFMRequest.placeEventAppointedUserlist(params, aesKey, aesIV)
        }
        RequestManager.request(request, aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            if let result = object as? [String: AnyObject] {
                guard let tempArray = result["items"] as? [AnyObject] else { return }
                self.dataArray = tempArray.flatMap({UserInfo(JSON: ($0 as? [String: AnyObject]) ?? [String: AnyObject]() )})
                self.currentPage = page
                self.totalPage = Int((result["total_page"] as? String) ?? "0") ?? 0
                
                self.tableView.reloadData()
                self.tableView.mj_header.endRefreshing()
                self.tableView.mj_footer.endRefreshing()
            } else {
                self.tableView.mj_header.endRefreshing()
                self.tableView.mj_footer.endRefreshing()
            }
        }
    }
}
