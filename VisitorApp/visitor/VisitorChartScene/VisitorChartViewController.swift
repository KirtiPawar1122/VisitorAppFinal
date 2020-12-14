
import UIKit
import Charts

protocol VisitorChartDisplayLogic {
    func displayChart(viewModel: VisitorChart.VisitorChartData.ViewModel)
}

struct ChartViewControllerConstants{
    static let chartTitle = "Overall Visitors Data Chart"
    static let meetingTitle = "Meeting"
    static let guestVisitTitle = "Guest Visit"
    static let interviewTitle = "Interview"
    static let othersTitle = "Other"
}

class VisitorChartViewController: UIViewController, VisitorChartDisplayLogic {
   
    @IBOutlet weak var chartView: PieChartView!
    @IBOutlet var tableview: UITableView!
    
    var visits = [Visit]()
    var visitData = [Visit]()
    let purpose = ["Meeting", "Guest Visit", "Interview", "Others"]
    var meetings = 0
    var guestvisits = 0
    var interviews = 0
    var others = 0
    var chartRouter: VisitorChartRouter = VisitorChartRouter()
   // var chartInteractor : VisitorChartInteractor = VisitorChartInteractor()
    var chartDataInteractor: VisitorChartDataStore?
    var chartInteractor : VisitorChartBusinessLogic?
   // var chartRouter: VisitorChartDataPassing?
    
    //MARK: Object lifecycle
   override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
          super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
          setup()
    }

    required init?(coder aDecoder: NSCoder){
          super.init(coder: aDecoder)
          setup()
    }

    //MARK: Setup
    private func setup() {
        let viewController = self
        let interactor = VisitorChartInteractor()
        let presenter = VisitorChartPresenter()
        //let router = VisitorChartRouter()
        
        viewController.chartRouter = chartRouter
        viewController.chartInteractor = interactor
        viewController.chartDataInteractor = interactor
        interactor.data = visits
        interactor.presenter = presenter
        presenter.viewObj = viewController

    }
      
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = ChartViewControllerConstants.chartTitle
        getChartData()
        displayDataOnChart()
        print(visits.count)
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backImage")!)
        chartView.legend.enabled = true
        chartView.legend.textColor = UIColor.white
        chartView.legend.orientation = .horizontal
        chartView.legend.font = UIFont.systemFont(ofSize: 18)
        chartView.legend.horizontalAlignment = .center
    
        chartView.holeColor = UIColor(patternImage: UIImage(named: "backImage")!)
        chartView.notifyDataSetChanged()

        tableview.delegate = self
        tableview.dataSource = self
        tableview.backgroundColor = UIColor(patternImage: UIImage(named: "backImage")!)
        tableview.layer.borderColor = UIColor.white.cgColor
        tableview.layer.borderWidth = 2
    }
    
    func getChartData(){
        let request = VisitorChart.VisitorChartData.Request()
        chartInteractor?.visitorsChartData(request: request)
    }
    
    func displayChart(viewModel: VisitorChart.VisitorChartData.ViewModel) {
        visitData = viewModel.visitData
    }
       
    func displayDataOnChart(){
        for visit in visits {
            if let purpose = visit.purpose{
                if purpose == ChartViewControllerConstants.meetingTitle{
                      meetings = meetings + 1
                } else if purpose == ChartViewControllerConstants.guestVisitTitle{
                      guestvisits = guestvisits + 1
                } else if purpose == ChartViewControllerConstants.interviewTitle{
                      interviews = interviews + 1
                } else if purpose == ChartViewControllerConstants.othersTitle{
                      others = others + 1
                }
            }
        }
        let total = Double(visits.count)
        var meeting : Double{
            let meetingValue = 100 * Double(meetings) / total
            return meetingValue
        }
        var guestvisit : Double{
            let guestValue = 100 * Double(guestvisits) / total
            return guestValue
        }
        var interview : Double{
            let interviewValue = 100 * Double(interviews) / total
            return interviewValue
        }
        var other : Double{
            let otherValue = 100 * Double(others) / total
            return otherValue
        }
        let data = [meeting, guestvisit, interview, other]
        customizeChart(dataPoints: purpose, values: data)
    }
    
    func customizeChart(dataPoints: [String], values: [Double]) {
      // 1. Set ChartDataEntry
      //var dataEntries: [ChartDataEntry] = []
        var dataEntries: [PieChartDataEntry] = []
        for i in 0..<dataPoints.count {
        let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i], data: dataPoints[i] as AnyObject)
            if (dataEntry.y != 0) {
               dataEntries.append(dataEntry)
            }
            //dataEntries.append(dataEntry)
      }
      // 2. Set ChartDataSet
      let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
      pieChartDataSet.entryLabelColor  = UIColor.white
      pieChartDataSet.entryLabelFont = UIFont(name: "futura", size: 17)
      if let font = UIFont(name: "futura", size: 17) {
            pieChartDataSet.valueFont = font
      } else {
            print("error in to set font")
      }
        
      var colors: [UIColor] = []
      for item in dataEntries {
            if item.label == "Meeting"{
                colors.append(UIColor.systemBlue)
            } else if item.label == "Guest Visit" {
                colors.append(UIColor.purple)
            } else if item.label == "Interview" {
                colors.append(UIColor.systemGreen)
            } else if item.label == "Others" {
                colors.append(UIColor.systemRed)
            }
        }
     pieChartDataSet.colors = colors

      // 3. Set ChartData
      let pieChartData = PieChartData(dataSet: pieChartDataSet)
      let format = NumberFormatter()
      format.numberStyle = .percent
      format.multiplier = 1.0
      format.allowsFloats = true
      format.maximumFractionDigits = 2

      let formatter = DefaultValueFormatter(formatter: format)
      pieChartData.setValueFormatter(formatter)
      pieChartData.setValueTextColor(.white)
      //4. Assign it to the chart’s data
      chartView.data = pieChartData
    }
}

extension VisitorChartViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension VisitorChartViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purpose.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "VisitorPieChartTableViewCell", for: indexPath) as! VisitorPieChartTableViewCell
        let data = purpose[indexPath.row]
        cell.selectionStyle = .none
        cell.contentView.backgroundColor = UIColor.clear
        cell.layer.backgroundColor = UIColor.clear.cgColor
        cell.sectionTitleLabel.textColor = UIColor.white
        cell.dataCountLabel.textColor = UIColor.white
        cell.sectionTitleLabel.text = data
        
       /* if data == "Meeting" {
            cell.dataCountLabel.text = String(meetings)
            cell.backgroundColor = UIColor.systemBlue
        } else if data == "Interview"{
            cell.dataCountLabel.text = String(interviews)
            cell.backgroundColor = UIColor.systemGreen
        } else if data == "Guest Visit"{
            cell.dataCountLabel.text = String(guestvisits)
            cell.backgroundColor = UIColor.purple
        } else if data == "Others"{
            cell.dataCountLabel.text = String(others)
            cell.backgroundColor = UIColor.systemRed
        } */
    
        if indexPath.row == 0 {
            if data == "Meeting" {
            cell.dataCountLabel.text = String(meetings)
            cell.backgroundColor = UIColor.systemBlue
            }
        } else if indexPath.row == 1{
            if data == "Guest Visit"{
                cell.dataCountLabel.text = String(guestvisits)
                cell.backgroundColor = UIColor.purple
            }
        } else if indexPath.row == 2{
            if data == "Interview"{
                cell.dataCountLabel.text = String(interviews)
                cell.backgroundColor = UIColor.systemGreen
            }
        } else if indexPath.row == 3{
            if data == "Others"{
                cell.dataCountLabel.text = String(others)
                cell.backgroundColor = UIColor.systemRed
            }
        }
        return cell
    }
}

