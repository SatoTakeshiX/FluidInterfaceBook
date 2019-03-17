//
//  SmoothTransitionViewController.swift
//  01_PhotoTransition
//
//  Created by satoutakeshi on 2019/03/17.
//  Copyright © 2019 Personal Factory. All rights reserved.
//

import UIKit

class SmoothTransitionViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var imageView: UIImageView!
    let image: UIImage
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    
    init(image: UIImage) {
        self.image = image
        super.init(nibName: "SmoothTransitionViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        imageView.image = image
    }
}
