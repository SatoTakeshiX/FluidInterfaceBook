//
//  SmoothTransitionViewModel.swift
//  01_PhotoTransition
//
//  Created by satoutakeshi on 2019/03/17.
//  Copyright © 2019 Personal Factory. All rights reserved.
//

import UIKit

protocol SmoothTransitionViewModelInputs {
    func didSelectCell(at indexPath: IndexPath)
    var transitionController: TransitionController { get }
}

protocol SmoothTransitionViewModelOutputs: AnyObject {
    var show: ((SmoothTransitionDetailViewController) -> ())? { get set }
    var transitionController: TransitionController { get }
    var selectedIndexPath: IndexPath? { get }
    func imageViewOfTransitioning(collectionView: UICollectionView) -> UIImageView?
    func imageViewFrameOfTransitioning(collectionView: UICollectionView) -> CGRect?
}

protocol SmoothTransitionViewModelType {
    var inputs: SmoothTransitionViewModelInputs { get }
    var outputs: SmoothTransitionViewModelOutputs { get }
}


final class SmoothTransitionViewModel: NSObject, SmoothTransitionViewModelInputs, SmoothTransitionViewModelOutputs, SmoothTransitionViewModelType {

    var inputs: SmoothTransitionViewModelInputs { return self }
    var outputs: SmoothTransitionViewModelOutputs { return self }

    private let imageList: [UIImage] = [
        #imageLiteral(resourceName: "1"),
        #imageLiteral(resourceName: "2"),
        #imageLiteral(resourceName: "3"),
        #imageLiteral(resourceName: "7"),
        #imageLiteral(resourceName: "8"),
        #imageLiteral(resourceName: "5"),
        #imageLiteral(resourceName: "6"),
        #imageLiteral(resourceName: "4"),
        #imageLiteral(resourceName: "9"),
        #imageLiteral(resourceName: "1"),
        #imageLiteral(resourceName: "2"),
        #imageLiteral(resourceName: "3"),
        #imageLiteral(resourceName: "7"),
        #imageLiteral(resourceName: "8"),
        #imageLiteral(resourceName: "5"),
        #imageLiteral(resourceName: "6"),
        #imageLiteral(resourceName: "4"),
        #imageLiteral(resourceName: "9"),
        #imageLiteral(resourceName: "2"),
        #imageLiteral(resourceName: "3"),
        #imageLiteral(resourceName: "7"),
        #imageLiteral(resourceName: "8"),
        #imageLiteral(resourceName: "5"),
        #imageLiteral(resourceName: "6"),
        #imageLiteral(resourceName: "4"),
        #imageLiteral(resourceName: "9")
    ]

    // MARK: Inputs and Outputs
    let transitionController = TransitionController()

    // MARK: Inputs
    private(set) var selectedIndexPath: IndexPath?

    func didSelectCell(at indexPath: IndexPath) {
        let image = imageList[indexPath.row]
        let nextVC = SmoothTransitionDetailViewController(image: image)
        selectedIndexPath = indexPath
        show?(nextVC)
    }

    // MARK: Outputs
    var show: ((SmoothTransitionDetailViewController) -> ())?

    func imageViewOfTransitioning(collectionView: UICollectionView) -> UIImageView? {
        return getSelectedCell(for: collectionView)?.imageView
    }

    func imageViewFrameOfTransitioning(collectionView: UICollectionView) -> CGRect? {
        guard let cell = getSelectedCell(for: collectionView) else { return nil }
        let rect = collectionView.convert(collectionView.frame, to: cell)
        return getSelectedCell(for: collectionView)?.frame
    }

    private func getSelectedCell(for collectionView: UICollectionView) -> SmoothTrasitionCollectionViewCell? {
        guard let indexPath = selectedIndexPath else { return nil }
        //選択したcellを取り出す
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? SmoothTrasitionCollectionViewCell else {
            return nil
        }
        return selectedCell
    }
}

extension SmoothTransitionViewModel: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? SmoothTrasitionCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.imageView.image = imageList[indexPath.row]
        return cell
    }
}
