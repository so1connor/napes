//
//  ViewController.swift
//  Napes
//
//  Created by Steve O'Connor on 20/06/2018.
//  Copyright © 2018 Steve O'Connor. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    var imagewidth: CGFloat = 0
    var imageheight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.delegate = self
        imagewidth = self.imageView.image?.size.width ?? 0
        imageheight = self.imageView.image?.size.height ?? 0
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidLayoutSubviews() {
        print("viewDidLayoutSubviews")
        super.viewDidLayoutSubviews()
        let screenCentreX : CGFloat = UIScreen.main.bounds.width * 0.5
        let screenCentreY : CGFloat = UIScreen.main.bounds.height * 0.5
        var offsetX :CGFloat = imagewidth/2 - screenCentreX
        var offsetY :CGFloat = imageheight/2 - screenCentreY
        offsetX += 50
        offsetY += 150
        self.scrollView.setContentOffset(CGPoint(x:offsetX,y:offsetY),animated: false)
        print("image width is %f",self.imageView.image?.size.width ?? 0)
        print("image height is %f",self.imageView.image?.size.height ?? 0)
        //print("scroll position is %f %f",self.scrollView.contentOffset.x, self.scrollView.contentOffset.y)

        //the frames have now their final values, after applying constraints
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   func scrollViewDidScroll(_ scrollView : UIScrollView) {
        print("scrolled to %d %d",scrollView.contentOffset.x,scrollView.contentOffset.y)
    }


}

