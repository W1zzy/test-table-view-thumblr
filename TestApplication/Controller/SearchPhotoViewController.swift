//
//  SearchPhotoViewController.swift
//  TestApplication
//
//  Created by Антон Братчик on 25.09.17.
//  Copyright © 2017 Антон Братчик. All rights reserved.
//

import UIKit

class SearchPhotoViewController: UIViewController {
    
    private let cellReuseIdentifier = "SearchPhotoCell"
    private let photoPreviewSegue = "photoPreviewSegue"
    
    @IBOutlet weak var searchPhraseTextField: UITextField!
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var searchResultsButton: UIButton!
    
    private var dataSource = [SearchPhotoDatasourceItem]()
    
    /// ViewController lifecyrcle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        searchResultsTableView.rowHeight = UITableViewAutomaticDimension
        searchResultsTableView.estimatedRowHeight = 250
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
    
    override func didReceiveMemoryWarning() {
        dataSource.removeAll()
        searchResultsTableView.reloadData()
    }

    
    /// Actions
    @IBAction func searchPhoto(_ sender: UIButton) {
        view.endEditing(true)
        searchResultsButton.isEnabled = false
        
        if let searchString = searchPhraseTextField?.text {
            dataSource.removeAll()
            searchResultsTableView.reloadData()
            
            NetworkManager.sharedInstance.getPostsWith(tag: searchString, onSuccess: { [weak self] (json) in
                DispatchQueue.main.async {
                    if let unwrappedSelf = self {
                        if let response = json["response"], let posts = response as? Array<[String: AnyObject]> {
                            for post in posts {
                                guard let postPhotos = post["photos"], let postPhotosArray = postPhotos as? Array<[String: AnyObject]> else {
                                    continue
                                }
                                
                                for photoObject in postPhotosArray {
                                    guard let photo = photoObject["original_size"], let photoURL = photo["url"] as? String, !photoURL.isEmpty else {
                                        continue
                                    }
                                    
                                    if let url = URL(string: photoURL) {
                                        unwrappedSelf.dataSource.append(SearchPhotoDatasourceItem(photoURL: url))
                                    }
                                }
                            }
                        }
                        
                        unwrappedSelf.searchResultsTableView.reloadData()
                        unwrappedSelf.searchResultsButton.isEnabled = true
                    }
                }
            }, onFailure: { [weak self] (error) in
                DispatchQueue.main.async {
                    if let unwrappedSelf = self {
                        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                        
                        unwrappedSelf.present(alert, animated: true, completion: nil)
                        unwrappedSelf.searchResultsButton.isEnabled = true
                    }
                }
            })
        }
    }
}


/// TableView delegate implementation
extension SearchPhotoViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: photoPreviewSegue, sender: dataSource[indexPath.row].image)
    }
}


/// TableView data source implementation
extension SearchPhotoViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchResultsTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! SearchPhotoTableViewCell
        cell.tag = indexPath.row
        
        // clean cell image (after dequeue can be missplaced previous image)
        cell.photo.image = nil
        
        // check on image existing (preventing infinity reloads of row)
        if dataSource[indexPath.row].imageResized == nil || dataSource[indexPath.row].image == nil{
            // trying to find new image for cell
            NetworkManager.sharedInstance.getImageWith(url: dataSource[indexPath.row].photoURL, onSuccess: { [weak self] (image) in
                DispatchQueue.global().async {
                    if let unwrappedSelf = self, unwrappedSelf.dataSource.count > indexPath.row {
                        unwrappedSelf.dataSource[indexPath.row].image = image
                        unwrappedSelf.dataSource[indexPath.row].imageResized = image.resizeImage(pixelWidth: 300)
                        
                        DispatchQueue.main.async {
                            // check is answer for this cell or not
                            if cell.tag == indexPath.row {
                                tableView.reloadRows(at: [indexPath], with: .automatic)
                            }
                        }
                    }
                }
            })
        } else {
            cell.photo.image = dataSource[indexPath.row].imageResized!
        }

        return cell
    }
}

/// Navigation
extension SearchPhotoViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == photoPreviewSegue {
            let destVC = segue.destination as! PhotoViewController
            destVC.image = sender as! UIImage?
        }
    }
}
