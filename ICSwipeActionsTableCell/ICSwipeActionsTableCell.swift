
import UIKit

public protocol ICSwipeActionsTableCellDelegate : NSObjectProtocol {
    func swipeCellButtonPressedWithTitle(title: String, indexPath: NSIndexPath)
}

public class ICSwipeActionsTableCell: UITableViewCell {
    
    // MARK: - properties

    public var buttonsTitles = []
    public var animationDuration = 0.3
    
    public var delegate: ICSwipeActionsTableCellDelegate?

    // MARK: - private properties

    private var _panRec: UIPanGestureRecognizer?
    private var _tapRec: UITapGestureRecognizer?
    
    private var _initialContentViewCenter = CGPointZero
    private var _currentContentViewCenter = CGPointZero
    
    private var _buttonsView: UIView?
    private var _buttonsViewWidth: CGFloat = 200.0
    private var _swipeExpanded = false
    private var _buttonsAreHiding = false
    
    private var _currentTouchInView = CGPointZero
    private var _currentTableView: UITableView?
    private var _currentTableViewOverlay: ICTableViewOvelay?

    // MARK: - NSObject

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupEverythigng()
    }

    deinit {
        self.removeTableOverlay()
    }
    
    // MARK: - UIView

    public override func layoutSubviews() {
        super.layoutSubviews()
        _initialContentViewCenter = self.contentView.center
    }

    public override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        _currentTouchInView = self.convertPoint(point, toView:self.contentView)
        return super.hitTest(point, withEvent: event)
    }
    
    public override func willMoveToSuperview(newSuperview: UIView?) {
        self.removeTableOverlay()
    }
    
    // MARK: - UITableViewCell

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupEverythigng()
    }

    
    // MARK: - ICSwipeActionsTableCell

    func hideButtons() {
        self.hideButtons(true)
    }
    func hideButtons(animated: Bool) {
        if ( !_buttonsAreHiding) {
            let newContentViewCenter = CGPointMake(_initialContentViewCenter.x, self.contentView.center.y)
            _currentContentViewCenter = newContentViewCenter
            _swipeExpanded = false
            _buttonsAreHiding = true
            self.removeTableOverlay()
            
            if animated {
                UIView.animateWithDuration(animationDuration, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                    self.contentView.center = newContentViewCenter
                    }) { (completed) -> Void in
                        self.removeButtonsView()
                }
            } else {
                self.contentView.center = newContentViewCenter
                self.removeButtonsView()
            }
        }
    }
    

    // MARK: - ICSwipeActionsTableCell internal

    internal func viewPanned(panRec: UIPanGestureRecognizer) {
        let velocity = panRec.velocityInView(self)
        if (velocity.x < 0) { // view panned left
            if (panRec.state == .Began) {
                self.handleLeftPanGestureBegan()
            }
        }
        
        self.handleLeftPanGestureChanged(panRec)
        
        if (panRec.state == .Ended) {
            self.handlePanGestureEnded(panRec, velocity: velocity)
        }
        
    }

    func buttonTouchUpInside(sender: UIButton) {
        if delegate != nil {
            if delegate!.respondsToSelector("swipeCellButtonPressedWithTitle::") {
                let indexPath = self.currentTableView()?.indexPathForCell(self)
                if indexPath != nil {
                    self.delegate!.swipeCellButtonPressedWithTitle(sender.titleLabel!.text!, indexPath: indexPath!)
                }
            }
        }
    }

    
    // MARK: - ICSwipeActionsTableCell ()
    
    
    // MARK: - Setup

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
    
    
    // MARK: - Button views

    private func addButtonsView() {
        if (_buttonsView != nil) {
            self.removeButtonsView()
        }
        _buttonsView = UIView(frame: CGRectMake(self.contentView.frame.size.width, 0, _buttonsViewWidth, self.contentView.frame.size.height))
        _buttonsView!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        _buttonsView!.backgroundColor = UIColor.redColor()
        self.contentView.addSubview(_buttonsView!)
        self.addTableOverlay()
    }
    
    private func removeButtonsView() {
        _buttonsView?.removeFromSuperview()
        _buttonsView = nil
        _buttonsAreHiding = false
    }
    
    // MARK: - GestureHandlers

    private func handleLeftPanGestureBegan() {
        if (self.selected) {
            self.selected = false
        }
        self.addButtonsView()
        _swipeExpanded = true
    }
    
    private func handlePanGestureEnded(panRec: UIPanGestureRecognizer, velocity: CGPoint) {
        var newContentViewCenter = CGPointZero

        if (velocity.x < 0) { // view panned left
            newContentViewCenter = CGPointMake(_initialContentViewCenter.x - _buttonsViewWidth, self.contentView.center.y)
            _currentContentViewCenter = newContentViewCenter
            UIView.animateWithDuration(animationDuration, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                self.contentView.center = newContentViewCenter
                }) { (completed) -> Void in
            }
        } else {
            self.hideButtons()
        }
    }
    
    private func handleLeftPanGestureChanged(panRec: UIPanGestureRecognizer) {
        let translation = panRec.translationInView(self)
        
        let newCenter = CGPointMake(self.contentView.center.x + translation.x, self.contentView.center.y)
        if ((_initialContentViewCenter.x - newCenter.x) < _buttonsViewWidth) { // no more then buttons width
            if (_initialContentViewCenter.x - newCenter.x > 0) { // no more then view size
                self.contentView.center = newCenter
                _currentContentViewCenter = newCenter
            }
        }
        panRec.setTranslation(CGPointZero, inView: self)
    }
    
    
    // MARK: - 
    
    private func currentTableView() -> UITableView? {
        if (_currentTableView == nil) {
            var view = self.superview;
            while (view != nil) {
                if (view!.isKindOfClass(UITableView.self)) {
                    _currentTableView = view as? UITableView
                }
                view = view!.superview
            }
        }
        return _currentTableView
    }
    
    public override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if gestureRecognizer == _tapRec {
            let tapLocation = gestureRecognizer.locationInView(_currentTableViewOverlay)
            if let _ = _buttonsView {
                if CGRectContainsPoint(_buttonsView!.frame, tapLocation) {
                    return false
                }
            }
        }
        return true
    }
    
    
    // MARK: - Table view overlay
    
    class ICTableViewOvelay: UIView {
        var parentCell : ICSwipeActionsTableCell?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            self.backgroundColor = UIColor.clearColor()
        }

        required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
            if parentCell != nil {
                if CGRectContainsPoint(parentCell!.bounds, self.convertPoint(point, toView: parentCell)) {
                    return nil
                }
            }
            parentCell?.hideButtons()
            return nil;
        }
    }

    private func addTableOverlay() {
        if let table = self.currentTableView() {
            _currentTableViewOverlay = ICTableViewOvelay(frame: table.frame)
            _currentTableViewOverlay?.parentCell = self
            table.addSubview(_currentTableViewOverlay!)
        }
    }
    
    private func removeTableOverlay() {
        _currentTableViewOverlay?.removeFromSuperview()
        _currentTableViewOverlay = nil
    }

}
