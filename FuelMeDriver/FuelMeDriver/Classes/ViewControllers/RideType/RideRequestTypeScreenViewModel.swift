//
//  RideRequestTypeScreenViewModel.swift
//  RideDriver
//
//  Created by Theodore Gonzalez on 13/07/2018.
//  Copyright © 2018 FuelMe LLC. All rights reserved.
//

import Foundation

@objc public protocol RideRequestTypeScreenViewModelProtocol {
    func didUpdateDataSource()
}

@objc public final class RideRequestTypeScreenViewModel: NSObject {
    //MARK: Internal
    fileprivate weak var configManager:ConfigurationManager?
    fileprivate weak var sessionManager:RASessionManager?
    fileprivate weak var delegate:RideRequestTypeScreenViewModelProtocol?
    
    //MARK: External
    @objc public let title = "Ride Request Type"
    @objc public var driverTypeFilter: DriverType
    @objc public private(set) var carTypeViewModels: [CarTypeViewModel]
    @objc public init(sessionManager:RASessionManager, configManager:ConfigurationManager, delegate:RideRequestTypeScreenViewModelProtocol) {
        self.configManager = configManager
        self.sessionManager = sessionManager
        self.delegate = delegate
        let session = sessionManager.currentSession!
        self.driverTypeFilter = session.driverTypeFilter
        self.carTypeViewModels = configManager.global.carTypes.map { CarTypeViewModel(category: $0) }
        
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(updateCarTypes), name: NSNotification.Name.userCarTypesHasBeenChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCarTypes), name: NSNotification.Name.currentDriverHasBeenChanged, object: nil)
        updateCarTypes()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

@objc public extension RideRequestTypeScreenViewModel {
    func reloadSelectedCarWithCompletion(_ completion:@escaping (Error?)->()) {
        sessionManager?.reloadCurrentDriver(completion: { [weak self] (driver, error) in
            if error == nil {
                self?.updateCarTypes()
            }
            completion(error)
        })
    }
    
    func didSelectCar(index:Int) {
        let vm = carTypeViewModels[index]
        if vm.isActive {
            vm.isSelected = !vm.isSelected
            delegate?.didUpdateDataSource()
        }
    }
    
    func didSelectFilter(index:Int, sender:UISegmentedControl) {
        let options = filterOptions()
        //update color
        if let femaleSegmentIndex = options.index(where: { $0.type == .femaleDriver}) {
            if index == femaleSegmentIndex {
                sender.tintColor = UIColor.femaleDriverPink()
            } else {
                sender.tintColor = UIColor.azureBlue()
            }
        }
        driverTypeFilter = options[index].type
        delegate?.didUpdateDataSource()
    }
    
    func didSave(completion:(String?)->()) {
        let activeAndSelected:[CarTypeViewModel] = activeAndSelectedCarTypes()
        if activeAndSelected.count == 0 {
            completion("Please select at least one category")
        } else {
            let carCategories:[String] = activeAndSelected.map { $0.carCategory() }
            sessionManager?.saveUserCarTypes(carCategories, andDriverType: driverTypeFilter)
            completion(nil)
        }
    }
    
    func canSave() -> Bool {
        if driverTypeFilter != sessionManager?.currentSession?.driverTypeFilter {
            return true
        }
        
        if let cached = sessionManager?.currentSession?.userCarTypes {
            let activeAndSelectedCarCategories:[String] = carTypeViewModels.filter { $0.isActive && $0.isSelected }.map{$0.carCategory()}
            return Set(activeAndSelectedCarCategories) != Set(cached)
        }
        return false
    }
    
    func shouldShowDriverTypeFilter() -> Bool {
        return shouldShowFemaleDriverMode() || shouldShowDCMode()
    }
    
    func displayCarName() -> String {
        if let car = selectedCar() {
            return car.carName()
        } else {
            return "Please select your car in settings"
        }
    }
    
    func selectionDescription() -> String {
        let activeAndSelected = activeAndSelectedCarTypes()
        let activeSelectedString = activeAndSelected.map { $0.displayName() }.joined(separator: " + ")
        
        var mDescription = ""
        if (activeAndSelected.count > 0) {
            mDescription.append("Your current ride request type is now set to the following categories. You are set to receive:\n\n")
            mDescription.append(activeSelectedString) //CASE 1
            
            switch driverTypeFilter {
            case .femaleDriver:
                if shouldShowFemaleDriverMode() {
                    mDescription.append("\nfemale driver requests ONLY")
                }
            case .directConnect:
                if shouldShowDCMode() {
                    mDescription.append("\ndirect connect requests ONLY")
                }
            case .unspecified, .fingerPrinted:
                if shouldShowFemaleDriverMode() {
                    mDescription.append("\nand\n")
                    
                    //intersection between available and selected
                    let femaleDriverModeEligibleCategories = Set(configManager!.global.driverTypeOnlyWomenMode().availableInCategories)
                    
                    let availableCategories = Set(activeAndSelected.map({ (vm) -> String in
                        return vm.carCategory()
                    })).intersection(femaleDriverModeEligibleCategories)
                    
                    mDescription.append(availableCategories.map({ (category) -> String in
                        return configManager!.global.carTypes.first { $0.carCategory == category }!.title
                    }).joined(separator: " + "))
                    mDescription.append("\nfemale driver requests")
                }
            }
            
            mDescription.append("\n\n")
            if (activeAndSelected.count == carTypeViewModels.count) {
                mDescription.append("All car types are selected")
            } else {
                mDescription.append("Select or register for other car categories to receive ride requests in those categories.")
            }
        } else {
            mDescription.append("Please select car type")
        }
        return mDescription;
    }
}

//  MARK: Driver Types
public extension RideRequestTypeScreenViewModel {
    @objc func setupSegmentedControl(target:Any, action:Selector) -> UISegmentedControl? {
        let options = filterOptions()
        guard case let count = options.count, count > 1 else {
            return nil
        }
        
        let control = UISegmentedControl(items: options.map { $0.title })
        control.addTarget(target, action: action, for: .valueChanged)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.tintColor = UIColor.azureBlue()
        if #available(iOS 13.0, *) {
            control.selectedSegmentTintColor = UIColor.azureBlue()
        }
        
        let font = UIFont(name: RAFontType.regular.rawValue, size: 14)!
        control.setTitleTextAttributes([NSAttributedString.Key(rawValue: convertFromNSAttributedStringKey(NSAttributedString.Key.font)):font, NSAttributedString.Key(rawValue: convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor)):UIColor.azureBlue()], for: .normal)
        control.setTitleTextAttributes([NSAttributedString.Key(rawValue: convertFromNSAttributedStringKey(NSAttributedString.Key.font)):font, NSAttributedString.Key(rawValue: convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor)):UIColor.white], for: .selected)
        
        if #available(iOS 9.0, *) {
            UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0
        }
        if let selectedFilter = sessionManager?.currentSession?.driverTypeFilter,
           let index = options.index(where: { $0.type == selectedFilter }) {
            control.selectedSegmentIndex = index
        }
        
        return control
    }
}
fileprivate extension RideRequestTypeScreenViewModel {
    func filterOptions() -> [(title:String, type:DriverType)] {
        var options:[(title:String, type:DriverType)] = [("No filter",.unspecified)]
        if shouldShowFemaleDriverMode() {
            options.append(("Female Driver Requests Only",.femaleDriver))
        }
        if shouldShowDCMode() {
            options.append(("Direct Connect Requests Only",.directConnect))
        }
        return options
    }
    func shouldShowFemaleDriverMode() -> Bool {
        return configManager!.global.availableFemaleDriverMode(forDriver: sessionManager!.currentSession!.driver)
    }
    func shouldShowDCMode() -> Bool {
        return configManager!.global.availableDCMode(forDriver: sessionManager!.currentSession!.driver)
    }
}

//  MARK: Car Types
fileprivate extension RideRequestTypeScreenViewModel {
    func selectedCar() -> Car? {
        return sessionManager?.currentSession?.driver?.selectedCar()
    }
    
    func activeAndSelectedCarTypes() -> [CarTypeViewModel] {
        return carTypeViewModels.filter { $0.isActive && $0.isSelected }
    }
    
    @objc func updateCarTypes() {
        if let session = sessionManager!.currentSession, let global = configManager?.global {
            let carTypesForSelectedCar:[String]? = session.driver!.selectedCar().carCategories
            let userCarTypes = session.userCarTypes
            for vm in carTypeViewModels {
                if let carTypesForSelectedCar = carTypesForSelectedCar {
                    if shouldShowFemaleDriverMode() && driverTypeFilter == .femaleDriver {
                        let femaleDriverModeEligibleCategories = Set(global.driverTypeOnlyWomenMode().availableInCategories);
                        let availableCategories = Set(carTypesForSelectedCar).intersection(femaleDriverModeEligibleCategories)
                        vm.isActive = availableCategories.contains(vm.carCategory())
                    } else {
                        vm.isActive = carTypesForSelectedCar.contains(vm.carCategory())
                    }
                }
                if let userCarTypes = userCarTypes {
                    vm.isSelected = vm.isActive && userCarTypes.contains(vm.carCategory())
                }
            }
            delegate?.didUpdateDataSource()
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
