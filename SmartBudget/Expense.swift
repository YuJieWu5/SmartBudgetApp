//
//  Expense.swift
//  SmartBudget
//
//  Created by YuJie Wu on 2025/4/23.
//

import UIKit

struct Expense: Codable{
    var title: String
    var amount: Double
    var date: Date
    var category: String
    
    init(title: String, amount: Double, date: Date, category: String){
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
    }
    
    private(set) var id: String = UUID().uuidString
}

extension Expense{
    static var expenseKey: String{
        return "personalBudget"
    }
    
    static func save(_ expenses:[Expense]){
        let defaults = UserDefaults.standard
        let key = self.expenseKey
        let encodedData = try! JSONEncoder().encode(expenses)
        defaults.set(encodedData, forKey: key)
    }
    
    static func getExpense()->[Expense]{
        let defaults = UserDefaults.standard
        let key = self.expenseKey
        if let data = defaults.data(forKey: key){
            let decodeExpenses = try! JSONDecoder().decode([Expense].self, from: data)
            return decodeExpenses
        }else{
            return []
        }
    }
    
    func save(){
        var currentExpenses = Expense.getExpense()
        
        if let existingIndex = currentExpenses.firstIndex(where: {$0.id == self.id}){
            currentExpenses.remove(at: existingIndex)
            currentExpenses.insert(self, at: existingIndex)
        }else{
            currentExpenses.append(self)
        }
        
        Expense.save(currentExpenses)
    }
    
    
}
