//
//  PhotoViewController.swift
//  TestApplication
//
//  Created by Антон Братчик on 26.09.17.
//  Copyright © 2017 Антон Братчик. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var photo: UIImageView!
    
    var image : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photo.image = image
        
        scrollView.maximumZoomScale = 4.0
        scrollView.minimumZoomScale = 1
        scrollView.zoomScale = 1
        scrollView.contentMode = .scaleAspectFit
        scrollView.delegate = self
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photo
    }
}
