//
//  ViewController.swift
//  Napes
//
//  Created by Steve O'Connor on 20/06/2018.
//  Copyright © 2018 Steve O'Connor. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.contentsRect = CGRect(x:0,y:0,width:1,height:1)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

