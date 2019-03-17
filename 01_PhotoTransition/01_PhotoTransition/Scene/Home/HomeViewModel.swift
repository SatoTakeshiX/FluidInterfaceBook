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

protocol HomeViewModelOutputs {
    var show: ((UIViewController) -> ())? { get }
}

protocol HomeViewModelType {
    var inputs: HomeViewModelInputs { get }
    var outputs: HomeViewModelOutputs { get }

}

final class HomeViewModel: NSObject, HomeViewModelInputs, HomeViewModelOutputs, HomeViewModelType {

    private let identifier = "cell"
    let source: [CellType] = [.smoothTransition, .fluidTransition]
    var inputs: HomeViewModelInputs { return self }
    var outputs: HomeViewModelOutputs { return self }
    var show: ((UIViewController) -> ())?

    override init() {}

    func didSelectRow(at indexPath: IndexPath) {

        let type = source[indexPath.row]
        switch type {
        case .smoothTransition:
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home")
            show?(viewController)
        case .fluidTransition:
            show?(UIViewController())
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

enum CellType: String, CaseIterable {
    case smoothTransition = "Smooth Transition"
    case fluidTransition = "Fluid Transition"
}
