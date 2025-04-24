//
//  BudgetViewController.swift
//  SmartBudget
//
//  Created by YuJie Wu on 2025/4/17.
//

import UIKit

class BudgetViewController: UIViewController, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pieChartData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetCell") ?? UITableViewCell(style: .value1, reuseIdentifier: "BudgetCell")
        
        let data = pieChartData[indexPath.row]
        cell.textLabel?.text = data.category
        cell.detailTextLabel?.text = "$\(Int(data.value))"
        
        // Create color indicator view
        let colorIndicator = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        colorIndicator.backgroundColor = data.color
        colorIndicator.layer.cornerRadius = 10
        cell.accessoryView = colorIndicator
        
        return cell
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pieChartView: PieChartView!
    
    private var pieChart: PieChartView!
    private var pieChartData: [(category: String, value: Double, color: UIColor)] = [
           ("Food", 300, .systemRed),
           ("Transportation", 250, .systemBlue),
           ("Entertainment", 150, .systemGreen),
           ("Utilities", 200, .systemOrange),
           ("Others", 100, .systemPurple)
       ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        setupPieChart()
    }
    
    private func setupPieChart() {
        // Remove any existing subviews
        pieChartView.subviews.forEach { $0.removeFromSuperview() }
        
        // Create pie chart with the same frame as the placeholder
        pieChart = PieChartView(frame: pieChartView.bounds)
        pieChart.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Configure the doughnut appearance
        pieChart.innerRadiusRatio = 0.6 // Adjust this value to control hole size (0.0-1.0)
        pieChart.strokeWidth = 2.0 // Slightly thicker border between slices
        pieChart.strokeColor = .white
        
        // Add sample data
        pieChart.addSlice(value: 45, color: .systemPurple) // Purple slice (largest)
        pieChart.addSlice(value: 20, color: .systemPink)   // Pink slice
        pieChart.addSlice(value: 15, color: .systemRed)    // Red slice
        pieChart.addSlice(value: 20, color: .systemGreen)  // Green slice
        
        // Add to view
        pieChartView.addSubview(pieChart)
        
        // Force layout update
        pieChart.setNeedsDisplay()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
