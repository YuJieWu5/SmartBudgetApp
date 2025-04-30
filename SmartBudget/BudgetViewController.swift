//
//  BudgetViewController.swift
//  SmartBudget
//
//  Created by YuJie Wu on 2025/4/17.
//

import UIKit

class BudgetViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var emptyStateLabel: UILabel!
    
    // The main expenses array initialized with a default value of an empty array
    var expenses = [Expense]()
    
    // Category color mapping
    private let categoryColors: [String: UIColor] = [
        "Food": UIColor(hex: "#F7CAC9"),
        "Transportation": UIColor(hex: "#6B5B95"),
        "Entertainment": UIColor(hex: "#FF6F61"),
        "Other": UIColor(hex: "#88B04B")
    ]
    
    // Category data for pie chart
    private var categoryData: [(category: String, value: Double, color: UIColor)] = []
    
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set table view data source and delegate
        tableView.dataSource = self
        tableView.delegate = self
        
        // Hide top cell separator
        tableView.tableHeaderView = UIView()
        
        // Setup activity indicator
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        
        setupPieChart()
        
//        refreshExpenses()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshExpenses()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ComposeSegue" {
            if let composeNavController = segue.destination as? UINavigationController,
               let composeViewController = composeNavController.topViewController as? ExpenseComposeViewController {
                composeViewController.onComposeExpense = { [weak self] expense in
                    print("###prepare")
                    
                    // Show activity indicator immediately
                    DispatchQueue.main.async {
                        self?.activityIndicator.startAnimating()
                    }
                    
                    // Save expense using async/await
                    Task {
                        await expense.save()
                        await self?.refreshExpenses()
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func refreshExpenses() {
        // Start loading indicator
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
        
        Task {
            // Fetch expenses from Supabase
            let fetchedExpenses = await Expense.getExpenses()
            
            // Update UI on main thread
            await MainActor.run {
                // Update the main expenses array
                self.expenses = fetchedExpenses
                
                // Hide the "empty state label" if there are expenses
                emptyStateLabel.isHidden = !fetchedExpenses.isEmpty
                
                // Calculate category data for pie chart
                calculateCategoryData()
                
                // Update pie chart with new data
                updatePieChart()
                
                // Reload the table view to reflect updates
                tableView.reloadData()
                
                // Stop loading indicator
                activityIndicator.stopAnimating()
            }
        }
    }
    
    private func calculateCategoryData() {
        // Reset category data
        categoryData = []
        
        // Get total amount
        let totalAmount = expenses.reduce(0) { $0 + $1.amount }
        
        // Skip calculation if total is zero
        guard totalAmount > 0 else { return }
        
        // Group expenses by category and sum amounts
        var categoryAmounts: [String: Double] = [:]
        
        for expense in expenses {
            let category = expense.category
            categoryAmounts[category, default: 0] += expense.amount
        }
        
        // Convert to data format needed for pie chart
        for (category, amount) in categoryAmounts {
            let color = categoryColors[category] ?? .systemGray
            categoryData.append((category: category, value: amount, color: color))
        }
        
        // Sort by value (optional)
        categoryData.sort { $0.value > $1.value }
    }
    
    private func setupPieChart() {
        // Remove any existing subviews
        pieChartView.subviews.forEach { $0.removeFromSuperview() }
        
        // Create pie chart with the same frame as the placeholder
        let pieChart = PieChartView(frame: pieChartView.bounds)
        pieChart.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Configure the doughnut appearance
        pieChart.innerRadiusRatio = 0.6
        pieChart.strokeWidth = 2.0
        pieChart.strokeColor = .white
        
        // Add to view
        pieChartView.addSubview(pieChart)
    }
    
    private func updatePieChart() {
        // Remove any existing pie chart
        pieChartView.subviews.forEach { $0.removeFromSuperview() }
        
        // Create new pie chart
        let pieChart = PieChartView(frame: pieChartView.bounds)
        pieChart.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Configure appearance
        pieChart.innerRadiusRatio = 0.6
        pieChart.strokeWidth = 2.0
        pieChart.strokeColor = .white
        
        // Add slices based on category data
        if categoryData.isEmpty {
            // Add empty state with placeholder data
            pieChart.addSlice(value: 1, color: .systemGray4)
        } else {
            // Add slices for each category
            for data in categoryData {
                pieChart.addSlice(value: data.value, color: data.color)
            }
        }
        
        // Add to view
        pieChartView.addSubview(pieChart)
        
        // Force layout update
        pieChart.setNeedsDisplay()
    }
    
    // MARK: - Actions
    
    @IBAction func didTapNewExpenseButton(_ sender: Any) {
        performSegue(withIdentifier: "ComposeSegue", sender: nil)
    }
}

// MARK: - Table View Data Source Methods

extension BudgetViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath) as! ExpenseCell
        
        let expense = expenses[indexPath.row]
        
        // Configure cell with expense data
        cell.titleLabel.text = expense.title
        cell.amountLabel.text = "$\(String(format: "%.2f", expense.amount))"
        
        // Set category image background color based on category
        let categoryColor = categoryColors[expense.category] ?? .systemGray
        cell.categoryImageView.backgroundColor = categoryColor
//        cell.categoryImageView.layer.cornerRadius = cell.categoryImageView.frame.height / 2
        cell.categoryImageView.clipsToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Get the expense to delete
            let expenseToDelete = expenses[indexPath.row]
            
            // Remove from array
            expenses.remove(at: indexPath.row)
            
            // Delete row from table
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // Update pie chart
            calculateCategoryData()
            updatePieChart()
            
            // Delete from Supabase
            Task {
                await Expense.delete(id: expenseToDelete.id)
            }
        }
    }
}

// MARK: - Table View Delegate Methods

extension BudgetViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        let selectedExpense = expenses[indexPath.row]
        
        // (Future Feature) Implement navigation to expense editing screen here
    }
}

// Add this to the BudgetViewController class
extension UIColor {
    // Initialize with hex string like "#FF0000" or "FF0000"
    convenience init(hex: String) {
        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        
        if hexString.hasPrefix("#") {
            scanner.currentIndex = hexString.index(after: hexString.startIndex)
        }
        
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
    
    // Initialize with RGBA values (0-255)
    convenience init(r: Int, g: Int, b: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: a
        )
    }
}
