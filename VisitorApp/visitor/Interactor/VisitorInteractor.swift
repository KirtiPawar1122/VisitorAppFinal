


import UIKit
import CoreData

struct VisitorInteractorConstants {
    static let visitorName = "name"
    static let visitorAddress = "address"
    static let visitorPhoneNo = "phoneNo"
    static let visitorEmail = "email"
    static let visitorProfileImage = "profileImage"
    static let visitorCompanyName = "companyName"
    static let visitorPurpose = "purpose"
    static let visitorImage = "visitImage"
    static let currentDate = "date"
    static let visitingPersonName = "visitorName"
    static let visitors = "visitors"
    static let entityVisitor = "Visitor"
    static let entityVisit = "Visit"
    static let predicateString = "visitors.phoneNo == %@"
    static let predicateVisitor = "phoneNo == %@"
    static let predicatePurpose = "purpose == %@"

    
}

protocol VisitorFormBusinessLogic{
    func fetchRequest(request: VisitorForm.fetchVisitorRecord.Request)
    func saveVisitorRecord(request: VisitorForm.saveVisitorRecord.Request)
}

class VisitorInteractor: VisitorFormBusinessLogic {
    
    var presenter : VisitorFormPrsentationLogic?
    var visitorCoreData : VisitorCoreDataStore = VisitorCoreDataStore()
      
    func saveVisitorRecord(request: VisitorForm.saveVisitorRecord.Request) {
        visitorCoreData.saveVisitorRecord(request: request)
    }
    
    func fetchRequest(request: VisitorForm.fetchVisitorRecord.Request) {
        
        visitorCoreData.fetchRecord(request: request) { (records) in
            let visitorResponse = VisitorForm.fetchVisitorRecord.Response(visit: records)
            self.presenter?.presentFetchResults(response: visitorResponse)
        }
    }
 
}
