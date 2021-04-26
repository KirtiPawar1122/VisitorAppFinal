
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseDatabase

protocol VisitorPrintDisplayLogic{
    func displayVisitorPrint(viewModel: VisitorPrint.VisitorPrintData.ViewModel)
}

struct VisitorPrintViewControllerConstant{
    
      static let selectedImageName = "no-image"
      static let navBarTitle = "Visitor Pass Preview"
      static let dateFormatForDisplayOnCard = "MMM d, yyyy"
      static let dateFormatForSavedDBDate = "dd/MM/yyyy hh:mm a"
      static let nameString = "name"
      static let profileImage = "profileImage"
      static let xValue = -100
      static let yValue = 300
      static let width = 794
      static let height = 1123
      static let timeLimit = 8
}

class VisitorPrintViewController: UIViewController,VisitorPrintDisplayLogic {
   
    
    @IBOutlet var visitorCardView: UIView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var printButton: UIButton!
    @IBOutlet var VisitDate: UILabel!
    @IBOutlet var visitorName: UILabel!
    @IBOutlet var companyName: UILabel!
    @IBOutlet var companyLogo: UIImageView!
    @IBOutlet var purposeLabel: UILabel!
    @IBOutlet var hostLabel: UILabel!
    
    var printData = Visit()
    var printVisitData: Visit?
    var printInteractor: VisitorPrintBusinessLogic?
    var printRouter: VisitorPrintRouter = VisitorPrintRouter()
    var cardImage: UIImage?
    var selectedEmail = String()
    var selectedPhoneNo = String()
    var currentDate = Date()
    var printVisitorData: DisplayData?
    var printVisitorsData = [DisplayData]()
    var printedData = [VisitorModel]()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        setup()
    }
    
    //MARK: - Setup
    private func setup() {
        let viewController = self
        let router = VisitorPrintRouter()
        let interactor = VisitorPrintInteractor()
        let presenter = VisitorPrintPresenter()
        viewController.printInteractor = interactor
        interactor.printPresenter = presenter
        presenter.viewPrintLogic = viewController
        viewController.printRouter = router
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        print(printVisitorsData)
        print(printVisitData)
        print(printVisitorData)
    
    }
    
    func setupUI(){
        visitorCardView.layer.borderWidth = 1
        visitorCardView.layer.borderColor = #colorLiteral(red: 0.4407853214, green: 0.4373977654, blue: 0.4395006303, alpha: 1)
        visitorCardView.layer.cornerRadius = 10
        visitorCardView.layer.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
               
        printButton.layer.cornerRadius = printButton.frame.height/2
        printButton.layer.borderColor = UIColor.black.cgColor
        self.view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.navigationItem.title = VisitorPrintViewControllerConstant.navBarTitle
        
        // Logic for hide print button
         /* let todaysDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = VisitorPrintViewControllerConstant.dateFormatForSavedDBDate
        let currentSelectedDate = printVisitorsData[0].date
        let stringDate = formatter.string(from: currentSelectedDate ?? todaysDate)
        let selectedDate = formatter.date(from: stringDate)
        let timedata = getDateDiff(start: selectedDate!, end: currentDate)
        
        if timedata <= VisitorPrintViewControllerConstant.timeLimit {
            printButton.isHidden = false
        } else {
            printButton.isHidden = true
        } */
        
       /* if printVisitData != nil {
           formatter.dateFormat = VisitorPrintViewControllerConstant.dateFormatForDisplayOnCard
           let displayDate = formatter.string(from: printVisitData!.date!)
           VisitDate.text = displayDate
           visitorName.text = printVisitData?.visitors?.value(forKey: VisitorPrintViewControllerConstant.nameString) as? String
           hostLabel.text = printVisitData?.visitorName
           purposeLabel.text = printVisitData?.purpose
           guard let image = UIImage(data: printVisitData?.visitImage ?? Data()) else {
                return
           }
           profileImage.image = image
        } else {
            getPrintData()
        } */
        
       /* if printVisitorsData.count != 0 {
           let displayData = printVisitorsData[0]
           formatter.dateFormat = VisitorPrintViewControllerConstant.dateFormatForDisplayOnCard
            let displayDate = formatter.string(from: displayData.date)
           VisitDate.text = displayDate
            visitorName.text = displayData.name
           hostLabel.text = displayData.contactPerson
           purposeLabel.text = displayData.purspose
          /* guard let image = UIImage(data: printVisitorData?.profileImage ?? Data()) else {
                return
           } */
           guard let image = UIImage(named: displayData.profileImage) else { return }
           profileImage.image = image
        } else {
            getPrintData()
        } */
        printVisitorCardData()
    }
    
    func printVisitorCardData(){
        if printVisitorsData.count != 0 {
            let displayData = printVisitorsData[0]
            let formatter = DateFormatter()
            let todaysDate = Date()
            formatter.dateFormat = VisitorPrintViewControllerConstant.dateFormatForDisplayOnCard
            let displayDate = formatter.string(from: todaysDate)
            VisitDate.text = displayDate
            visitorName.text = displayData.name
            hostLabel.text = displayData.contactPerson
            purposeLabel.text = displayData.purspose
            guard let profileURL = URL(string: displayData.profileImage) else { return }
            profileImage.af.setImage(withURL: profileURL )
        } else if printedData.count != 0 {
            let displayData = printedData[0]
            let visits = displayData.visits
            print(visits[0])
            let formatter = DateFormatter()
            formatter.dateFormat = VisitorPrintViewControllerConstant.dateFormatForDisplayOnCard
            let displayDate = formatter.string(from: visits[0].date)
            VisitDate.text = displayDate
            visitorName.text = displayData.name
            hostLabel.text = visits[0].contactPersonName
            purposeLabel.text = visits[0].purpose
            guard let profileURL = URL(string: visits[0].profileVisitImage) else { return }
            profileImage.af.setImage(withURL: profileURL)
        } else {
            print("Directly fetch data from firebase")
            let displayData = printVisitorData
            let formatter = DateFormatter()
            formatter.dateFormat = VisitorPrintViewControllerConstant.dateFormatForDisplayOnCard
            let displayDate = formatter.string(from: (displayData?.date)!)
            VisitDate.text = displayDate
            visitorName.text = displayData?.name
            hostLabel.text = displayData?.contactPerson
            purposeLabel.text = displayData?.purspose
            guard let profileURL = URL(string: displayData!.profileImage) else { return }
            profileImage.af.setImage(withURL: profileURL )
        }
        
    }
    
    
    func getPrintData(){
        let request = VisitorPrint.VisitorPrintData.Request(phoneNo: selectedPhoneNo)
        printInteractor?.fetchVisitorPrintData(request: request)
    }
    
    func getDateDiff(start: Date, end: Date) -> Int  {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([Calendar.Component.second], from: start, to: end)
        let seconds = dateComponents.second
        return Int(seconds! / 3600)
    }

    func displayVisitorPrint(viewModel: VisitorPrint.VisitorPrintData.ViewModel) {
        let formatter = DateFormatter()
        formatter.dateFormat = VisitorPrintViewControllerConstant.dateFormatForDisplayOnCard
        
        guard let savedVisitDate = viewModel.visitData?.date else { return }
        let displayDate = formatter.string(from: savedVisitDate)
        VisitDate.text = displayDate
        visitorName.text = viewModel.visitData?.visitors?.value(forKey: VisitorPrintViewControllerConstant.nameString) as? String
        purposeLabel.text = viewModel.visitData?.purpose
        hostLabel.text = viewModel.visitData?.visitorName
        guard let image = UIImage(data: viewModel.visitData?.visitImage ?? Data()) else{
            return
        }
        profileImage.image = image
    }
    
    @IBAction func onPrintAction(_ sender: Any) {
        //convert UIView into PDF & Save - alert display
      
        let pdfFilePath = visitorCardView.createPDFfromView()
        let pdfURL = NSURL.fileURL(withPath: pdfFilePath)
        let items = [ pdfURL as Any]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if UIDevice.current.userInterfaceIdiom == .pad {
            ac.popoverPresentationController?.sourceView = printButton
        }
        present(ac, animated: true, completion: nil)
    }
}

extension UIView {
    func takeSnapShot() -> UIImage? {
       UIGraphicsBeginImageContext(CGSize(width: self.frame.width, height: self.frame.height ))
       let rect = CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height)
       drawHierarchy(in: rect, afterScreenUpdates: true)
       let image = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()
       return image
    }
    
    func createPDFfromView() -> String {
        // Fixed height and width to set alignment as center to print preview
        let pdfPageFrame = CGRect(x: VisitorPrintViewControllerConstant.xValue, y: VisitorPrintViewControllerConstant.height/5, width: VisitorPrintViewControllerConstant.width, height: VisitorPrintViewControllerConstant.height)
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
        UIGraphicsBeginPDFPageWithInfo(pdfPageFrame, nil)
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return "" }
        self.layer.render(in: pdfContext)
        UIGraphicsEndPDFContext()
        return self.saveViewPdf(data: pdfData)
    }
    
    func saveViewPdf(data: NSMutableData) -> String {
      let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
      let docDirectoryPath = paths[0]
      let pdfPath = docDirectoryPath.appendingPathComponent("viewPdf.pdf")
      if data.write(to: pdfPath, atomically: true) {
          return pdfPath.path
      } else {
          return ""
      }
    }
}

extension UIImage{
     func saveToPhotoLibrary(_ completionTarget: Any?, _ completionSelector: Selector?) {
           DispatchQueue.global(qos: .userInitiated).async {
               UIImageWriteToSavedPhotosAlbum(self, completionTarget, completionSelector, nil)
           }
       }
}
