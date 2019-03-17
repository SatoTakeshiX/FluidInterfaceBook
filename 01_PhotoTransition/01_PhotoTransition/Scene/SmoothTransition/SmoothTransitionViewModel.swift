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
}

protocol SmoothTransitionViewModelOutputs: AnyObject {
    var show: ((UIViewController) -> ())? { get set }
}

protocol SmoothTransitionViewModelType {
    var inputs: SmoothTransitionViewModelInputs { get }
    var outputs: SmoothTransitionViewModelOutputs { get }
}


final class SmoothTransitionViewModel: NSObject, SmoothTransitionViewModelInputs, SmoothTransitionViewModelOutputs, SmoothTransitionViewModelType {

    var inputs: SmoothTransitionViewModelInputs { return self }
    var outputs: SmoothTransitionViewModelOutputs { return self }

    let imageList: [UIImage] = [
        #imageLiteral(resourceName: "1"),
        #imageLiteral(resourceName: "2"),
        #imageLiteral(resourceName: "3"),
        #imageLiteral(resourceName: "7"),
        #imageLiteral(resourceName: "8"),
        #imageLiteral(resourceName: "5"),
        #imageLiteral(resourceName: "6"),
        #imageLiteral(resourceName: "4"),
        #imageLiteral(resourceName: "9")
    ]

    // MARK: Inputs
    func didSelectCell(at indexPath: IndexPath) {
        let image = imageList[indexPath.row]
        let nextVC = SmoothTransitionDetailViewController(image: image)
        show?(nextVC)
    }

    // MARK: Outputs
    var show: ((UIViewController) -> ())?
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
