//
//  Expense.swift
//  SmartBudget
//
//  Created by YuJie Wu on 2025/4/23.
//
import Foundation

struct Expense: Codable {
    var title: String
    var amount: Double
    var date: Date
    var category: String
    var id: String
    var userId: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case amount
        case date
        case category
        case id
        case userId = "user_id"
    }
    
    init(title: String, amount: Double, date: Date, category: String) {
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
        self.id = UUID().uuidString
        self.userId = nil
    }
    
    // Save the expense to Supabase
    func save() async {
        do {
            try await SupabaseExpenseManager.shared.saveExpense(self)
        } catch {
            print("Error saving expense: \(error)")
        }
    }
    
    // Delete the expense from Supabase
    static func delete(id: String) async {
        do {
            try await SupabaseExpenseManager.shared.deleteExpense(id: id)
        } catch {
            print("Error deleting expense: \(error)")
        }
    }
    
    // Get all expenses from Supabase
    static func getExpenses() async -> [Expense] {
        do {
            return try await SupabaseExpenseManager.shared.getExpenses()
        } catch {
            print("Error fetching expenses: \(error)")
            return []
        }
    }
}
