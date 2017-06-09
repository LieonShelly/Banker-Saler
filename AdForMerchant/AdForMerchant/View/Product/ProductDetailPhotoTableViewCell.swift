//
//  ProductDetailPhotoTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 2/3/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class ProductDetailPhotoTableViewCell: UITableViewCell {
    
    //Block
    internal var addCompletionBlock:(() -> Void)?
    internal var detailCompletionBlock:(() -> Void)?
    var sourceIsAllowEdit: Bool = false {
        didSet {
            if sourceIsAllowEdit {
                let addImgTap = UITapGestureRecognizer(target: self, action: #selector(self.addImg))
                imgView1.addGestureRecognizer(addImgTap)
            }
        }
    }
    @IBOutlet internal var imgView1: UIImageView!
    @IBOutlet internal var imgView2: UIImageView!
    @IBOutlet internal var imgView3: UIImageView!
    @IBOutlet internal var imgView4: UIImageView!
    
    @IBOutlet internal var moreImgBgView: UIView!
    @IBOutlet internal var photoCountLabel: UILabel!
    @IBOutlet internal var bottomNoteLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let addImgTap = UITapGestureRecognizer(target: self, action: #selector(self.addImg))
        if kApp.pleaseAttestationAction(showAlert: false, type: .publish) {
             imgView1.addGestureRecognizer(addImgTap)
        }
        let detailImgTap2 = UITapGestureRecognizer(target: self, action: #selector(self.detailImg))
        let detailImgTap3 = UITapGestureRecognizer(target: self, action: #selector(self.detailImg))
        let detailImgTap4 = UITapGestureRecognizer(target: self, action: #selector(self.detailImg))
        let detailImgTap5 = UITapGestureRecognizer(target: self, action: #selector(self.detailImg))
        
        imgView2.addGestureRecognizer(detailImgTap2)
        imgView3.addGestureRecognizer(detailImgTap3)
        imgView4.addGestureRecognizer(detailImgTap4)
        moreImgBgView.addGestureRecognizer(detailImgTap5)
        
        imgView1.isUserInteractionEnabled = true
        imgView2.isUserInteractionEnabled = true
        imgView3.isUserInteractionEnabled = true
        imgView4.isUserInteractionEnabled = true
        moreImgBgView.isUserInteractionEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
///添加图片
    func addImg() {
        if let block = addCompletionBlock {
            block()
        }
    }
    
///图片详情
    func detailImg() {
        if let block = detailCompletionBlock {
            block()
        }
    }
    
}
