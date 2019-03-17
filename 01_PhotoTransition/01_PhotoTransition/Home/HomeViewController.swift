//
//  HomeViewController.swift
//  01_PhotoTransition
//
//  Created by satoutakeshi on 2019/03/17.
//  Copyright © 2019 Personal Factory. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    let viewModle = HomeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = viewModle
        tableView.delegate = self
        setupUI()
        viewModle.show = {[weak self] viewController in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.navigationController?.show(viewController, sender: nil)
            }
        }
    }

    private func setupUI() {
        tableView.tableFooterView = UIView()
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModle.didSelectRow(at: indexPath)
    }
}

