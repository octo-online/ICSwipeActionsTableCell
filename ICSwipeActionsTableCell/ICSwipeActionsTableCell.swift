
import UIKit

class ICSwipeActionsTableCell: UITableViewCell {
    
    // MARK: - properties

    private var _panRec: UIPanGestureRecognizer?
    
    
    // MARK: - NSObject

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupEverythigng()
    }

    // MARK: - UITableViewCell

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupEverythigng()
    }

    // MARK: - ICSwipeActionsTableCell ()

    func viewPanned(panRec: UIPanGestureRecognizer) {
        
    }

    // MARK: - ICSwipeActionsTableCell ()
    
    private func setupEverythigng() {
        self.addPanGestureRecogniser()
    }
    
    private func addPanGestureRecogniser() {
        _panRec = UIPanGestureRecognizer(target: self, action: "viewPanned:")
        if let validPan = _panRec {
            validPan.delegate = self
            self.addGestureRecognizer(validPan)
        }
    }
    
}
