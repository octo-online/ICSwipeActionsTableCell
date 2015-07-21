
import UIKit

public class ICSwipeActionsTableCell: UITableViewCell {
    
    // MARK: - properties

    public var buttonsTitles = []
    public var animationDuration = 0.3
    
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

    // MARK: - NSObject

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupEverythigng()
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
    
    // MARK: - UITableViewCell

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupEverythigng()
    }

    // MARK: - ICSwipeActionsTableCell

    func viewPanned(panRec: UIPanGestureRecognizer) {
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
    
    private func addTapGestureRecogniser() {
        _tapRec = UITapGestureRecognizer(target: self, action: "viewPanned:")
        if let validPan = _tapRec {
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
    
    private func hideButtons() {
        if ( !_buttonsAreHiding) {
            let newContentViewCenter = CGPointMake(_initialContentViewCenter.x, self.contentView.center.y)
            _currentContentViewCenter = newContentViewCenter
            _swipeExpanded = false
            _buttonsAreHiding = true
            
            UIView.animateWithDuration(animationDuration, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                self.contentView.center = newContentViewCenter
                }) { (completed) -> Void in
                    self.removeButtonsView()
            }
        }
    }
    
    
}
