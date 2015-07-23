
import UIKit

class ICDemoTableViewController: UITableViewController, ICSwipeActionsTableCellDelegate {

    
    // MARK: - properties
    
    var numberOfDemoCells = 10
    
    let moreButtonTitle = "MORE"
    let deleteButtonTitle = "DELETE THIS"
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(ICDemoTableViewCell.self, forCellReuseIdentifier: ICDemoTableViewCellIdentifier)
        self.tableView.registerNib(UINib(nibName: "ICDemoTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: ICDemoTableViewCellIdentifier)
        self.tableView.separatorColor = UIColor(red: 64.0/255.0, green: 0.0, blue: 128.0/255.0, alpha: 1.0)
    }

    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfDemoCells
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ICDemoTableViewCellIdentifier, forIndexPath: indexPath) as! ICDemoTableViewCell
        cell.indexPathLabel.text = "\(indexPath.row)"
        let textColor = UIColor(red: 1.0, green: 1.0, blue: 102.0/255.0, alpha: 1.0)
        cell.leftButtonsTitles = [(title:moreButtonTitle, color:UIColor(red: 128.0/255.0, green: 0.0, blue: 128.0/255.0, alpha: 1.0), textColor:textColor), (title:deleteButtonTitle, color:UIColor(red: 1.0, green: 0.0, blue: 128.0/255.0, alpha: 1.0), textColor:textColor)]
        cell.rightButtonsTitles = cell.leftButtonsTitles
        cell.delegate = self
        cell.buttonsEqualSize = true
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88.0
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRectMake(0, 0, tableView.frame.width, 20))
        view.backgroundColor = UIColor.whiteColor()
        return view
    }
    
    // MARK: - ICSwipeActionsTableCellDelegate
    
    func swipeCellButtonPressedWithTitle(title: String, indexPath: NSIndexPath) {
        if title == deleteButtonTitle {
            numberOfDemoCells -= 1
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        } else {
            numberOfDemoCells += 1
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        }
    }
}
