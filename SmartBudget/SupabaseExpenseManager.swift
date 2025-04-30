//
//  SupabaseExpenseManager.swift
//  SmartBudget
//
//  Created by YuJie Wu on 2025/4/29.
//
import Foundation
import Supabase

class SupabaseExpenseManager {
    static let shared = SupabaseExpenseManager()
    private let supabaseClient = SupabaseManager.shared.supabase
    
    private init() { }
    
    // Fetch all expenses for the current user
    func getExpenses() async throws -> [Expense] {
        guard let user = try? await SupabaseManager.shared.getCurrentUser() else {
            throw NSError(domain: "Not authenticated", code: 401)
        }
        print(user.id)
        let userId = user.id.uuidString.lowercased()
        
        // Fetch expenses from Supabase where user_id matches current user
        let response = try await supabaseClient
            .from("Expense")
            .select()
            .eq("user_id", value: userId)
            .order("date", ascending: false)
            .execute()
        
//        print("Response data type: \(type(of: response.data))")
//        print("Response data size: \(response.data)")
        
        if let data = response.data as? Data {
            print("Received data object - attempting to parse JSON")
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data)
                print("Converted to JSON: \(jsonObject)")
                
                if let expensesArray = jsonObject as? [[String: Any]] {
                    // Create a custom decoder with date formatter for YYYY-MM-DD format
                    let decoder = JSONDecoder()
                    
                    // Create a custom date formatter for "YYYY-MM-DD" format
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    // Use the custom date formatter for decoding dates
                    decoder.dateDecodingStrategy = .custom { decoder -> Date in
                        let container = try decoder.singleValueContainer()
                        let dateString = try container.decode(String.self)
                        
                        // Try date formatter first
                        if let date = dateFormatter.date(from: dateString) {
                            return date
                        }
                        
                        // Try ISO8601 as fallback
                        let iso8601Formatter = ISO8601DateFormatter()
                        if let date = iso8601Formatter.date(from: dateString) {
                            return date
                        }
                        
                        throw DecodingError.dataCorruptedError(
                            in: container,
                            debugDescription: "Cannot decode date: \(dateString)"
                        )
                    }
                    
                    // Convert back to data and decode
                    let jsonData = try JSONSerialization.data(withJSONObject: expensesArray)
                    let expenses = try decoder.decode([Expense].self, from: jsonData)
                    print("Successfully decoded \(expenses.count) expenses")
                    return expenses
                } else {
                    print("JSON is not an array of dictionaries: \(jsonObject)")
                    return []
                }
            } catch {
                print("JSON parsing error: \(error)")
                return []
            }
        }
        
        print("Response is not a Data object")
        return []
    }
    
    // Save a new expense
    func saveExpense(_ expense: Expense) async throws {
        guard let user = await SupabaseManager.shared.getCurrentUser() else {
            throw NSError(domain: "Not authenticated", code: 401)
        }
        
        let userId = user.id.uuidString
        print("userId: \(userId)")
        
        // Create a struct for upserting
        struct ExpenseUpload: Encodable {
            let id: String
            let title: String
            let amount: Double
            let category: String
            let date: String
            let user_id: String
        }
        
        // Create an ISO8601 formatter
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        // Create an encodable object with the expense data
        let expenseData = ExpenseUpload(
            id: expense.id,
            title: expense.title,
            amount: expense.amount,
            category: expense.category,
            date: formatter.string(from: expense.date),
            user_id: userId
        )
        
        // Upsert the expense to Supabase (insert if not exists, update if exists)
        _ = try await supabaseClient
            .from("Expense")
            .upsert(expenseData)
            .execute()
    }
    
    // Delete an expense
    func deleteExpense(id: String) async throws {
        guard let user = await SupabaseManager.shared.getCurrentUser() else {
            throw NSError(domain: "Not authenticated", code: 401)
        }
        
        let userId = user.id.uuidString
        
        // Delete the expense from Supabase (ensure it belongs to the current user)
        _ = try await supabaseClient
            .from("Expense")
            .delete()
            .eq("id", value: id)
            .eq("user_id", value: userId)  // Security check
            .execute()
    }
}
