//
//  SmoothTransitionDetailDetailViewController.swift
//  01_PhotoTransition
//
//  Created by satoutakeshi on 2019/03/18.
//  Copyright © 2019 Personal Factory. All rights reserved.
//

import UIKit

class SmoothTransitionDetailViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!

    let viewModel: SmoothTransitionDetailViewModel

    init(image: UIImage) {
        self.viewModel = SmoothTransitionDetailViewModel(image: image)
        super.init(nibName: "SmoothTransitionDetailViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        imageView.image = viewModel.image
    }

}
