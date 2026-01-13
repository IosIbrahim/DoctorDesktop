//
//  apis.swift
//  DoctorDesktop
//
//  Created by Macintosh HD on 9/18/19.
//  Copyright © 2019 khabeer Group. All rights reserved.
//
import Alamofire
import Foundation
import SwiftyJSON
class apis :NSObject {
        struct AlamofireAppManager {
            static let shared: Session = {
                let configuration = URLSessionConfiguration.default
                configuration.timeoutIntervalForRequest = 30
                configuration.timeoutIntervalForResource = 30
                let sessionManager = Alamofire.Session(configuration: configuration)
                return sessionManager
            }()
        }
    
     class func getPrescriptionDate(params : [String:String],completion: @escaping ( _ precrition:[precrition])->Void) {

        let url = AppURLS.ip+"/MobileApi/api/WorkFlowController/workflow"
        
        print(url)
        
       
      
        AlamofireAppManager.shared.request(url,parameters: params)
            .responseJSON { response in
                guard let data = response.data else { return }
                
                print(data)
                print(response)
                print(JSON(response))
//                var precritions1 = [precrition]()

                let keyPath = "Root"
                guard let precritions = try? Precritions (data: data, keyPath: keyPath)
                    
                    else {
                    if let precrition = try? precrition (data: data, keyPath: keyPath) {
                       return  
                    } else {
                        return 
                        //                        return []
                    }
                    return
                }
                
                completion(precritions)
                
                
//                finished(user)
        }
    }
    class func getPrescriptiondetails(params : [String:Any],completion: @escaping ( _ precrition:Welcome)->Void) {
        
        
        print(params)
        let url = AppURLS.ip+"/MobileApi/api/StockController/get_speciality_shortlist"
 
        AlamofireAppManager.shared.request(url,parameters: params)
            .responseJSON { response in
                guard let data = response.data else { return }
                
                print(data)
                print(response)
                print(JSON(response.value))
                
                switch response.result {
                case .success (let value):
                    do{
                        
                        let welcome1 = try?    JSONDecoder().decode(Welcome.self, from: data)
                        
                        completion(welcome1!)
                        
                    }
                    
                    catch{
                        
                    }
                    
                case .failure(let error):
                    print(error)
                    
                }
                
            }
    }
    
    class func getSearchResultInprecription(params : [String:Any],completion: @escaping ( _ precrition:searchModel?)->Void) {
        
        
        print(params)
        //http://192.168.1.174/MobileApi/api/StockController/get_speciality_shortlist?BRANCH_ID=1&FLAG=1&PATIENT_ID=569&PRESC_TYPE=1697&USER_ID=KHABEER&VISIT_ID=3
        
        let url = AppURLS.ip+"/MobileApi/api/StockController/GETDRUGS"
        
        print(url)
        
        
        
        AlamofireAppManager.shared.request(url,parameters: params)
            .responseJSON { response in
                guard let data = response.data else { return }
                
                print(data)
                print(response)
                
                switch response.result {
                case .success (let value):
                    do{
                        let searchResult = try?    JSONDecoder().decode(searchModel.self, from: data)
                        
                        guard let data  = searchResult else{
                            completion(nil)

                            return
                        }
                            completion(searchResult!)
                    }
                        
                    catch{
                        
                    }
        
                    
                case .failure(let error):
                    print(error)
                    
                }
            
        }
    }

    
    
}

