//
//  HomeViewModel.swift
//  01_PhotoTransition
//
//  Created by satoutakeshi on 2019/03/17.
//  Copyright © 2019 Personal Factory. All rights reserved.
//

import UIKit

protocol HomeViewModelInputs {
    func didSelectRow(at indexPath: IndexPath)
}

protocol HomeViewModelOutputs: AnyObject {
    var show: ((UIViewController) -> ())? { get set }
}

protocol HomeViewModelType {
    var inputs: HomeViewModelInputs { get }
    var outputs: HomeViewModelOutputs { get }
}

final class HomeViewModel: NSObject, HomeViewModelInputs, HomeViewModelOutputs, HomeViewModelType {
    private let identifier = "cell"
    let source: [CellType] = [.smoothTransition]

    var inputs: HomeViewModelInputs { return self }
    var outputs: HomeViewModelOutputs { return self }

    var show: ((UIViewController) -> ())?

    override init() {}

    func didSelectRow(at indexPath: IndexPath) {

        let type = source[indexPath.row]
        switch type {
        case .smoothTransition:
            guard let viewController = UIStoryboard(name: "SmoothTransitionViewController", bundle: nil).instantiateInitialViewController() as? SmoothTransitionViewController else { return }
            show?(viewController)
        }
    }
}

    // MARK: UITableView DataSource Delegates
extension HomeViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) else {
            return UITableViewCell()
        }

        let type = source[indexPath.row]
        cell.textLabel?.text = type.rawValue
        return cell
    }
}

enum CellType: String {
    case smoothTransition = "Smooth Transition"
}
