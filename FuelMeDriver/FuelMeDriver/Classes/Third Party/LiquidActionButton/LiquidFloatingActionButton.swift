//
//  LiquidFloatingActionButton.swift
//  Pods
//
//  Created by Takuma Yoshida on 2015/08/25.
//
//

import Foundation
import QuartzCore
import UIKit

// LiquidFloatingButton DataSource methods
@objc public protocol LiquidFloatingActionButtonDataSource {
    func numberOfCells(_ liquidFloatingActionButton: LiquidFloatingActionButton) -> Int
    func cellForIndex(_ index: Int) -> LiquidFloatingCell
}

@objc public protocol LiquidFloatingActionButtonDelegate {
    // selected method
    @objc optional func liquidFloatingActionButton(_ liquidFloatingActionButton: LiquidFloatingActionButton, didSelectItemAtIndex index: Int)
}

public enum LiquidFloatingActionButtonAnimateStyle : Int {
    case up
    case right
    case left
    case down
}

@IBDesignable
@objc open class LiquidFloatingActionButton : UIView {

    fileprivate let internalRadiusRatio: CGFloat = 20.0 / 56.0
    open var cellRadiusRatio: CGFloat      = 0.38
    open var animateStyle: LiquidFloatingActionButtonAnimateStyle = .up {
        didSet {
            baseView.animateStyle = animateStyle
        }
    }
    open var enableShadow = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @objc weak open var delegate:   LiquidFloatingActionButtonDelegate?
    @objc weak open var dataSource: LiquidFloatingActionButtonDataSource?

    open var responsible = true
    @objc open var isOpening: Bool  {
        get {
            return !baseView.openingCells.isEmpty
        }
    }
    @objc open fileprivate(set) var isClosed: Bool = true
    
    @IBInspectable open var color: UIColor = UIColor(red: 82 / 255.0, green: 112 / 255.0, blue: 235 / 255.0, alpha: 1.0) {
        didSet {
            baseView.color = color
        }
    }
    
    @IBInspectable open var image: UIImage? {
        didSet {
            if image != nil {
                plusLayer.contents = image!.cgImage
                plusLayer.path = nil
            }
        }
    }
    
    @IBInspectable open var rotationDegrees: CGFloat = 45.0

    fileprivate var plusLayer   = CAShapeLayer()
    fileprivate let circleLayer = CAShapeLayer()
    
    fileprivate var touching = false

    fileprivate var baseView = CircleLiquidBaseView()
    fileprivate let liquidView = UIView()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    fileprivate func insertCell(_ cell: LiquidFloatingCell) {
        cell.color  = self.baseView.color//UIColor.blue
        cell.radius = self.frame.width * cellRadiusRatio
        cell.center = self.center.minus(self.frame.origin)
        cell.actionButton = self
        insertSubview(cell, aboveSubview: baseView)
    }
    
    fileprivate func cellArray() -> [LiquidFloatingCell] {
        var result: [LiquidFloatingCell] = []
        if let source = dataSource {
            for i in 0..<source.numberOfCells(self) {
                result.append(source.cellForIndex(i))
            }
        }
        return result
    }

    // open all cells
    @objc open func open() {
        
        // rotate plus icon
        CATransaction.setAnimationDuration(0.8)
        self.plusLayer.transform = CATransform3DMakeRotation((CGFloat(Double.pi) * rotationDegrees) / 180, 0, 0, 1)

        let cells = cellArray()
        for cell in cells {
            insertCell(cell)
        }

        self.baseView.open(cells)
        
        self.isClosed = false
    }

    // close all cells
    @objc open func close() {
        
        // rotate plus icon
        CATransaction.setAnimationDuration(0.8)
        self.plusLayer.transform = CATransform3DMakeRotation(0, 0, 0, 1)
    
        self.baseView.close(cellArray())
        
        self.isClosed = true
    }

    // MARK: draw icon
    open override func draw(_ rect: CGRect) {
        drawCircle()
        drawShadow()
    }
    
    /// create, configure & draw the plus layer (override and create your own shape in subclass!)
    open func createPlusLayer(_ frame: CGRect) -> CAShapeLayer {
        
        // draw plus shape
        let plusLayer = CAShapeLayer()
        plusLayer.lineCap = CAShapeLayerLineCap.round
        plusLayer.strokeColor = UIColor(red: 100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0, alpha: 1).cgColor
        plusLayer.lineWidth = 2.0
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.width * internalRadiusRatio, y: frame.height * 0.5))
        path.addLine(to: CGPoint(x: frame.width * (1 - internalRadiusRatio), y: frame.height * 0.5))
        path.move(to: CGPoint(x: frame.width * 0.5, y: frame.height * internalRadiusRatio))
        path.addLine(to: CGPoint(x: frame.width * 0.5, y: frame.height * (1 - internalRadiusRatio)))
        
        plusLayer.path = path.cgPath
        return plusLayer
    }
    
    fileprivate func drawCircle() {
        self.circleLayer.cornerRadius = self.frame.width * 0.5
        self.circleLayer.masksToBounds = true
        if touching && responsible {
            self.circleLayer.backgroundColor = self.color.white(0.5).cgColor
        } else {
            self.circleLayer.backgroundColor = self.color.cgColor
        }
    }
    
    fileprivate func drawShadow() {
        if enableShadow {
            circleLayer.appendShadow()
        }
    }
    
    // MARK: Events
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touching = true
        setNeedsDisplay()
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touching = false
        setNeedsDisplay()
        didTapped()
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        self.touching = false
        setNeedsDisplay()
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for cell in cellArray() {
            let pointForTargetView = cell.convert(point, from: self)
            
            if (cell.bounds.contains(pointForTargetView)) {
                if cell.isUserInteractionEnabled {
                    return cell.hitTest(pointForTargetView, with: event)
                }
            }
            
            if let cell = cell as? LiquidFloatingLabelCell {
                let pointToTest = cell.label.convert(point, from: self)
                if cell.label.bounds.contains(pointToTest) {
                    return cell.label.hitTest(pointToTest, with:event)
                }
            }
    
        }
        
        return super.hitTest(point, with: event)
    }
    
    // MARK: private methods
    fileprivate func setup() {
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = false

        baseView.setup(self)
        addSubview(baseView)
        
        liquidView.frame = baseView.frame
        liquidView.isUserInteractionEnabled = false
        addSubview(liquidView)
        
        liquidView.layer.addSublayer(circleLayer)
        circleLayer.frame = liquidView.layer.bounds
        
        plusLayer = createPlusLayer(circleLayer.bounds)
        circleLayer.addSublayer(plusLayer)
        plusLayer.frame = circleLayer.bounds
    }

    fileprivate func didTapped() {
        if isClosed {
            open()
        } else {
            close()
        }
    }
    
    open func didTappedCell(_ target: LiquidFloatingCell) {
        if let _ = dataSource {
            let cells = cellArray()
            for i in 0..<cells.count {
                let cell = cells[i]
                if target === cell {
                    delegate?.liquidFloatingActionButton?(self, didSelectItemAtIndex: i)
                }
            }
        }
    }

}

class ActionBarBaseView : UIView {
    var opening = false
    func setup(_ actionButton: LiquidFloatingActionButton) {
    }
    
    func translateY(_ layer: CALayer, duration: CFTimeInterval, f: (CABasicAnimation) -> ()) {
        let translate = CABasicAnimation(keyPath: "transform.translation.y")
        f(translate)
        translate.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        translate.isRemovedOnCompletion = false
        translate.fillMode = CAMediaTimingFillMode.forwards
        translate.duration = duration
        layer.add(translate, forKey: "transYAnim")
    }
}

class CircleLiquidBaseView : ActionBarBaseView {

    let openDuration: CGFloat  = 0.6
    let closeDuration: CGFloat = 0.2
    let viscosity: CGFloat     = 0.65
    var animateStyle: LiquidFloatingActionButtonAnimateStyle = .up
    var color: UIColor = UIColor(red: 82 / 255.0, green: 112 / 255.0, blue: 235 / 255.0, alpha: 1.0) {
        didSet {
            engine?.color = color
            bigEngine?.color = color
        }
    }

    var baseLiquid: LiquittableCircle?
    var engine:     SimpleCircleLiquidEngine?
    var bigEngine:  SimpleCircleLiquidEngine?
    var enableShadow = true

    fileprivate var openingCells: [LiquidFloatingCell] = []
    fileprivate var keyDuration: CGFloat = 0
    fileprivate var displayLink: CADisplayLink?

    override func setup(_ actionButton: LiquidFloatingActionButton) {
        self.frame = actionButton.frame
        self.center = actionButton.center.minus(actionButton.frame.origin)
        self.animateStyle = actionButton.animateStyle
        let radius = min(self.frame.width, self.frame.height) * 0.5
        self.engine = SimpleCircleLiquidEngine(radiusThresh: radius * 0.73, angleThresh: 0.45)
        engine?.viscosity = viscosity
        self.bigEngine = SimpleCircleLiquidEngine(radiusThresh: radius, angleThresh: 0.55)
        bigEngine?.viscosity = viscosity
        self.engine?.color = actionButton.color
        self.bigEngine?.color = actionButton.color

        baseLiquid = LiquittableCircle(center: self.center.minus(self.frame.origin), radius: radius, color: actionButton.color)
        baseLiquid?.clipsToBounds = false
        baseLiquid?.layer.masksToBounds = false
        
        clipsToBounds = false
        layer.masksToBounds = false
        addSubview(baseLiquid!)
    }

    func open(_ cells: [LiquidFloatingCell]) {
        stop()
        displayLink = CADisplayLink(target: self, selector: #selector(CircleLiquidBaseView.didDisplayRefresh(_:)))
        displayLink?.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
        opening = true
        for cell in cells {
            cell.layer.removeAllAnimations()
            cell.layer.eraseShadow()
            openingCells.append(cell)
        }
    }
    
    func close(_ cells: [LiquidFloatingCell]) {
        stop()
        opening = false
        displayLink = CADisplayLink(target: self, selector: #selector(CircleLiquidBaseView.didDisplayRefresh(_:)))
        displayLink?.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
        for cell in cells {
            cell.layer.removeAllAnimations()
            cell.layer.eraseShadow()
            openingCells.append(cell)
            cell.isUserInteractionEnabled = false
        }
    }

    func didFinishUpdate() {
        if opening {
            for cell in openingCells {
                cell.isUserInteractionEnabled = true
            }
        } else {
            for cell in openingCells {
                cell.removeFromSuperview()
            }
        }
    }

    func update(_ delay: CGFloat, duration: CGFloat, f: (LiquidFloatingCell, Int, CGFloat) -> ()) {
        if openingCells.isEmpty {
            return
        }

        let maxDuration = duration + CGFloat(openingCells.count) * CGFloat(delay)
        let t = keyDuration
        let allRatio = easeInEaseOut(t / maxDuration)

        if allRatio >= 1.0 {
            didFinishUpdate()
            stop()
            return
        }

        engine?.clear()
        bigEngine?.clear()
        for i in 0..<openingCells.count {
            let liquidCell = openingCells[i]
            let cellDelay = CGFloat(delay) * CGFloat(i)
            let ratio = easeInEaseOut((t - cellDelay) / duration)
            f(liquidCell, i, ratio)
        }

        if let firstCell = openingCells.first {
            _ = bigEngine?.push(circle: baseLiquid!, other: firstCell)
        }
        for i in 1..<openingCells.count {
            let prev = openingCells[i - 1]
            let cell = openingCells[i]
            _ = engine?.push(circle: prev, other: cell)
        }
        engine?.draw(parent: baseLiquid!)
        bigEngine?.draw(parent: baseLiquid!)
    }
    
    func updateOpen() {
        update(0.1, duration: openDuration) { cell, i, ratio in
            let posRatio = ratio > CGFloat(i) / CGFloat(self.openingCells.count) ? ratio : 0
            let distance = (cell.frame.height * 0.5 + CGFloat(i + 1) * cell.frame.height * 1.5) * posRatio
            cell.center = self.center.plus(self.differencePoint(distance))
            cell.update(ratio, open: true)
        }
    }
    
    func updateClose() {
        update(0, duration: closeDuration) { cell, i, ratio in
            let distance = (cell.frame.height * 0.5 + CGFloat(i + 1) * cell.frame.height * 1.5) * (1 - ratio)
            cell.center = self.center.plus(self.differencePoint(distance))
            cell.update(ratio, open: false)
        }
    }
    
    func differencePoint(_ distance: CGFloat) -> CGPoint {
        switch animateStyle {
        case .up:
            return CGPoint(x: 0, y: -distance)
        case .right:
            return CGPoint(x: distance, y: 0)
        case .left:
            return CGPoint(x: -distance, y: 0)
        case .down:
            return CGPoint(x: 0, y: distance)
        }
    }
    
    func stop() {
        for cell in openingCells {
            if enableShadow {
                cell.layer.appendShadow()
            }
        }
        openingCells = []
        keyDuration = 0
        displayLink?.invalidate()
    }
    
    func easeInEaseOut(_ t: CGFloat) -> CGFloat {
        if t >= 1.0 {
            return 1.0
        }
        if t < 0 {
            return 0
        }
        return -1 * t * (t - 2)
    }
    
    @objc func didDisplayRefresh(_ displayLink: CADisplayLink) {
        if opening {
            keyDuration += CGFloat(displayLink.duration)
            updateOpen()
        } else {
            keyDuration += CGFloat(displayLink.duration)
            updateClose()
        }
    }

}

@objc open class LiquidFloatingCell : LiquittableCircle {
    
    let internalRatio: CGFloat = 0.75

    open var responsible = true
    open var imageView = UIImageView()
    weak var actionButton: LiquidFloatingActionButton?

    // for implement responsible color
    fileprivate var originalColor: UIColor
    
    open override var frame: CGRect {
        didSet {
            resizeSubviews()
        }
    }

    init(center: CGPoint, radius: CGFloat, color: UIColor, icon: UIImage) {
        self.originalColor = color
        super.init(center: center, radius: radius, color: color)
        setup(icon)
    }

    init(center: CGPoint, radius: CGFloat, color: UIColor, view: UIView) {
        self.originalColor = color
        super.init(center: center, radius: radius, color: color)
        setupView(view)
    }
    
    public init(icon: UIImage) {
        self.originalColor = UIColor.clear
        super.init()
        setup(icon)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(_ image: UIImage, tintColor: UIColor = UIColor(red: 100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0, alpha: 1)) {
        imageView.image = image.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        imageView.tintColor = tintColor
        imageView.contentMode = .scaleAspectFit
        setupView(imageView)
    }
    
    open func setupView(_ view: UIView) {
        isUserInteractionEnabled = false
        addSubview(view)
        resizeSubviews()
    }
    
    fileprivate func resizeSubviews() {
        let size = CGSize(width: frame.width * 0.5, height: frame.height * 0.5)
        imageView.frame = CGRect(x: frame.width - frame.width * internalRatio, y: frame.height - frame.height * internalRatio, width: size.width, height: size.height)
    }
    
    func update(_ key: CGFloat, open: Bool) {
        for subview in self.subviews {
            let ratio = max(2 * (key * key - 0.5), 0)
            subview.alpha = open ? ratio : -ratio
        }
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if responsible {
            originalColor = color
            color = originalColor.white(0.5)
            setNeedsDisplay()
        }
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        if responsible {
            color = originalColor
            setNeedsDisplay()
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        color = originalColor
        actionButton?.didTappedCell(self)
    }

}

@objc open class LiquidFloatingLabelCell : LiquidFloatingCell {
    
    var name: String = ""
    @objc open var tapAction:(()->Void)?
    let label = UILabel()
    
    @objc init(icon: UIImage, name: String) {
        self.name = name
        super.init(icon: icon)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func setupView(_ view: UIView) {
        super.setupView(view)
        label.text = name
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor(red: 60/255.0, green: 67/255.0, blue: 80/255.0, alpha: 1)
        label.backgroundColor = UIColor.white
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.font = UIFont(name: "Montserrat-Light", size: 13)
        label.isUserInteractionEnabled = true
        addSubview(label)
        
        let centerYConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy:  NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.0, constant: 0.0)
        let heightConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1.0, constant: 30)
        let horizontalSpacing = NSLayoutConstraint(item: label, attribute: .right, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: -16)
        let widthConstraint = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: label.intrinsicContentSize.width + 25)
        
        NSLayoutConstraint.activate([horizontalSpacing,heightConstraint,centerYConstraint,widthConstraint])
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event);
        self.tapAction?()
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.tapAction?()
    }
    
}
