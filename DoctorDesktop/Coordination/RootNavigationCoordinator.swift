//
//  NavigationCoordinator.swift
//  Doctor Desktop
//
//  Created by Jon Bott on 4/20/17.
//  Copyright © 2017 JonBott.com. All rights reserved.
//

import UIKit

protocol NavigationCoordinator: class {
  func next(arguments: Dictionary<String, Any>?)
  func movingBack()
}

enum NavigationState {
  case atLogin,
  atComponentCollection,
  atPatientList,
  atEmergencyTriage,
  atOrderCollection,
  atOrderServiceList,
  atOrderCheckoutList,
  atOverviewCollection,
  atOverviewSectionDetails,
  atWebViewer
}

class RootNavigationCoordinatorImpl: NavigationCoordinator {
  
  var registry: DependencyRegistry
  var rootViewController: UIViewController
  
  var navState: NavigationState = .atLogin
  
  init(with rootViewController: UIViewController, registry: DependencyRegistry) {
    self.rootViewController = rootViewController
    self.registry = registry
  }
  
  func movingBack() {
    switch navState {
    case .atLogin: //not possible to move back - do nothing
      break
    case .atComponentCollection: navState = .atLogin
    case .atPatientList: navState = .atComponentCollection

    case .atOrderCollection: navState = .atPatientList
    case .atEmergencyTriage: navState = .atPatientList
    case .atOrderServiceList: navState = .atOrderCollection
    case .atOrderCheckoutList: navState = .atOrderServiceList

    case .atOverviewCollection: navState = .atPatientList
    case .atOverviewSectionDetails: navState = .atOverviewCollection
    case .atWebViewer: navState = .atOverviewSectionDetails
    }
  }
  
  func next(arguments: Dictionary<String, Any>?) {
    
   print(arguments)
    
    
    switch navState {
    case .atLogin: showComponentCollection(arguments: arguments)
    case .atComponentCollection: showPatientList(arguments: arguments)
    case .atPatientList:
      guard let viewType = arguments!["viewType"] as? String else { break }
      switch viewType {
      case "overview": showOverviewCollection(arguments: arguments)
      case "order": showOrderCollection(arguments: arguments)
      case "emergency": showEmergencyTriage(arguments: arguments)
      default: break
      }
    case .atEmergencyTriage:
      if let viewType = arguments!["viewType"] as? String {
        switch viewType {
        case "overview": showOverviewCollection(arguments: arguments)
        case "order": showOrderCollection(arguments: arguments)
        default: break
        }
      }
    case .atOrderCollection:
      if let viewType = arguments!["viewType"] as? String {
        switch viewType {
        case "overview": showOverviewCollection(arguments: arguments)
        case "emergency": showEmergencyTriage(arguments: arguments)
        default: break
        }
      }
      else {
        showOrderServiceList(arguments: arguments)
      }
    case .atOrderServiceList: showOrderCheckoutList(arguments: arguments)
        
    case .atOrderCheckoutList: break
    case .atOverviewCollection:
      if let viewType = arguments!["viewType"] as? String {
        switch viewType {
        case "order": showOrderCollection(arguments: arguments)
        case "emergency": showEmergencyTriage(arguments: arguments)
        default: break
        }
      } else {
        showOverviewSectionDetails(arguments: arguments)
      }
    case .atOverviewSectionDetails: showWebViewer(arguments: arguments)
    case .atWebViewer: break
    }
  }
  
  func showComponentCollection(arguments: Dictionary<String, Any>?) {
    guard let component = arguments?["components"] as? Components,
      let user = arguments?["user"] as? User else { return }
    let componentViewController = registry.makeComponentCollectionViewController(with: component, user: user)
    rootViewController.navigationController?.pushViewController(componentViewController, animated: true)
    navState = .atComponentCollection
  }
  
  func showPatientList(arguments: Dictionary<String, Any>?) {
    guard let componentType = arguments?["componentType"] as? ComponentType,
      let user = arguments?["user"] as? User else { return }
    let patientsViewController = registry.makePatientsViewController(with: componentType, user: user)
    rootViewController.navigationController?.pushViewController(patientsViewController, animated: true)
    navState = .atPatientList
  }

  func showEmergencyTriage(arguments: Dictionary<String, Any>?) {
    guard let patient = arguments?["patient"] as? EmergencyPatient,
      let user = arguments?["user"] as? User else {return}
    let emergencyTriageViewController = registry.makeEmergencyTriageViewController(with: patient, user: user)
    //rootViewController.navigationController?.present(emergencyTriageViewController, animated: true, completion: nil)
    rootViewController.navigationController?.pushViewController(emergencyTriageViewController, animated: true)
    navState = .atEmergencyTriage
  }

  func showOrderCollection(arguments: Dictionary<String, Any>?) {
    guard let patient = arguments?["patient"] as? Patient,
      let templateType = arguments?["templateType"] as? TemplateType,
      let user = arguments?["user"] as? User else { return }
    let orderCollectionViewController = registry.makeOrderCollectionViewController(with: patient, templateType: templateType, user: user)
    //rootViewController.navigationController?.present(orderCollectionViewController, animated: true, completion: nil)
    rootViewController.navigationController?.pushViewController(orderCollectionViewController, animated: true)
    navState = .atOrderCollection
  }

  func showOrderServiceList(arguments: Dictionary<String, Any>?) {
    guard let patient = arguments?["patient"] as? Patient,
      let serviceCategory = arguments?["serviceCategory"] as? ServiceCategory,
      let templateType = arguments?["templateType"] as? TemplateType,
      let generalParams = arguments?["generalParams"] as? GeneralParams,
      let user = arguments?["user"] as? User else { return }
    let orderServiceListViewController = registry.makeOrderServiceList(with: patient, serviceCategory: serviceCategory, templateType: templateType, generalParams: generalParams, user: user)
    rootViewController.navigationController?.pushViewController(orderServiceListViewController, animated: true)
    navState = .atOrderServiceList
  }

  func showOrderCheckoutList(arguments: Dictionary<String, Any>?) {
    guard let servicesDetails = arguments?["servicesDetails"] as? ServicesDetails,
      let templateType = arguments?["templateType"] as? TemplateType,
      let user = arguments?["user"] as? User,
      let patient = arguments?["patient"] as? Patient,
      let requstDoctor = arguments?["requestDoctor"] as? String else { return }

    let orderCheckoutListViewController = registry.makeOrderCheckoutList(with: servicesDetails, templateType: templateType, user: user, labOrderServiceListPresenter: nil, patient: patient, requestDoctor: requstDoctor)
    rootViewController.navigationController?.pushViewController(orderCheckoutListViewController, animated: true)
    navState = .atOrderCheckoutList
  }

  func showOverviewCollection(arguments: Dictionary<String, Any>?) {
    guard let patient = arguments?["patient"] as? Patient,
      let user = arguments?["user"] as? User else { return }
    let overviewCollectionViewController = registry.makeOverviewCollectionViewController(with: patient, user: user)
    //rootViewController.navigationController?.present(overviewCollectionViewController, animated: true, completion: nil)
    rootViewController.navigationController?.pushViewController(overviewCollectionViewController, animated: true)
    navState = .atOverviewCollection
  }

  func showOverviewSectionDetails(arguments: Dictionary<String, Any>?) {
    guard let overviewSection = arguments?["overviewSection"] as? OverviewSection,
      let patientSummary = arguments?["patientSummary"] as? PatientSummary,
      let user = arguments?["user"] as? User else { return }
    let overviewSectionDetailsViewController = registry.makeOverviewSectionDetailsViewController(overviewSection: overviewSection, patientSummary: patientSummary, user: user)
    rootViewController.navigationController?.pushViewController(overviewSectionDetailsViewController, animated: true)
    navState = .atOverviewSectionDetails
  }

  func showWebViewer(arguments: Dictionary<String, Any>?) {
    guard let url = arguments?["url"] as? URL else { return }
    let webViewerViewController = registry.makeWebViewerViewController(url: url)
    rootViewController.navigationController?.pushViewController(webViewerViewController, animated: true)
    navState = .atWebViewer
  }

  //OrderCollection
  func notifyNilArguments() {
    print("notify user of error")
  }
}
