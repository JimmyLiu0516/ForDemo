//
//  FlickrSearchViewController.swift
//  ForDemo
//
//  Created by Blacktea Liu on 2019/3/9.
//  Copyright © 2019 Jimmy Liu. All rights reserved.
//

import UIKit
import Alamofire

class FlickrSearchViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var perPageTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "搜尋輸入頁"
        
        self.searchTextField.delegate = self
        self.perPageTextField.delegate = self
        
        self.searchButton.isEnabled = false;
        self.configSearchButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeText(sender:)), name: UITextField.textDidChangeNotification, object: self.searchTextField)
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeText(sender:)), name: UITextField.textDidChangeNotification, object: self.perPageTextField)
    }
    
    // MARK: - TextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // 檢查perPage輸入是否為數字
        if textField == self.perPageTextField {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }

        return true
    }
    
    // MARK: - UI event
    @IBAction func searchAction(_ sender: Any) {
        
        self.view.endEditing(true)
        
        if let searchText = searchTextField.text, !searchText.isEmpty, let perPageText = perPageTextField.text, !perPageText.isEmpty {
            let manager = FlickrDataManager.sharedInstance
            manager.fetchData(text: searchText, perPage: perPageText) { (data, error) in
                if let error = error {
                    print(error)
                    return
                }
                
                if let data = data {
                    do {
                        let result = try manager.parseFlickrSearchResult(data: data)
                        let allPhotos = manager.addPhotos(photos: result.photoInfo.photos)
                        manager.seatchText = searchText
                        manager.perPage = perPageText
                        print(allPhotos)
                
                        DispatchQueue.main.async {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let viewController = storyboard.instantiateViewController(withIdentifier: "CollectionViewController")
                            self.navigationController?.pushViewController(viewController, animated: true)
                        }
                    }
                    catch {
                        print(error)
                    }
                }
                
            }
        }
    }
    
    // MARK: - private
    func configSearchButton() -> Void {
        if self.searchButton.isEnabled {
            self.searchButton.backgroundColor = UIColor.blue
        }
        else {
            self.searchButton.backgroundColor = UIColor.lightGray
        }
    }
    
    @objc func didChangeText(sender: Notification) -> Void {

        if let searchText = searchTextField.text, !searchText.isEmpty, let perPageText = perPageTextField.text, !perPageText.isEmpty {
            self.searchButton.isEnabled = true
        }
        else {
            self.searchButton.isEnabled = false
        }
        
        self.configSearchButton()
        
    }

}
