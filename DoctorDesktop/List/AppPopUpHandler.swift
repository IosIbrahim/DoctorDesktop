//
//  AppPopUpHandler.swift
//  CareMate
//
//  Created by MAC on 22/08/2021.
//  Copyright © 2021 khabeer Group. All rights reserved.
//

import Foundation
//


import Foundation
import PopupDialog
import MZFormSheetController

class AppPopUpHandler {
    
    static let instance = AppPopUpHandler()
    private init () {}
    
    func initListPopup(container: UIViewController, arrayNames: [String], title: String, type: String) {
        let vc = ListPopupViewController(arrayNames: arrayNames, header: title, type: type)
        print("type")

        print(type)
        vc.listPopupDelegate = container as? ListPopupDelegate
        let formSheet = MZFormSheetController.init(viewController: vc)
        formSheet.shouldDismissOnBackgroundViewTap = true
        formSheet.transitionStyle = .slideFromBottom
        formSheet.cornerRadius = 20
        formSheet.portraitTopInset = UIScreen.main.bounds.height * 0.5
        formSheet.presentedFormSheetSize = CGSize.init(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.5)
        formSheet.present(animated: true, completionHandler: nil)
    }
    
//    func initListPopupVisit(container: UIViewController,type: String,listOfVisits:[visitDTO]) {
////        let vc = ListPopupViewController(arrayNames: arrayNames, header: title, type: type)
////        print("type")
//        let vc =   VisitsViewController()
//
//        print(type)
//        vc.type = type
//        vc.fromDropDown = true
//        vc.listOfVisit = listOfVisits
//        vc.listPopupDelegate = container as? ListPopupDelegate
//        let formSheet = MZFormSheetController.init(viewController: vc)
//        formSheet.shouldDismissOnBackgroundViewTap = true
//        formSheet.transitionStyle = .slideFromBottom
//        formSheet.cornerRadius = 20
//        formSheet.portraitTopInset = UIScreen.main.bounds.height * 0.5
//        formSheet.presentedFormSheetSize = CGSize.init(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.5)
//        formSheet.present(animated: true, completionHandler: nil)
//    }
    
//    func initHintPopUp(container: UIViewController, message: String, type: String = "", dismiss: Bool = false) {
//        let vc = HintPopupViewController(message: message, type: type)
//        vc.delegate = container as? HintPopupDelegate
//        let popup = PopupDialog(viewController: vc, buttonAlignment: .horizontal, transitionStyle: .zoomIn, preferredWidth: 300, tapGestureDismissal: dismiss)
//        container.present(popup, animated: true, completion: nil)
//    }
//
//    func initOptionPopUp(container: UIViewController, message:String, type: String = "", extraData: String = "", extraData2: String = "") {
//        let vc = OptionPopupViewController.init(message: message, type: type, extraData: extraData, extraData2: extraData2)
//        vc.delegate = container as? OptionPopupDelegate
//        let popup = PopupDialog(viewController: vc, buttonAlignment: .horizontal, transitionStyle: .zoomIn, preferredWidth: 300, tapGestureDismissal: true, panGestureDismissal: true)
//        container.present(popup, animated: true, completion: nil)
//    }
//
//    func openPopup(container: UIViewController, vc: UIViewController) {
//        let popup = PopupDialog(viewController: vc, buttonAlignment: .horizontal, transitionStyle: .zoomIn, preferredWidth: 300, tapGestureDismissal: true, panGestureDismissal: true)
//        container.present(popup, animated: true, completion: nil)
//    }
//
    func openVCPop(_ vc: UIViewController, height: CGFloat) {
        let formSheet = MZFormSheetController.init(viewController: vc)
        formSheet.shouldDismissOnBackgroundViewTap = true
        formSheet.transitionStyle = .slideFromBottom
        formSheet.presentedFormSheetSize = CGSize.init(width: UIScreen.main.bounds.width * 0.9, height: height)
        formSheet.shouldCenterVertically = true
        formSheet.present(animated: true, completionHandler: nil)
    }
//
//
//    func openDataPickerPopUp(container: UIViewController, date: Date? = nil) {
//        let vc = DatePickerPopupViewController(minDate: date)
//        vc.delegate = container as? DataPickerPopupDelegate
//        let popup = PopupDialog(viewController: vc, buttonAlignment: .horizontal, transitionStyle: .zoomIn, preferredWidth: 300, tapGestureDismissal: true)
//        container.present(popup, animated: true, completion: nil)
//    }

}
