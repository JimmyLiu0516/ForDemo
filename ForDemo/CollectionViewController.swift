//
//  CollectionViewController.swift
//  ForDemo
//
//  Created by Blacktea Liu on 2019/3/11.
//  Copyright © 2019 Jimmy Liu. All rights reserved.
//

import UIKit
import SDWebImage


private let reuseIdentifier = "searchResultCell"

class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    let manager = FlickrDataManager.sharedInstance
    var isFavorites = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        self.title = "搜尋結果" + manager.seatchText
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
    }
    

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isFavorites {
            return manager.favorites.count
        }
        
        return manager.photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SearchResultCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SearchResultCollectionViewCell
    
        // Configure the cell
        
        var photo: Photo
        
        if (self.isFavorites) {
            photo = manager.favorites[indexPath.row]
        }
        else {
            photo = manager.photos[indexPath.row]
        }
        
        cell.titleLabel.text = photo.title
        cell.imageView.sd_setImage(with: URL(string: photo.imageURL))
        cell.favoriteHandler = { isFavorite in
            if isFavorite {
                self.manager.addPhotoToFavorite(photo: photo)
            }
            else {
                self.manager.removePhotoToFavorite(photo: photo)
            }
            self.collectionView.reloadData()
        }
        
        if manager.favorites.contains(photo) {
            cell.isFavorite = true
        }
        else {
            cell.isFavorite = false
        }
        
        return cell
    }
    
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        manager.currentPage = manager.currentPage + 1
        manager.fetchData(text: manager.seatchText, perPage: manager.perPage, page: manager.currentPage) { (data, error) in
            if let error = error {
                print(error)
                return
            }
            
            if let data = data {
                do {
                    let result = try self.manager.parseFlickrSearchResult(data: data)
                    let _ = self.manager.addPhotos(photos: result.photoInfo.photos)
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
                catch {
                    print(error)
                }
            }
            
        }
    }
    
    // MARK: - UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    // MARK: -  UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
     return CGSize(width: self.view.frame.width / 2, height: 200)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
