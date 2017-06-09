//
//  GuideCollectionViewController.swift
//  Bank
//
//  Created by Tzzzzz on 16/8/10.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"
private let curVersion = "CurVersion"
private let cfbundleShortVersionString = "CFBundleShortVersionString"

class GuideCollectionViewController: UICollectionViewController {
    
    fileprivate lazy var pageController: UIPageControl = {
        let pageController = UIPageControl()
        pageController.numberOfPages = 5
        pageController.currentPage = 0
        pageController.backgroundColor = UIColor.clear
        pageController.currentPageIndicatorTintColor = UIColor.black
        pageController.pageIndicatorTintColor = UIColor.lightGray
        pageController.center.x = UIScreen.main.bounds.width * 0.5
        pageController.center.y = UIScreen.main.bounds.height * 0.9
        return pageController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Register cell classes
        self.collectionView?.register(GuideCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.isPagingEnabled = true
        self.collectionView?.showsHorizontalScrollIndicator = false
        self.collectionView?.backgroundColor = UIColor.white
        self.collectionView?.bounces = false
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 5
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? GuideCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let imageName = NSString(string: "guidepage0\(indexPath.row+1)") as String
        
        cell.congfigImage(UIImage(named:imageName))
        cell.setStarBtnHidden(indexPath, count: 5)
        return cell
    }
}

// MARK: Delegate
extension GuideCollectionViewController {
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let offsetX = collectionView?.contentOffset.x else { return }
        let currentPage = NSInteger(offsetX / UIScreen.main.bounds.width)
        pageController.currentPage = currentPage
    }
}
