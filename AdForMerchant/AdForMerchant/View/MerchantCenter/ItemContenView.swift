//
//  ItemContenView.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/26.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

private let cellID = "ItemContentCollectionViewCellID"
class ItemContenView: UIView {
    fileprivate var childVCs: [UIViewController]
    fileprivate weak var parentVC: UIViewController?
    
    fileprivate lazy var collectionView: UICollectionView = { [weak self] in
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    init(frame: CGRect, childVCs: [UIViewController], parentVC: UIViewController?) {
        self.childVCs = childVCs
        self.parentVC = parentVC
        super.init(frame: frame)
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
         guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return  }
        layout.itemSize = bounds.size
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ItemContenView {
    func selectedPage(_ index: Int) {
        let offsetX = CGFloat(index) * collectionView.bounds.width
        collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
}

extension ItemContenView {
    func setupUI() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.center.equalTo(self.snp.center)
            make.size.equalTo(self.snp.size)
        }
        
        for childVC in childVCs {
            if let parentVC = parentVC {
                parentVC.addChildViewController(childVC)
            }
        }
    }
}

extension ItemContenView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return childVCs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
        let childVC = childVCs[indexPath.item]
        childVC.view.frame = bounds
        cell.contentView.addSubview(childVC.view)
        cell.backgroundColor = UIColor.randomColor()
        return cell
    }
}
