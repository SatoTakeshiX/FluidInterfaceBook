//
//  SmoothTransitionViewController.swift
//  01_PhotoTransition
//
//  Created by satoutakeshi on 2019/03/17.
//  Copyright © 2019 Personal Factory. All rights reserved.
//

import UIKit

class SmoothTransitionViewController: UIViewController {

    private let viewModel = SmoothTransitionViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    
    init() {
        super.init(nibName: "SmoothTransitionViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        
    }
}
