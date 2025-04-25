//
//  GroupExpense.swift
//  SmartBudget
//
//  Created by YuJie Wu on 2025/4/24.
//
import UIKit

struct GroupExpense: Codable{
    var title: String
    var amount: Double
    var paidBy: String
    
    init(title: String, amount: Double, paidBy: String){
        self.title = title
        self.amount = amount
        self.paidBy = paidBy
    }
    
    private(set) var id: String = UUID().uuidString
}

extension GroupExpense{
    static var expenseKey: String{
        return "groupExpense"
    }
    
    static func save(_ expenses:[GroupExpense]){
        let defaults = UserDefaults.standard
        let key = self.expenseKey
        let encodedData = try! JSONEncoder().encode(expenses)
        defaults.set(encodedData, forKey: key)
    }
    
    static func getExpense()->[GroupExpense]{
        let defaults = UserDefaults.standard
        let key = self.expenseKey
        if let data = defaults.data(forKey: key){
            let decodeExpenses = try! JSONDecoder().decode([GroupExpense].self, from: data)
            return decodeExpenses
        }else{
            return []
        }
    }
    
    func save(){
        var currentExpenses = GroupExpense.getExpense()
        
        if let existingIndex = currentExpenses.firstIndex(where: {$0.id == self.id}){
            currentExpenses.remove(at: existingIndex)
            currentExpenses.insert(self, at: existingIndex)
        }else{
            currentExpenses.append(self)
        }
        
        GroupExpense.save(currentExpenses)
    }
    
    
}

