//
//  BeerFilterViewModel.swift
//  BeerCrafts
//
//  Created by Abhishek on 28/07/18.
//  Copyright © 2018 Abhishek. All rights reserved.
//

import Foundation
import AppModel

struct FilterTypes {
    static let Style = "Style"
    static let Ounces = "Ounces"
    static let ABV = "ABV"
}

class BeerFilterViewModel {
    
    var sections: [SectionModel] = []
    var reloadHandler: DataHandler = { }
    var filters: [String: [String]] = [:]
    
    init(list: [Beer] = []) {
        self.configure(list: list)
    }
    
    func configure(list: [Beer]) {
        
        let abvDictionary = list.reduce(into: [String: Int]()) { (dictionary, model) in
            let type = model.abv.isEmpty ? "0.00" : model.abv
            dictionary[type] = 0
        }
        
        let ouncesDictionary = list.reduce(into: [String: Int]()) { (dictionary, model) in
            let type = String(model.ounces)
            dictionary[type] = 0
        }
        
        let styleDictionary = list.reduce(into: [String: Int]()) { (dictionary, model) in
            let type = model.style
            dictionary[type] = 0
        }
        
        let abvCellModels = abvDictionary.map { FilterCellModel(value: $0.key) }
        let ouncesCellModels = ouncesDictionary.map { FilterCellModel(value: $0.key) }
        let styleCellModels = styleDictionary.map { FilterCellModel(value: $0.key) }
        
        self.sections = [
            SectionModel(headerModel: HeaderModel(type: FilterTypes.Style),
                         cellModels: styleCellModels),
            SectionModel(headerModel: HeaderModel(type: FilterTypes.Ounces),
                         cellModels: ouncesCellModels),
            SectionModel(headerModel: HeaderModel(type: FilterTypes.ABV),
                         cellModels: abvCellModels)
        ]
    }
}

extension BeerFilterViewModel {
    
    func item(at indexPath: IndexPath) -> Any {
        return self.sections[
            indexPath.section
        ].cellModels[
            indexPath.row
        ]
    }
    
    func items(at indexPath: IndexPath) -> [Any] {
        return self.sections[
            indexPath.section
        ].cellModels
    }
    
    func itemCount(at section: Int) -> Int {
        return self.sections[
            section
        ].cellModels.count
    }
    
    var sectionCount: Int {
        return self.sections.count
    }
    
    func sectionModel(at section: Int) -> Any? {
        return self.sections[
            section
        ].headerModel
    }
}

// APPLY and CLEAR
extension BeerFilterViewModel {
    
    func clearFilters() {
        self.sections.forEach {
            $0.cellModels.forEach { model in
                (model as? FilterCellModel)?.isSelected = false
            }
        }
        self.filters.removeAll()
        self.reloadHandler()
    }
    
    func updateFilter(at indexPath: IndexPath) {
        
        guard let sectionModel = self.sectionModel(at: indexPath.section) as? HeaderModel,
              let cellModel = self.item(at: indexPath) as? FilterCellModel else { return }
        
        cellModel.isSelected = !cellModel.isSelected
        
        if cellModel.isSelected {
            if let _ = self.filters[sectionModel.type] {
                self.filters[sectionModel.type]?.append(cellModel.value)
            } else {
                self.filters[sectionModel.type] = [cellModel.value]
            }
        } else {
            guard let values = self.filters[sectionModel.type],
                  let index = values.index(where: {
                  $0 == cellModel.value
              }) else { return }
            self.filters[sectionModel.type]?.remove(at: index)
        }
        print("UPDATED FILTERS : \(self.filters)")
    }
}
