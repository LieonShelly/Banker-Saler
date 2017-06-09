//
//  ProductFilterViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/29/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class ProductFilterViewController: BaseViewController {
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var conditionBtn1: UIButton!
    @IBOutlet fileprivate weak var conditionBtn2: UIButton!
    @IBOutlet fileprivate weak var conditionBtn3: UIButton!
    @IBOutlet fileprivate weak var conditionBtn4: UIButton!
    @IBOutlet fileprivate weak var bgView1: UIView!
    @IBOutlet fileprivate weak var bgView2: UIView!
    @IBOutlet fileprivate weak var bgView3: UIView!
    @IBOutlet fileprivate weak var bgView4: UIView!
    @IBOutlet fileprivate weak var redTagView1: UIView!
    @IBOutlet fileprivate weak var redTagView2: UIView!
    @IBOutlet fileprivate weak var redTagView3: UIView!
    @IBOutlet fileprivate weak var redTagView4: UIView!
    @IBOutlet fileprivate weak var filterConditionLabel1: UILabel!
    @IBOutlet fileprivate weak var filterConditionLabel2: UILabel!
    @IBOutlet fileprivate weak var filterConditionLabel3: UILabel!
    @IBOutlet fileprivate weak var filterConditionLabel4: UILabel!
    var selectType: SelectType?
    var selectedCondition: Int = 0 {
        didSet {
            switch selectedCondition {
            case 0:
                bgView1.backgroundColor = UIColor.commonBgColor()
                filterConditionLabel1.textColor = UIColor.commonBlueColor()
                bgView2.backgroundColor = UIColor.white
                filterConditionLabel2.textColor = UIColor.commonTxtColor()
                bgView3.backgroundColor = UIColor.white
                filterConditionLabel3.textColor = UIColor.commonTxtColor()
                bgView4.backgroundColor = UIColor.white
                filterConditionLabel4.textColor = UIColor.commonTxtColor()
                break
            case 1:
                bgView2.backgroundColor = UIColor.commonBgColor()
                filterConditionLabel2.textColor = UIColor.commonBlueColor()
                
                bgView1.backgroundColor = UIColor.white
                filterConditionLabel1.textColor = UIColor.commonTxtColor()
                bgView3.backgroundColor = UIColor.white
                filterConditionLabel3.textColor = UIColor.commonTxtColor()
                bgView4.backgroundColor = UIColor.white
                filterConditionLabel4.textColor = UIColor.commonTxtColor()
                break
            case 2:
                bgView3.backgroundColor = UIColor.commonBgColor()
                filterConditionLabel3.textColor = UIColor.commonBlueColor()
                
                bgView2.backgroundColor = UIColor.white
                filterConditionLabel2.textColor = UIColor.commonTxtColor()
                bgView1.backgroundColor = UIColor.white
                filterConditionLabel1.textColor = UIColor.commonTxtColor()
                bgView4.backgroundColor = UIColor.white
                filterConditionLabel4.textColor = UIColor.commonTxtColor()
                break
            case 3:
                bgView4.backgroundColor = UIColor.commonBgColor()
                filterConditionLabel4.textColor = UIColor.commonBlueColor()
                
                bgView2.backgroundColor = UIColor.white
                filterConditionLabel2.textColor = UIColor.commonTxtColor()
                bgView3.backgroundColor = UIColor.white
                filterConditionLabel3.textColor = UIColor.commonTxtColor()
                bgView1.backgroundColor = UIColor.white
                filterConditionLabel1.textColor = UIColor.commonTxtColor()
                break
            default:
                break
            }
        }
    }
    var selectCompletionBlock: (( _ orderbyID: String, _ catListIDArray: [String], _ selectedSortIndex: Int, _ selectedCategoryIndex: [Int], _ selectedEventType: [EvetnType], _ selectedGoodsType: [GoodsType]) -> Void)?
    var selectedSortIndex: Int = 0
    var selectedCategoryIndex: [Int] = [Int]()
    var selectedEventType: [EvetnType] = [EvetnType]()
    var selectedGoodsType: [GoodsType] = [GoodsType]()
    internal var goodsFilterModel: GoodsFilterModel! = GoodsFilterModel()
    
    @IBAction func filterAction(_ sender: AnyObject) {
        if let block =  selectCompletionBlock {
            let orderbyID = self.goodsFilterModel.orderbyList[selectedSortIndex].orderby
            var catListIDArray: [String] = [String]()
            if selectedCategoryIndex.isEmpty == false {
                for index in selectedCategoryIndex {
                    catListIDArray.append(self.goodsFilterModel.catList[index].catId)
                }
                block(orderbyID, catListIDArray, selectedSortIndex, selectedCategoryIndex, selectedEventType, selectedGoodsType)
                _ = navigationController?.popViewController(animated: true)
            } else {
                block(orderbyID, catListIDArray, selectedSortIndex, selectedCategoryIndex, selectedEventType, selectedGoodsType)
                _ = navigationController?.popViewController(animated: true)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        requestFilter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         redTagView2.isHidden = selectedCategoryIndex.isEmpty
        redTagView3.isHidden = selectedEventType.isEmpty
        redTagView4.isHidden = selectedGoodsType.isEmpty
      
    }
}

extension ProductFilterViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selectedCondition {
        case 0:
            return (self.goodsFilterModel?.orderbyList.count) ?? 0
        case 1:
             return (self.goodsFilterModel?.catList.count) ?? 0
        case 2:
             return (self.goodsFilterModel?.evetTypelList.count) ?? 0
        case 3:
             return (self.goodsFilterModel?.goodsTypList.count) ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCategoryTableViewCell", for: indexPath)
        cell.backgroundColor = UIColor.commonBgColor()
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
        
    }
}

extension ProductFilterViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return CGFloat.leastNormalMagnitude
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        default:
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        guard  let pCell = cell as? ProductCategoryTableViewCell else { return }
        if selectedCategoryIndex.isEmpty == true {
            redTagView2.isHidden = true
        } else {
            redTagView2.isHidden = false
        }
        switch selectedCondition {
        case 0:
            pCell.config((self.goodsFilterModel.orderbyList[indexPath.row].orderName))
            if indexPath.row == selectedSortIndex {
                if selectedSortIndex == 0 {
                    redTagView1.isHidden = true
                } else {
                    redTagView1.isHidden = false
                }
                pCell.isCategorySelected = true
                pCell.selectionButton.isHidden = false
            } else {
                pCell.isCategorySelected = false
                pCell.selectionButton.isHidden = true
            }
            break
        case 1:
            pCell.config((self.goodsFilterModel.catList[indexPath.row].catName))
            pCell.isCategorySelected = false
            pCell.selectionButton.isHidden = false
            
            for index in selectedCategoryIndex where index == indexPath.row {
                pCell.isCategorySelected = true
            }
            if selectedCategoryIndex.isEmpty == true {
                redTagView2.isHidden = true
            } else {
                redTagView2.isHidden = false
            }
            break
        case 2:
            pCell.config((self.goodsFilterModel.evetTypelList[indexPath.row].title))
            pCell.isCategorySelected = false
            pCell.selectionButton.isHidden = false
            for type in selectedEventType where type == goodsFilterModel.evetTypelList[indexPath.row] {
                pCell.isCategorySelected = true
            }
            if selectedEventType.isEmpty {
                redTagView3.isHidden = true
            } else {
                redTagView3.isHidden = false
            }
            break
        case 3:
            pCell.config((self.goodsFilterModel.goodsTypList[indexPath.row].nikiname))
            pCell.isCategorySelected = false
            pCell.selectionButton.isHidden = false
            for type in selectedGoodsType where type == goodsFilterModel.goodsTypList[indexPath.row] {
                pCell.isCategorySelected = true
            }
            
            if selectedGoodsType.isEmpty {
                redTagView4.isHidden = true
            } else {
                redTagView4.isHidden = false
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch selectedCondition {
        case 0:
                selectedSortIndex = indexPath.row
        case 1:
            //判断分类index是否有重复项,有则删除,无则添加
            if  judgeSelectedGroupIsRepeat(indexPath.row, in: selectedCategoryIndex) {
                for i in 0 ..< selectedCategoryIndex.count where selectedCategoryIndex[i] == indexPath.row {
                    selectedCategoryIndex.remove(at: i)
                    break
                }
            } else {
                selectedCategoryIndex.append(indexPath.row)
            }
        case 2:
            if  judgeSelectedGroupIsRepeat(goodsFilterModel.evetTypelList[indexPath.row], in: selectedEventType) {
                for i in 0 ..< selectedEventType.count where selectedEventType[i] == goodsFilterModel.evetTypelList[indexPath.row] {
                    selectedEventType.remove(at: i)
                    break
                }
            } else {
                selectedEventType.append(goodsFilterModel.evetTypelList[indexPath.row])
            }
        case 3:
            if  judgeSelectedGroupIsRepeat(goodsFilterModel.goodsTypList[indexPath.row], in: selectedGoodsType) {
                for i in 0 ..< selectedGoodsType.count where selectedGoodsType[i] == goodsFilterModel.goodsTypList[indexPath.row] {
                    selectedGoodsType.remove(at: i)
                    break
                }
            } else {
                selectedGoodsType.append(goodsFilterModel.goodsTypList[indexPath.row])
            }
        default:
            break
        }
        tableView.reloadData()
    }
}

extension ProductFilterViewController {
    fileprivate  func setupUI() {
        
        navigationItem.title = "筛选"
        
        let rightBarItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.refreshFilterTag))
        navigationItem.rightBarButtonItem = rightBarItem
        tableView.backgroundColor = UIColor.commonBgColor()
        tableView.register(UINib(nibName: "ProductCategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductCategoryTableViewCell")
        
        conditionBtn1.addTarget(self, action: #selector(self.selectCondition(_:)), for: .touchUpInside)
        conditionBtn2.addTarget(self, action: #selector(self.selectCondition(_:)), for: .touchUpInside)
        conditionBtn3.addTarget(self, action: #selector(self.selectCondition(_:)), for: .touchUpInside)
        conditionBtn4.addTarget(self, action: #selector(self.selectCondition(_:)), for: .touchUpInside)
        selectedCondition = 0
        redTagView1.isHidden = false
    }
    fileprivate func requestFilter() {
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.goodsFilter(aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            guard let result = object as? [String: AnyObject] else { return }
            self.goodsFilterModel = GoodsFilterModel(JSON:result)
            self.tableView.reloadData()
        }
    }
    
    @objc fileprivate  func selectCondition(_ btn: UIButton) {
        selectedCondition = btn.tag
        tableView.reloadData()
    }
    
     @objc fileprivate  func refreshFilterTag() {
        selectedSortIndex = 0
        selectedCategoryIndex.removeAll()
        selectedEventType.removeAll()
        selectedGoodsType.removeAll()
        tableView.reloadData()
        redTagView1.isHidden = true
        redTagView2.isHidden = true
        redTagView3.isHidden = true
        redTagView4.isHidden = true
    }
    
    fileprivate  func judgeSelectedGroupIsRepeat(_ selectedIndex: Int, in group: [Int]) -> Bool {
        for i in group where i == selectedIndex {
            return true
        }
        return false
    }
    
    fileprivate  func judgeSelectedGroupIsRepeat(_ selectedType: EvetnType, in group: [EvetnType]) -> Bool {
        for i in group where i == selectedType {
            return true
        }
        return false
    }
    
    fileprivate  func judgeSelectedGroupIsRepeat(_ selectedType: GoodsType, in group: [GoodsType]) -> Bool {
        for i in group where i == selectedType {
            return true
        }
        return false
    }
}
