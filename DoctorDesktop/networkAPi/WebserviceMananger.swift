

import UIKit
import Alamofire
import Reachability
import SwiftyJSON

class WebserviceMananger: NSObject {
    struct Singleton {
        static let instance = WebserviceMananger()
    }
    
    class var sharedInstance: WebserviceMananger {
        return Singleton.instance
    }
    var callURL = ""
    func makeCall(method: HTTPMethod, url : String, parameters: [String: Any]? , vc:UIViewController? = nil , completionHandler : @escaping (AnyObject?,String?) -> ()) -> Void
    {
        print(url)
        
     
//        indicator.sharedInstance.show()
//        if Reachability.isConnectedToNetwork() {
          var parss = parameters
            AF.request(url, method: method, parameters: parss, encoding: JSONEncoding.default, headers: nil) .responseJSON
                { response in
//                indicator.sharedInstance.dismiss()
                
                print(parss)
                print(url)

                print(JSON(response.value))
                    print("response.response!.statusCode ")
                    print(response)
                    if response.response == nil || response.response!.statusCode == 500
                    {
                        Utilities.showAlert(vc, messageToDisplay:"Couldn't connect to server")
                        
                        return
                    }
                    if response.response!.statusCode == 404
                    {

                        Utilities.showAlert(vc, messageToDisplay: "Couldn't connect to server")
                        return
                    }
                    
                    switch response.result {
                    case .success (let value):
              
                        if let data = value as? [String: AnyObject]
                        {
                            
                            
//                            if  !data.keys.contains("PATIENT_ROW")
//                            {
//                                Utilities.showAlert(vc, messageToDisplay : "No Data")
//                                
//                                return
//                            }
                            print(data)
                            if data.keys.contains("Root")
                            {
                            let root = data["Root"] as? [String: AnyObject]
                                if ((root?.keys.contains("MESSAGE")) != nil)
                            {
                                    let messageRow = (root?["MESSAGE"] as? [String: AnyObject])?["MESSAGE_ROW"] as? [String : AnyObject]
                                    let englishMsg = messageRow?["NAME_EN"] as? String
                                    let arabicMsg = messageRow?["NAME_AR"] as? String
                                    
                                completionHandler(data as AnyObject?, nil)

                            }
                            else
                            {
                                completionHandler(data as AnyObject?, nil)

                            }
                            }
                            else
                            {
                                completionHandler(data as AnyObject?, nil)
                            }
                            
                        }
                        else
                        {
                            if let dat = value as? [[String:AnyObject]]
                            {
                                completionHandler(value as AnyObject?, nil)
                            }
                            else if let x = value as? String
                            {
                                completionHandler(["result":x] as AnyObject, nil)
                            }
                            else
                            {
                                Utilities.showAlert(vc, messageToDisplay : "No Internet Connection")
                            }
                        }
                    case .failure(let error):
                        completionHandler(nil, nil)

                    }
            }
            
//        } else {
//            Utilities.showAlert(vc, messageToDisplay : "No Internet Connection")
//        }
    }
    
    fileprivate  func getHTTpHeader(_ param:[String:Any]?) -> HTTPHeaders? {
        var newHeader : HTTPHeaders?
        if param != nil {
            newHeader = .init()
            var htpHeaders = [HTTPHeader]()
            let keys = param?.keys
            for (i,item) in keys!.enumerated() {
                for (j,val) in param!.values.enumerated() {
                    if i == j {
                        let head :HTTPHeader = .init(name: item, value: "\(val)")
                        htpHeaders.append(head)
                    }
                }
            }
            newHeader = .init(htpHeaders)
        }
        return newHeader
    }
    
    func makeCall(method: HTTPMethod, urlString : String, parameters: [String: Any]? , vc:UIViewController , headers :[String:String] , completionHandler : @escaping (AnyObject?,String?) -> ()) -> Void
    {
//        indicator.sharedInstance.show(vc)
//        if Reachability.isConnectedToNetwork() {
            print(urlString)
            AF.request(urlString, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: getHTTpHeader(headers)).responseJSON
                { response in
                    
                    switch response.result {
                    case .success (let value):
//                        indicator.sharedInstance.dismiss()
                        let data = value as! [String: AnyObject]
                        if let succ = data["key"]
                        {
                            if(data["key"] as! Bool == true ){ //Temp case
                                print(value)
                                
                                
                                completionHandler(value as AnyObject?, nil)
                            }
                            else
                            {
//                                indicator.sharedInstance.dismiss()
                                Utilities.showAlert(vc, messageToDisplay : "API Error "+data.description)
                                
                            }
                        }
                        
                    case .failure(let error):
//                        indicator.sharedInstance.dismiss()
                        
                        completionHandler(nil, error.localizedDescription)
                    }
            }
            
//        } else {
//            indicator.sharedInstance.dismiss()
//            Utilities.showAlert(vc, messageToDisplay : "No Internet Connection")
//            //            completionHandler(nil, nil)
//        }
    }
    
    
    func makeCallText(method: HTTPMethod, urlString : String, parameters: String , vc:UIViewController , headers :[String:String] , completionHandler : @escaping (AnyObject?,NSError?,Int) -> ()) -> Void
    {
//        indicator.sharedInstance.show(vc)
//        if Reachability.isConnectedToNetwork() {
            
            
            AF.request(urlString, method: method, parameters: [:], encoding: parameters , headers: getHTTpHeader(headers) ).responseJSON
                { response in
                    //                   response.resultc
                    switch response.result {
                    case .success (let value):
//                        indicator.sharedInstance.dismiss()
                        completionHandler(value as AnyObject?, nil , response.response!.statusCode)
                    case .failure(let error):
//                        indicator.sharedInstance.dismiss()
                        
                        completionHandler(nil, error as NSError?, response.response!.statusCode)
                        
                    }
            }
            
//        } else {
//            indicator.sharedInstance.dismiss()
//            Utilities.showAlert(vc, messageToDisplay : "No Internet Connection")
//            //            completionHandler(nil, nil)
//        }
    }
    
    
    
}


extension String: ParameterEncoding {
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
    
}

