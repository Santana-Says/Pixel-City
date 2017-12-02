//
//  PopVC.swift
//  Pixel City
//
//  Created by Jeffrey Santana on 11/30/17.
//  Copyright © 2017 Jefffrey Santana. All rights reserved.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {

    //Outlets
    @IBOutlet weak var popImgView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    
    //Variables
    var passedImg: Photo!
    
    func initData(forImage image: Photo) {
        passedImg = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        popImgView.image = passedImg.img
        titleLbl.text = passedImg.title
        addDoubleTap()
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(screenWasDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
    
    @objc func screenWasDoubleTapped() {
        dismiss(animated: true, completion: nil)
    }

}
