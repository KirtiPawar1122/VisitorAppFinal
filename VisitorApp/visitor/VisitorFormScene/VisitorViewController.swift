
import UIKit
import CoreData
import AVFoundation
import Toast_Swift

protocol VisitorFormDisplayLogic{
    func displayVisitorData(viewModel : VisitorForm.fetchVisitorRecord.ViewModel)
}

struct VisitorViewControllerConstants {
    static let selectedImageName = "camera-1"
    static let defaultImageName = "person-1"
    static let personImageName = "user"
    static let addressImageName = "address-100"
    static let phoneImageName = "phone-100"
    static let emailString = "email"
    static let emailImageName = "email-100"
    static let companyIamageName = "company"
    static let purposeImageName = "question-100"
    static let emailValidateMessage = "Please enter valid email ID"
    static let userValidateMessage = "Please enter name"
    static let addressValidateMessage = "Please enter address"
    static let phoneValidateMessage = "Please enter valid phone number"
    static let companyValidateMessage = "Please enter company Name"
    static let purposeValidateMessage = "Please enter visit purpose"
    static let visitingValidateMessage = "Please enter visiting person name"
    static let imageValidateMessage = "Please select Image"
    static let purposeOptionMenuMessage = "Choose Option"
    static let optionMenuFirstAction = "Guest Visit"
    static let optionMenuSecondAction = "Interview"
    static let optionMenuThirdAction = "Meeting"
    static let optionMenuFourthAction = "Other"
    static let checkmailAlert = "Welcome to Wurth IT"
    static let warningTitle = "Warning"
    static let warningImageMsg = "You don't have camera"
    static let alertOkActionMsg = "Ok"
    static let alertPrintActionTitle = "Print"
    static let alertCancelMsg = "Cancel"
    static let imageClickMsg = "Take Photo"
    static let imageChooseMsg = "Choose Photo "
    static let entityVisit = "Visit"
    static let entityVisitor = "Visitor"
    static let errorMassage = "error in function"
    static let nameString = "name"
    static let addressString = "address"
    static let phoneString = "phoneNo"
    static let profileImageString = "profileImage"
    static let dateFormat = "dd/MM/yyyy hh:mm a"
    static let maxTapCount = 5
    static let minTapCount = 0
}

class VisitorViewController: UIViewController,UITextFieldDelegate,VisitorFormDisplayLogic {

    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var scrollView : UIScrollView!
    @IBOutlet weak var visitorImage: CustomImageView!
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var userTextField: CustomTextField!
    @IBOutlet weak var addressTextField: CustomTextField!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var phoneTextField: CustomTextField!
    @IBOutlet weak var companyTextField: CustomTextField!
    @IBOutlet weak var purposeTextFeild: CustomTextField!
    @IBOutlet weak var visitTextField: CustomTextField!
    @IBOutlet weak var loadDataButton: UIBarButtonItem!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet var innerView: UIView!
    @IBOutlet var resetLabel: UIButton!
    @IBOutlet var takePictureButtonLabel: UIButton!
    var visitor : [Visitor] = []
    var visit = Visit()
    var visitPrintData = Visit()
    var arr = [Any]()
    var tapCount = 0
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var selectedImage = UIImage(named: VisitorViewControllerConstants.selectedImageName)
    var interactor : VisitorFormBusinessLogic?
    var router : VisitorRoutingLogic?
    let imagePicker = UIImagePickerController()
    var campareData : String = ""
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    var name: String = ""
    var compareEmail: String = ""
    var checkmail: String = ""
    var checkphoneNo: String = ""
    var profileImage: UIImage?
    var defaultImage = UIImage(named: VisitorViewControllerConstants.defaultImageName)
    
      
    //MARK: Object lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
      super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
       setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
      super.init(coder: aDecoder)
       setup()
    }

   //MARK: Setup
    private func setup() {
        let viewController = self
        let interactor = VisitorInteractor()
        let presenter = VisitorPresenter()
        let router = VisitorRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewObj = viewController
        router.viewcontroller = viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    //MARK: UI Setup Method
    func setUpUI(){
        
        hideKeyboardTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector( VisitorViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(VisitorViewController
            .keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapOnImageView = UITapGestureRecognizer(target: self, action: #selector(imageAction))
        visitorImage.addGestureRecognizer(tapOnImageView)
        visitorImage.isUserInteractionEnabled = true
              
        let tapPurposeTextFeild = UITapGestureRecognizer(target: self, action: #selector(purposeAction))
        purposeTextFeild.addGestureRecognizer(tapPurposeTextFeild)
        purposeTextFeild.isUserInteractionEnabled = true
        
        submitButton.layer.cornerRadius = submitButton.frame.height/2
        submitButton.layer.borderColor = UIColor.black.cgColor
        
        let resetIcon = UIImage(named: "refresh")
        navigationController?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: resetIcon, style: .plain, target: self, action: nil)
       
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.889849101, green: 0, blue: 0.1077023318, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.innerView.backgroundColor = .clear
        self.view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        setUpShadow()
    }
    
    func addImageOntextField(textField : CustomTextField,img : UIImage){
        let imageView = UIImageView()
        imageView.image = img
        imageView.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
        textField.addSubview(imageView)
        let leftView = UIView.init(frame: CGRect(x: 10, y: 0, width: 30, height: 30))
        textField.leftView = leftView;
        textField.leftViewMode = .always
        textField.returnKeyType = .next
    }
    
    func setUpShadow(){
        containerView.clipsToBounds = false
        containerView.layer.shadowColor = UIColor.systemGray.cgColor
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowOffset = CGSize.zero
        containerView.layer.shadowRadius = 7
        containerView.layer.cornerRadius = containerView.frame.height/2
        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: containerView.frame.height/2).cgPath
        visitorImage.clipsToBounds = true
        visitorImage.layer.cornerRadius = visitorImage.frame.height/2
    }

    @IBAction func takePictureButton(_ sender: Any) {
        imageAction()
    }
    
    //MARK: Keyboards related methods
    @objc func keyboardWillShow(notification: NSNotification) {
         guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
         }
        let contentInsets = UIEdgeInsets(top: .zero, left: .zero, bottom: keyboardSize.height, right: .zero)
         scrollView.contentInset = contentInsets
         scrollView.scrollIndicatorInsets = contentInsets
     }

    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets(top: .zero, left: .zero, bottom: .zero, right: .zero)
         scrollView.contentInset = contentInsets
         scrollView.scrollIndicatorInsets = contentInsets
    }

    func hideKeyboardTappedAround(){
        let tap : UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dissmissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dissmissKeyboard(){
        view.endEditing(true)
    }
    
    func displayVisitorData(viewModel: VisitorForm.fetchVisitorRecord.ViewModel) {
        print(viewModel)
        guard let visitData = viewModel.visit else {
           return
        }
        visit = visitData
        userTextField.text = visit.visitors?.value(forKey: VisitorViewControllerConstants.nameString) as? String
        companyTextField.text = visit.companyName
        visitTextField.text = visit.visitorName
        phoneTextField.text = visit.visitors?.value(forKey: VisitorViewControllerConstants.phoneString) as? String
        emailTextField.text = visit.visitors?.value(forKey: VisitorViewControllerConstants.emailString) as? String
        print(visit.visitors?.value(forKey: VisitorViewControllerConstants.profileImageString) as? Data as Any)
        guard let profileData = visit.visitors?.value(forKey: VisitorViewControllerConstants.profileImageString) else{
            return
        }
        
        let fethcedprofileImage = UIImage(data: profileData as! Data)
        //selectedImage = fethcedprofileImage
        if fethcedprofileImage?.size == defaultImage?.size{
            selectedImage = UIImage(named: VisitorViewControllerConstants.selectedImageName)
        } else {
            selectedImage = fethcedprofileImage
        }
        visitorImage.image = selectedImage
        checkmail = emailTextField.text!
        checkphoneNo = phoneTextField.text!
        myUtterance = AVSpeechUtterance(string: "Hello \(userTextField.text!), Welcome to Wurth IT")
        myUtterance.rate = 0.4
        synth.speak(myUtterance)
        userTextField.resignFirstResponder()
    }
    
    func fetchData(email : String, phoneNo : String){
        interactor?.fetchRequest(request: VisitorForm.fetchVisitorRecord.Request(phoneNo: phoneNo))
    }
    
    func checkMail(checkmail: String, phoneNo: String){
        fetchData(email: checkmail, phoneNo: phoneNo)
    }
    
    @IBAction func submitButtonClick(_ sender: Any) {
        validate()
    }
    
    //MARK: TextFeilds methods
    private func switchnextTextField(_ textField: UITextField){
        switch textField {
        case self.phoneTextField:
            self.emailTextField.becomeFirstResponder()
            
        case self.emailTextField:
            self.userTextField.becomeFirstResponder()
            
        case self.userTextField:
            self.companyTextField.becomeFirstResponder()
            
        case self.companyTextField:
            self.purposeTextFeild.becomeFirstResponder()
            
        case self.purposeTextFeild:
            self.visitTextField.becomeFirstResponder()
            
        case self.visitTextField:
            self.submitButton.becomeFirstResponder()
            
        default:
            self.submitButton.becomeFirstResponder()
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // code for fetch data
        if (phoneTextField.text != "" && emailTextField.text == "") {
          fetchData(email: emailTextField.text ?? "", phoneNo: phoneTextField.text ?? "" )
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField {
        case phoneTextField:
            guard let text = phoneTextField.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 10
        default:
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switchnextTextField(textField)
        textField.resignFirstResponder()
        purposeTextFeild.addTarget(self, action: #selector(purposeAction), for: .editingDidBegin)
        return true
    }

    @objc func emailAction(){
        fetchData(email: emailTextField.text ?? "" , phoneNo: phoneTextField.text ?? "")
        switchnextTextField(userTextField)
    }
    
    /* Navigation bar hide button */
    @IBAction func savedData(_ sender: Any) {
        tapCount = tapCount + 1
        if tapCount == VisitorViewControllerConstants.maxTapCount {
            router?.routeToVisitorList()
            tapCount = VisitorViewControllerConstants.minTapCount
        } else {
            print(VisitorViewControllerConstants.errorMassage)
        }
    }
        
    func validate() -> Bool{
        
        guard let phoneNo = phoneTextField.text, !phoneNo.isBlank, phoneNo.isphoneValidate(phone: phoneNo) else{
            self.view.makeToast(VisitorViewControllerConstants.phoneValidateMessage, duration: 3, position: .center)
            phoneTextField.shake()
            return false
        }
        guard let email = emailTextField.text, !email.isBlank, email.isValidEmail(mail: email) else {
            self.view.makeToast(VisitorViewControllerConstants.emailValidateMessage, duration: 3, position: .center)
            emailTextField.shake()
            return false
        }
        guard let name = userTextField.text, !name.isBlank else{
            self.view.makeToast(VisitorViewControllerConstants.userValidateMessage, duration: 3, position: .center)
            userTextField.shake()
            return false
        }
        guard let companyName = companyTextField.text, !companyName.isBlank else{
            self.view.makeToast(VisitorViewControllerConstants.companyValidateMessage, duration: 3, position: .center)
            companyTextField.shake()
            return false
        }
        guard let visitPurpose = purposeTextFeild.text, !visitPurpose.isBlank else{
            self.view.makeToast(VisitorViewControllerConstants.purposeValidateMessage, duration: 3, position: .center)
            purposeTextFeild.shake()
            return false
        }
        guard let visitorName = visitTextField.text, !visitorName.isBlank else{
            self.view.makeToast(VisitorViewControllerConstants.visitingValidateMessage, duration: 3, position: .center)
            visitTextField.shake()
            return false
        }
        
        if visitorImage.image == UIImage(named: VisitorViewControllerConstants.selectedImageName){
            selectedImage = UIImage(named: VisitorViewControllerConstants.defaultImageName)
        }
        
        print(visitorImage.image as Any)
        guard let profileImg = selectedImage?.pngData() else {
            self.view.makeToast(VisitorViewControllerConstants.imageValidateMessage, duration: 3, position: .center)
            return false
        }

        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = VisitorViewControllerConstants.dateFormat
        let dateString = formatter.string(from: now)
        let stringtoDate = formatter.date(from: dateString)
        print(dateString)
        
        if(checkphoneNo != phoneNo) {
            saveVisitorData(request: VisitorForm.saveVisitorRecord.Request(name: name, email: email, phoneNo: phoneNo, visitPurpose: visitPurpose, visitingName: visitorName, companyName: companyName, profileImage: profileImg, currentDate: stringtoDate))
            showAlert(for: "Hello \(name), Welcome to Wurth-IT")
            
        } else {
            saveVisitorData(request: VisitorForm.saveVisitorRecord.Request(name: name, email: email, phoneNo: phoneNo, visitPurpose: visitPurpose, visitingName: visitorName, companyName: companyName, profileImage: profileImg, currentDate: stringtoDate))
            
            let alert = UIAlertController(title: nil, message:
            VisitorViewControllerConstants.checkmailAlert, preferredStyle: .alert)
            let alertAtion = UIAlertAction(title: VisitorViewControllerConstants.alertOkActionMsg, style: .default, handler: { _ in
                self.resetTextFields()
            })
            let printAction = UIAlertAction(title: VisitorViewControllerConstants.alertPrintActionTitle, style: .default, handler: { _ in
                self.visitorPrint(phoneNo: phoneNo)
                self.resetTextFields()
            })
            alert.addAction(alertAtion)
            alert.addAction(printAction)
            present(alert, animated: true, completion: nil)
        }
        return true
    }

    func saveVisitorData(request: VisitorForm.saveVisitorRecord.Request){
        interactor?.saveVisitorRecord(request: request)
    }

    func resetTextFields() {
        userTextField.text = ""
        emailTextField.text = ""
        phoneTextField.text = ""
        companyTextField.text = ""
        visitTextField.text = ""
        purposeTextFeild.text = ""
        visitorImage.image = UIImage(named: VisitorViewControllerConstants.selectedImageName)
        selectedImage = UIImage(named: VisitorViewControllerConstants.selectedImageName)
    }
    
    @IBAction func refreshPage(_ sender: UIBarButtonItem) {
        resetTextFields()
    }
    
    func showAlert(for alert : String) {
        let alertController = UIAlertController(title: nil, message: alert, preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction(title: VisitorViewControllerConstants.alertOkActionMsg, style: .default, handler: { _ in
            self.resetTextFields()
        })
        let printAction = UIAlertAction(title: VisitorViewControllerConstants.alertPrintActionTitle, style: .default, handler: {
            _ in
            self.visitorPrint(phoneNo: self.phoneTextField.text!)
            self.resetTextFields()
        })
        alertController.addAction(alertAction)
        alertController.addAction(printAction)
        present(alertController, animated: true, completion: nil)
        myUtterance = AVSpeechUtterance(string: alertController.message!)
        myUtterance.rate = 0.4
        synth.speak(myUtterance)
    }
    
    func visitorPrint(phoneNo: String){
        print(phoneNo)
        router?.routeToVisitorPrint(phoneNo: phoneNo)
    }
}


// MARK: - ImageView and PurposeTextfeild Actions
extension VisitorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func imageAction() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: VisitorViewControllerConstants.imageClickMsg, style: .default, handler: { _ in
               self.openCamera()
          }))
        alert.addAction(UIAlertAction(title: VisitorViewControllerConstants.imageChooseMsg, style: .default, handler: { _ in
               self.openGallary()
          }))
        alert.addAction(UIAlertAction.init(title: VisitorViewControllerConstants.alertCancelMsg, style: .cancel, handler: nil))

        switch UIDevice.current.userInterfaceIdiom {
              case .pad:
                  alert.popoverPresentationController?.sourceView = self.view
                  alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                  alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
              default:
                      break
          }
        self.present(alert, animated: true, completion: nil)
      }
    
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            //If you dont want to edit the photo then you can set allowsEditing to false
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
        else{
            let alert  = UIAlertController(title: VisitorViewControllerConstants.warningTitle, message: VisitorViewControllerConstants.warningImageMsg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: VisitorViewControllerConstants.alertOkActionMsg, style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func openGallary(){
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        //If you dont want to edit the photo then you can set allowsEditing to false
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let orienatationFixedImage = image.fixOrientation()
        selectedImage = orienatationFixedImage
        visitorImage.image = selectedImage
        self.dismiss(animated: true, completion: nil)
    }

    @objc func purposeAction(){
        let optionMenu = UIAlertController(title: nil, message: VisitorViewControllerConstants.purposeOptionMenuMessage, preferredStyle: .actionSheet)
        let FirstAction = UIAlertAction(title: VisitorViewControllerConstants.optionMenuFirstAction, style: .default){ (_) in
            self.purposeTextFeild.text = VisitorViewControllerConstants.optionMenuFirstAction
            return
        }
        let SecondAction = UIAlertAction(title: VisitorViewControllerConstants.optionMenuSecondAction, style: .default){ (_) in
            self.purposeTextFeild.text = VisitorViewControllerConstants.optionMenuSecondAction
        }
        let ThirdAction = UIAlertAction(title: VisitorViewControllerConstants.optionMenuThirdAction, style: .default){ (_) in
            self.purposeTextFeild.text = VisitorViewControllerConstants.optionMenuThirdAction
        }
        let FourthAction = UIAlertAction(title: VisitorViewControllerConstants.optionMenuFourthAction, style: .default){ (_) in
            self.purposeTextFeild.text = VisitorViewControllerConstants.optionMenuFourthAction
        }
        
        optionMenu.addAction(FirstAction)
        optionMenu.addAction(SecondAction)
        optionMenu.addAction(ThirdAction)
        optionMenu.addAction(FourthAction)

        switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                optionMenu.popoverPresentationController?.sourceView = self.view
                optionMenu.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: .zero, height: .zero)
                optionMenu.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
            default:
                    break
        }
        self.present(optionMenu, animated: true,completion: nil)
    }
}

public extension UIView {

    func shake(count : Float = 3,for duration : TimeInterval = 0.3, withTranslation translation : Float = 10) {
        
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.repeatCount = count
        animation.duration = duration/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.values = [translation, -translation]
        layer.add(animation, forKey: "shake")
    }
}

extension CustomTextField {
     @IBInspectable var placeholderColor: UIColor {
           get {
               return self.placeholderColor
          //  return (self.attributedPlaceholder?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor)!
           }
           set {
               self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: [.foregroundColor: newValue])
           }
    }
    
}

extension UIImage {
    func fixOrientation() -> UIImage {
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        } else {
            return self
        }
    }
}
