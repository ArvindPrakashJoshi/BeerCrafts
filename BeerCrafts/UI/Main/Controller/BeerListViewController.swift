//
//  BeerListViewController.swift
//  BeerCrafts
//
//  Created by Abhishek on 29/06/18.
//  Copyright © 2018 Abhishek. All rights reserved.
//

import UIKit
import AppModel

class BeerListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var viewModel = BeerListViewModel()
    
    private struct Segue {
        static let Filters = "FiltersVCSegueId"
        static let Cart = "CartViewSegueId"
    }
    @IBOutlet weak var cartButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.setupSearchBar()
        self.setupViewModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cartAction(_ sender: Any) {
        self.performSegue(withIdentifier: Segue.Cart, sender: nil)
    }
    
    @IBAction func sortAction(_ sender: Any) {
        self.viewModel.sortItems()
    }
    
    @IBAction func filterAction(_ sender: Any) {
        self.showFilters()
    }
}

extension BeerListViewController {
    
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "BeerTableViewCell", bundle: nil),
                                forCellReuseIdentifier: "BeerTableViewCell")
    }
    
    private func setupViewModel() {
        
        self.viewModel.reloadHandler = {
            self.tableView.reloadData()
        }
        
        self.showLoader()
        self.viewModel.fetchItems { _ in
            self.hideLoader()
        }
        
        let _ = CartManager.shared.cartItems.subscribe(onNext: { _ in
            self.cartButton.title = "\(CartManager.shared.cartItems.value.count) Item"
        })
    }
    
    private func showFilters() {
        self.performSegue(withIdentifier: Segue.Filters,
                          sender: self.viewModel.filterModel)
    }
}

extension BeerListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.itemCount
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "BeerTableViewCell"
        ) as! BeerTableViewCell
        cell.delegate = self
        cell.item = self.viewModel.item(indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension BeerListViewController: BeerTableViewCellDelegate {
    
    func didTapAddButton(cell: BeerTableViewCell) {
        CartManager.shared.add(beer: (cell.item as! BeerCellModel).beer)
    }
}

extension BeerListViewController: FiltersViewControllerDelegate {
    
    func applyFilters(filters: [FilterType: [String]]) {
        self.viewModel.applyFilters(filters: filters)
    }
    
    func clearFilters() {
        self.viewModel.clearFilters()
    }
}

extension BeerListViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.identifier, segue.destination, sender) {
        case (Segue.Filters?,
              let vc as FiltersViewController,
              let viewModel as BeerFilterViewModel):
            vc.viewModel = viewModel
            vc.delegate = self
        default:
            break
        }
        super.prepare(for: segue, sender: sender)
    }
}

extension BeerListViewController: UISearchBarDelegate {
    
    func setupSearchBar() {
        self.searchBar.delegate = self
        self.searchBar.setShowsCancelButton(false, animated: false)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.viewModel.filterSearch(searchText: searchBar.text ?? "")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.resetData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.resetData()
    }
    
    private func resetData() {
        searchBar.setShowsCancelButton(false, animated: true)
        self.searchBar.text = nil
        self.searchBar.resignFirstResponder()
        self.viewModel.resetData()
    }
}
