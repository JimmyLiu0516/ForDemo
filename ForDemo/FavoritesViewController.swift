//
//  FavoritesViewController.swift
//  ForDemo
//
//  Created by Blacktea Liu on 2019/3/11.
//  Copyright © 2019 Jimmy Liu. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController {

    var collectionViewController: CollectionViewController?
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "我的最愛"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "CollectionViewController") as! CollectionViewController
        viewController.isFavorites = true
        self.collectionViewController = viewController
        self.contentView.addSubview(viewController.view)
        self.addChild(viewController)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionViewController?.view.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
