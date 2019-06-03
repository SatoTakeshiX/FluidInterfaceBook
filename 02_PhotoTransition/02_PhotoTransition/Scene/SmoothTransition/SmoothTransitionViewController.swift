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

    var selectedCell: UICollectionViewCell?
    
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
            // TODO: Animatorを入れる
            self.navigationController?.delegate = self.viewModel.outputs.transitionController
            self.viewModel.inputs.transitionController.fromDelegate = self
            self.viewModel.inputs.transitionController.toDelegate = viewController
            self.show(viewController, sender: nil)
        }
    }
}

extension SmoothTransitionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        collectionView.deselectItem(at: indexPath, animated: true)
        selectedCell = collectionView.cellForItem(at: indexPath)
        viewModel.inputs.didSelectCell(at: indexPath)
    }
}

extension SmoothTransitionViewController: TransitionAnimatorDelegate {
    func transitionWillStart(in zoomAnimator: TransitionAnimator) {
    }

    func transitionDidEnd(in zoomAnimator: TransitionAnimator) {

        // 選択したcellフレーム
        let cellFrame = collectionView.convert(viewModel.outputs.imageViewFrameOfTransitioning(collectionView: collectionView!)!, to: self.view)

        // セルがコレクションビューの下だったら
        if cellFrame.minY < self.collectionView.contentInset.top {
            // collectionViewをスクロールして上に上げる
            self.collectionView.scrollToItem(at: viewModel.outputs.selectedIndexPath!, at: .top, animated: false)

        } else if cellFrame.maxY > self.view.frame.height - self.collectionView.contentInset.bottom {
            // cellの下の点がviewよりも下だったらcollectionを下までスクロール
            self.collectionView.scrollToItem(at: viewModel.outputs.selectedIndexPath!, at: .bottom, animated: false)
        }
    }

    func imageViewOfTransitioning() -> UIImageView? {
        return viewModel.outputs.imageViewOfTransitioning(collectionView: collectionView)
    }

    func imageViewFrameOfTransitioning() -> CGRect? {
        return viewModel.outputs.imageViewFrameOfTransitioning(collectionView: collectionView)
    }


}
