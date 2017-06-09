//
//  ShopCoverSelectViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 7/6/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit
import ALCameraViewController
import ObjectMapper

class ShopCoverSelectTableViewCell: UITableViewCell {
    
    @IBOutlet var coverImgView: UIImageView!
    @IBOutlet var selectionImgView: UIImageView!
    
    var isCoverSelected: Bool = false {
        didSet {
            selectionImgView.isHidden = !isCoverSelected
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class ShopCoverSelectViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    @IBOutlet fileprivate weak var coverImgView: UIImageView!
    @IBOutlet fileprivate weak var coverUploadButton: UIButton!
    
    var coverImgArray: [StoreCover] = []
    
    var selectedCoverIndex: Int = -1
    
    fileprivate var coverImg: UIImage?
    var coverImgUrl: String?
    
    var completeBlock: ((String?) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "选择封面"
        
        let rightBarItem = UIBarButtonItem(title: "确定", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.confirmAction))
        navigationItem.rightBarButtonItem = rightBarItem
        
        coverUploadButton.addTarget(self, action: #selector(self.uploadCoverAction), for: .touchUpInside)
        
        tableView.reloadData()
        
        coverImgView.isUserInteractionEnabled = true
        coverImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.uploadCoverAction)))
        
        requestSystemCoverList()
        
        refreshCover()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Button Action
    
    func confirmAction() {
        if let block = completeBlock {
            if selectedCoverIndex >= 0 {
                block(coverImgArray[selectedCoverIndex].URL)
            } else {
                block(coverImgUrl)
            }
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    func uploadCoverAction() {
        showAddPhotoAlertController()
    }
    
    func refreshCover() {
        if let url = coverImgUrl {
            if selectedCoverIndex >= 0 {
                coverImgView.isHidden = true
            } else {
                coverImgView.isHidden = false
                coverImgView.sd_setImage(with: URL(string: url))
            }
        } else {
            coverImgView.isHidden = true
        }
    }
    
    // Mark : - Photo Cover Alert
    
    @IBAction func showAddPhotoAlertController() {
        
        let actionAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionAlert.addAction(UIAlertAction(title: "选择相册", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            self.chooseFromType(.photoLibrary)
        }))
        actionAlert.addAction(UIAlertAction(title: "拍照上传", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            self.chooseFromType(.camera)
        }))
        actionAlert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(actionAlert, animated: true, completion: nil)
    }
    
    func chooseFromType(_ type: UIImagePickerControllerSourceType) {
        switch type {
        case .photoLibrary:
            let libraryViewController = CameraViewController.imagePickerViewController(croppingRatio: 220.0/750.0) { image, asset in
                if let image = image {
                    self.coverImg = image
                    self.dismiss(animated: true, completion: {
                        self.uploadImage()
                        self.selectedCoverIndex = -1
                        self.tableView.reloadData()
                    })
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            present(libraryViewController, animated: true, completion: nil)
        case .camera:
            let cameraViewController = CameraViewController(croppingRatio: 220.0/750.0) { image, asset in
                if let image = image {
                    self.coverImg = image
                    self.dismiss(animated: true, completion: {
                        self.uploadImage()
                        self.selectedCoverIndex = -1
                        self.tableView.reloadData()
                    })
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            present(cameraViewController, animated: true, completion: nil)
        default:
            break
        }
    }
    
    // MARK: - HTTP request
    
    func uploadImage() {
        
        guard let coverImg = coverImg else {return}
        guard let imageData = UIImageJPEGRepresentation(coverImg, 0.9) else {return}
        
        let parameters = ["cover": imageData, "prefix[cover]": "store/cover"] as [String : Any]
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.uploadImage(AFMRequest.imageUpload, params: parameters) { (_, _, object, error) -> Void in
            if (object) != nil {
                guard let result = object as? [String: AnyObject] else {return}
                guard let photoUploadedArray = result["success"] as? [AnyObject] else {return}
                if let photoInfo = photoUploadedArray.first, let imgUrl = photoInfo["url"] as? String {
                    self.coverImgUrl = imgUrl
                    self.coverImgView.sd_setImage(with: URL(string: imgUrl))
                    Utility.hideMBProgressHUD()
                    
                    self.refreshCover()
                    self.tableView.reloadData()
                } else {
                    Utility.showMBProgressHUDToastWithTxt("上传失败，请稍后重试")
                }
            } else {
                if let userInfo = error?.userInfo, let msg = userInfo["message"] as? String {
                    Utility.showMBProgressHUDToastWithTxt(msg)
                } else {
                    Utility.showMBProgressHUDToastWithTxt("上传失败，请稍后重试")
                }
            }
        }
    }
    
    func requestSystemCoverList() {
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.configDefaultStoreCover(aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, message) -> Void in
            Utility.hideMBProgressHUD()
            if let result = object as? [String: Any], let array = result["items"] as? [Any] {
                self.coverImgArray.removeAll()
                for index in 0..<array.count {
                    if let item = array[index] as? [String: Any], let cover = Mapper<StoreCover>().map(JSON: item) {
                        self.coverImgArray.append(cover)
                        if cover.URL == self.coverImgUrl {
                            self.selectedCoverIndex = index
                        }
                    }
                }
            }
            self.tableView.reloadData()
            self.refreshCover()
        }
    }
    
}

extension ShopCoverSelectViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coverImgArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ShopCoverSelectTableViewCell") as? ShopCoverSelectTableViewCell else {return UITableViewCell()}
        cell.isCoverSelected = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        
        let cover = coverImgArray[indexPath.row]
        guard let _cell = cell as? ShopCoverSelectTableViewCell else {return}
        _cell.coverImgView.sd_setImage(with: URL(string: cover.URL))
        _cell.isCoverSelected = (selectedCoverIndex == indexPath.row)
        
    }
    
}

extension ShopCoverSelectViewController: UITableViewDelegate {
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCoverIndex = indexPath.row
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let attrLabel = UILabel(frame: CGRect(x: 10, y: 15, width: screenWidth, height: 15))
            attrLabel.text = "选择其他封面"
            attrLabel.font = UIFont.systemFont(ofSize: 13)
            attrLabel.textColor = UIColor.commonGrayTxtColor()
            let attrBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 35))
            attrBg.addSubview(attrLabel)
            return attrBg
        }
        let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        return titleBg
    }
}
