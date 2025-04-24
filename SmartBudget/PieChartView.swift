//
//  PieChartView.swift
//  SmartBudget
//
//  Created by YuJie Wu on 2025/4/17.
//

import UIKit

class PieChartView: UIView {
    // Data structure for pie slice
    struct Slice {
        var value: Double
        var color: UIColor
    }
    
    // Array of slices for the pie chart
    var slices: [Slice] = [] {
        didSet {
            setNeedsDisplay() // Redraw when data changes
        }
    }
    
    // Line width of the stroke between slices (optional)
    var strokeWidth: CGFloat = 1.0
    
    // Stroke color between slices (optional)
    var strokeColor: UIColor = .white
    
    var innerRadiusRatio: CGFloat = 0.5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        guard !slices.isEmpty else { return }
        
        // Calculate total value for all slices
        let total = slices.reduce(0) { $0 + $1.value }
        guard total > 0 else { return }
        
        // Calculate center and radius of the pie chart
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 - strokeWidth
        let innerRadius = radius * innerRadiusRatio // Calculate inner radius
        
        // Starting angle is -90 degrees (top of the circle)
        var startAngle: CGFloat = -.pi / 2
        
        // Draw each slice
        for slice in slices {
            let sliceValue = CGFloat(slice.value / total)
            let endAngle = startAngle + sliceValue * .pi * 2
            
            // Create the path for the slice
            let path = UIBezierPath()
            
            // Move to the start point on the inner circle
            let startPointInner = CGPoint(
                x: center.x + innerRadius * cos(startAngle),
                y: center.y + innerRadius * sin(startAngle)
            )
            path.move(to: startPointInner)
            
            // Add outer arc from start angle to end angle
            path.addArc(
                withCenter: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: true
            )
            
            // Add inner arc from end angle back to start angle
            path.addArc(
                withCenter: center,
                radius: innerRadius,
                startAngle: endAngle,
                endAngle: startAngle,
                clockwise: false
            )
            
            // Close the path
            path.close()
            
            // Set fill and stroke colors
            context.setFillColor(slice.color.cgColor)
            context.setStrokeColor(strokeColor.cgColor)
            context.setLineWidth(strokeWidth)
            
            // Fill and stroke the path
            path.fill()
            path.stroke()
            
            // Update start angle for next slice
            startAngle = endAngle
        }
    }
    
    // Add slices programmatically
    func addSlice(value: Double, color: UIColor) {
        slices.append(Slice(value: value, color: color))
    }
    
    // Clear all slices
    func clearSlices() {
        slices.removeAll()
    }
}

// MARK: - Example usage
//class ViewController: UIViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Create pie chart
//        let pieChart = PieChartView(frame: CGRect(x: 50, y: 100, width: 200, height: 200))
//        view.addSubview(pieChart)
//        
//        // Add slices
//        pieChart.addSlice(value: 30, color: .systemRed)
//        pieChart.addSlice(value: 25, color: .systemBlue)
//        pieChart.addSlice(value: 15, color: .systemGreen)
//        pieChart.addSlice(value: 30, color: .systemOrange)
//    }
//}
