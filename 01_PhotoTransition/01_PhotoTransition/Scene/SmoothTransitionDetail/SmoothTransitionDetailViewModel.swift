//
//  SmoothTransitionDetailViewModel.swift
//  01_PhotoTransition
//
//  Created by satoutakeshi on 2019/03/18.
//  Copyright © 2019 Personal Factory. All rights reserved.
//

import UIKit

protocol SmoothTransitionDetailViewModelInputs {
}

protocol SmoothTransitionDetailViewModelOutputs: AnyObject {
}

protocol SmoothTransitionDetailViewModelType {
    var inputs: SmoothTransitionDetailViewModelInputs { get }
    var outputs: SmoothTransitionDetailViewModelOutputs { get }
}

final class SmoothTransitionDetailViewModel: NSObject,
SmoothTransitionDetailViewModelInputs,
SmoothTransitionDetailViewModelOutputs,
SmoothTransitionDetailViewModelType {

    let image: UIImage
    var inputs: SmoothTransitionDetailViewModelInputs { return self }
    var outputs: SmoothTransitionDetailViewModelOutputs { return self }

    init(image: UIImage) {
        self.image = image
    }
}
