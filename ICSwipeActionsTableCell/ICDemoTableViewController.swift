
import UIKit

class ICDemoTableViewController: UITableViewController {

    // MARK: - properties
    
    let numberOfDemoCells = 5

    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(ICDemoTableViewCell.self, forCellReuseIdentifier: ICDemoTableViewCellIdentifier)
        self.tableView.separatorColor = UIColor.whiteColor()
    }

    // MARK:  -  - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfDemoCells
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ICDemoTableViewCellIdentifier, forIndexPath: indexPath) as! ICDemoTableViewCell
        cell.backgroundColor = UIColor.purpleColor()
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.text = "\(indexPath.row)"
        cell.buttonsTitles = ["title1", "title2"]
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
}
