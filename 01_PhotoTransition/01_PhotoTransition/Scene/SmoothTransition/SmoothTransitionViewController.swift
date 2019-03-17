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
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        binds()
        setupUI()
    }

    private func setupUI() {
        collectionView.dataSource = viewModel
        collectionView.delegate = self
    }

    private func binds() {
        viewModel.show = {[weak self] viewController in
            guard let self = self else { return }
            self.show(viewController, sender: nil)
        }
    }
}

extension SmoothTransitionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        viewModel.inputs.didSelectCell(at: indexPath)

    }
}
