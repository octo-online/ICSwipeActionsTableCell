
import UIKit

public protocol ICSwipeActionsTableCellDelegate : NSObjectProtocol {
    func swipeCellButtonPressedWithTitle(title: String, indexPath: NSIndexPath)
}

public class ICSwipeActionsTableCell: UITableViewCell {
    
    // MARK: - types

    /// Tuple type with title string and background color.
    typealias ICButtonTitleWithColor = (title: String, color: UIColor)
    
    /// Tuple type with title string, title and background color.
    typealias ICButtonTitleWithTextAndBackgroundColor = (title: String, color: UIColor, textColor: UIColor)
    
    /// Tuple type with title string, title font, title and background color.
    typealias ICButtonTitleWithFontTextAndBackgroundColor = (title: String, font: UIFont, textColor: UIColor, color: UIColor)
    
    // MARK: - properties

    
    /// Array of button title properties, this can be one of three types:
    /// 1. Plain string:
    ///     // cell.buttonsTitles = ["Title 1", "Title 2"]
    ///
    /// 2. ICButtonTitleWithColor type:
    ///     // cell.buttonsTitles = [(title: "Title 1", color: UIColor.blackColor()), (title: "Title 2", color: UIColor.redColor())]
    ///
    /// 3. ICButtonTitleWithTextAndBackgroundColor type:
    ///     // [(title: "Title 1", color: UIColor.blackColor(), textColor:UIColor.whiteColor()), (title: "Title 2", color: UIColor.redColor(), textColor:UIColor.whiteColor())]
    ///
    /// 4. ICButtonTitleWithFontTextAndBackgroundColor type:
    ///     // [(title: "Title 1", font: UIFont.systemFontOfSize(22), textColor: UIColor.whiteColor(), color: UIColor.redColor())]
    ///
    /// Cell will recognise provided type automatically. All you need to worry about is the type that suits you best.
    public var buttonsTitles: [Any] = []
    
    ///  Buttons transiitons animation time. Default is 0.3, you can change it to whatever you like.
    public var animationDuration = 0.3
    
    ///  Buttons resize themselfes to the size of the title, this property will be applide to left and right margin between the title and button side. Default value is 16.
    public var buttonsSideMargins: CGFloat = 16.0
    
    ///  Flag indicating if the buttons should all be sized according to the biggest one. Default is no, meaning that every button will be the size of it's title.
    public var buttonsEqualSize = false
    
    /// The delegate that will respond to cell button touch up inside.
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
        if _swipeExpanded {
            if _buttonsView != nil {
                let p = self.convertPoint(point, toView: _buttonsView)
                if CGRectContainsPoint((_buttonsView?.bounds)!, p) {
                    return _buttonsView?.hitTest(p, withEvent: event)
                }
            }
        }
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

    
    /// Call this function to hide the buttons programmaticaly with animation. For non animated version use hideButtons(animated: Bool).
    func hideButtons() {
        self.hideButtons(true)
    }
    /// Call this function to hide the buttons programmaticaly.
    ///
    /// :param: animated optional parameter to determint if the action should be animated or not. Default value is true.
    func hideButtons(animated: Bool) {
        hideButtonsAnimated(animated, velocity: CGPointZero)
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
    
    internal func viewTapped(tapRec: UITapGestureRecognizer) {
        hideButtons()
    }
    
    internal func buttonTouchUpInside(sender: UIButton) {
        if delegate != nil {
            let indexPath = self.currentTableView()?.indexPathForCell(self)
            if indexPath != nil {
                self.delegate!.swipeCellButtonPressedWithTitle(sender.titleLabel!.text!, indexPath: indexPath!)
            }
        }
    }

    
    // MARK: - ICSwipeActionsTableCell ()
    
    // MARK: - Setup

    private func setupEverythigng() {
        self.addPanGestureRecognizer()
    }
    
    private func addPanGestureRecognizer() {
        _panRec = UIPanGestureRecognizer(target: self, action: "viewPanned:")
        if let validPan = _panRec {
            validPan.delegate = self
            self.addGestureRecognizer(validPan)
        }
    }
    
    private func addTapGestureRecognizer() {
        _tapRec = UITapGestureRecognizer(target: self, action: "viewTapped:")
        if let validTap = _tapRec {
            validTap.cancelsTouchesInView = true
            validTap.delegate = self
            self.addGestureRecognizer(validTap)
        }
    }
    
    private func removeTapGestureRecognizer() {
        if _tapRec != nil {
            self.removeGestureRecognizer(_tapRec!)
            _tapRec = nil
        }
    }
    
    // MARK: - Button views

    private func addButtonsView() {
        if (_buttonsView != nil) {
            removeButtonsView()
        }
        _buttonsView = self.prepareButtonsView()
        _buttonsView?.frame = CGRectMake(self.contentView.frame.size.width, 0, _buttonsViewWidth, self.contentView.frame.size.height)
        _buttonsView?.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        _buttonsView?.backgroundColor = UIColor.redColor()
        self.contentView.addSubview(_buttonsView!)
        addTapGestureRecognizer()
    }
    
    private func prepareButtonsView() -> UIView {
        if buttonsTitles.count > 0 {
            let view = UIView(frame: CGRectMake(0, 0, 0, self.contentView.frame.size.height))
            var maxButtonsWidth: CGFloat = 0
            
            for buttonProperty in buttonsTitles {
                let button = self.createButtonWith(buttonProperty)
                button.frame = CGRectMake(view.frame.size.width, 0, button.frame.size.width + 2 * buttonsSideMargins, view.frame.size.height)
                view.frame = CGRectMake(0, 0, view.frame.size.width + button.frame.width, view.frame.size.height)
                view.addSubview(button)
                maxButtonsWidth = max(maxButtonsWidth, button.frame.width)
            }
            if buttonsEqualSize {
                view.frame = CGRectMake(0, 0, maxButtonsWidth * CGFloat(buttonsTitles.count), view.frame.size.height)
                var currentX: CGFloat = 0
                for button in view.subviews {
                    button.frame = CGRectMake(currentX, 0, maxButtonsWidth, view.frame.size.height)
                    currentX += maxButtonsWidth
                }
            }
            _buttonsViewWidth = view.frame.size.width
            return view
        }
        return UIView()
    }
    
    private func createButtonWith(buttonProperty: Any) -> UIButton {
        let buttonFullProperties = self.buttonsPropertiesFromObject(buttonProperty)
        let button = UIButton(type: .Custom)
        button.setTitle(buttonFullProperties.title, forState: .Normal)
        button.backgroundColor = buttonFullProperties.color
        button.setTitleColor(buttonFullProperties.textColor, forState: .Normal)
        button.titleLabel?.font = buttonFullProperties.font
        button.sizeToFit()
        button.addTarget(self, action: "buttonTouchUpInside:", forControlEvents: .TouchUpInside)
        return button
    }
    
    private func buttonsPropertiesFromObject(buttonProperty: Any) -> ICButtonTitleWithFontTextAndBackgroundColor {
        var buttonTitle = ""
        var backgroundColor = self.anyColor()
        var titleColor = UIColor.whiteColor()
        var titleFont = UIFont.systemFontOfSize(15.0)
        if let stringTitle = buttonProperty as? String {
            buttonTitle = stringTitle
        } else if let colorTouple = buttonProperty as? ICButtonTitleWithColor {
            buttonTitle = colorTouple.title
            backgroundColor = colorTouple.color
        } else if let colorAndTextTouple = buttonProperty as? ICButtonTitleWithTextAndBackgroundColor {
            buttonTitle = colorAndTextTouple.title
            backgroundColor = colorAndTextTouple.color
            titleColor = colorAndTextTouple.textColor
        } else if let colorAndTitleAttrsTouple = buttonProperty as? ICButtonTitleWithFontTextAndBackgroundColor {
            buttonTitle = colorAndTitleAttrsTouple.title
            backgroundColor = colorAndTitleAttrsTouple.color
            titleFont = colorAndTitleAttrsTouple.font
            titleColor = colorAndTitleAttrsTouple.textColor
        }
        return (title: buttonTitle, font: titleFont, textColor: titleColor, color: backgroundColor)
    }
    
    private func anyColor() -> UIColor {
        let hue:CGFloat = (CGFloat)( arc4random() % 256 ) / 256.0  //  0.0 to 1.0
        let saturation:CGFloat = (CGFloat)( arc4random() % 128 ) / 256.0  //  0.0 to 1.0
        let brightness:CGFloat = (CGFloat)( arc4random() % 128 ) / 256.0  + 0.5 //  0.0 to 1.0
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
    
    private func removeButtonsView() {
        _buttonsView?.removeFromSuperview()
        _buttonsView = nil
        _buttonsAreHiding = false
    }
    
    func hideButtonsAnimated(animated: Bool, velocity: CGPoint) {
        if ( !_buttonsAreHiding) {
            let newContentViewCenter = CGPointMake(_initialContentViewCenter.x, self.contentView.center.y)
            _currentContentViewCenter = newContentViewCenter
            _swipeExpanded = false
            _buttonsAreHiding = true
            removeTableOverlay()
            
            func completition() {
                self.removeButtonsView()
                self.restoreTableSelection()
                self.removeTapGestureRecognizer()
            }
            
            if animated {
                var hideAnimationDuration = animationDuration
                if velocity != CGPointZero {
                    let currentDelta: Double = Double(_initialContentViewCenter.x) - Double(self.contentView.center.x)
                    let xVelocity: Double = Double(velocity.x)
                    hideAnimationDuration = currentDelta / xVelocity
                    if hideAnimationDuration < 0.0 || hideAnimationDuration > animationDuration {
                        hideAnimationDuration = animationDuration
                    }
                }
                UIView.animateWithDuration(hideAnimationDuration, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                    self.contentView.center = newContentViewCenter
                    }) { (completed) -> Void in
                        completition()
                }
            } else {
                self.contentView.center = newContentViewCenter
                completition()
            }
        }
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
                    self.addTableOverlay()
            }
        } else {
            hideButtonsAnimated(true, velocity: velocity)
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
    
    public override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer == _panRec) {
            
            if (self.editing) {
                return false
            }
            
            let translation = _panRec?.translationInView(self)
            if (fabs(translation!.y) > fabs(translation!.x)) {
                return false
            }
        }
        return true
    }
    
    
    // MARK: - parent TableView
    
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
    
    private func restoreTableSelection() {
        let tableView = currentTableView()
        let myIndexPath = tableView?.indexPathForCell(self)
        if myIndexPath != nil {
            let selectedRows = tableView?.indexPathsForSelectedRows
            if selectedRows != nil {
                if selectedRows!.contains(myIndexPath!) {
                    self.selected = true
                }
            }
        }
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
