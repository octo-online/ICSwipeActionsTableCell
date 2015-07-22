
import UIKit

class ICDemoTableViewController: UITableViewController, ICSwipeActionsTableCellDelegate {

    
    // MARK: - properties
    
    var numberOfDemoCells = 10
    
    let deleteButtonTitle = "DELETE"
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(ICDemoTableViewCell.self, forCellReuseIdentifier: ICDemoTableViewCellIdentifier)
        self.tableView.registerNib(UINib(nibName: "ICDemoTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: ICDemoTableViewCellIdentifier)
        self.tableView.separatorColor = UIColor.whiteColor()
    }

    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfDemoCells
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ICDemoTableViewCellIdentifier, forIndexPath: indexPath) as! ICDemoTableViewCell
        cell.indexPathLabel.text = "\(indexPath.row)"
        cell.buttonsTitles = [ (title:"OTHER", color:UIColor.blackColor()), (title:deleteButtonTitle, color:UIColor.redColor())]
        cell.delegate = self
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
