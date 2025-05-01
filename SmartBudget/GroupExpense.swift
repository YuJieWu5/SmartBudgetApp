//
//  GroupExpense.swift
//  SmartBudget
//
//  Created by YuJie Wu on 2025/4/24.
//
import UIKit
import Supabase

struct GroupExpense: Codable {
    var title: String
    var amount: Double
    var paidBy: String
    var groupId: String
    var id: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case amount
        case paidBy = "paid_by"
        case groupId = "group_id"
        case id
    }
    
    init(title: String, amount: Double, paidBy: String, group_id: String, id: String = UUID().uuidString) {
        self.title = title
        self.amount = amount
        self.paidBy = paidBy
        self.groupId = group_id
        self.id = id
    }
}

extension GroupExpense {
    static func fetchExpenses() async throws -> [GroupExpense] {
        let query = SupabaseManager.shared.supabase.database
            .from("GroupExpense")
            .select()
        
        let expenses: [GroupExpense] = try await query.execute().value
        return expenses
    }
    
    static func fetchExpensesForGroup(groupId: String) async throws -> [GroupExpense] {
        let query = SupabaseManager.shared.supabase.database
            .from("GroupExpense")
            .select()
            .eq("group_id", value: groupId)
        
        let expenses: [GroupExpense] = try await query.execute().value
        return expenses
    }
    
    func save() async throws {
        guard let user = await SupabaseManager.shared.getCurrentUser() else {
            throw NSError(domain: "Not authenticated", code: 401)
        }
        
        // Debug: Print information
        print("Saving expense with ID: \(id), title: \(title), amount: \(amount), paid by: \(paidBy), group ID: \(groupId)")
        
        // Create a struct specifically for sending to Supabase
        struct ExpenseUpload: Encodable {
            let id: String
            let title: String
            let amount: Double
            let paid_by: String
            let group_id: String
        }
        
        // Create an uploadable version with the correct field names
        let expenseData = ExpenseUpload(
            id: self.id,
            title: self.title,
            amount: self.amount,
            paid_by: self.paidBy,
            group_id: self.groupId
        )
        
        do {
            // Use upsert to handle both insert and update scenarios
            let response = try await SupabaseManager.shared.supabase
                .from("GroupExpense")
                .upsert(expenseData)
                .execute()
            
            print("Expense saved successfully")
            return
        } catch {
            print("Error saving expense: \(error)")
            throw error
        }
    }
    
    // Optional: Add delete function if needed
    func delete() async throws {
        do {
            let response = try await SupabaseManager.shared.supabase
                .from("GroupExpense")
                .delete()
                .eq("id", value: self.id)
                .execute()
            
            print("Expense deleted successfully")
        } catch {
            print("Error deleting expense: \(error)")
            throw error
        }
    }
}
