import Foundation
import SwiftUI

class Store: ObservableObject {
    @Published var kids: [Kid] = []
    @Published var templates: [ChoreTemplate] = []
    @Published var assigned: [AssignedChore] = []
    @Published var transactions: [Transaction] = []
    
    init() {
        loadPresets()
    }
    
    func loadPresets() {
        if templates.isEmpty {
            templates = [
                ChoreTemplate(title: "Washing dishes", amount: 10.0, isPreset: true),
                ChoreTemplate(title: "Mopping", amount: 7.0, isPreset: true),
                ChoreTemplate(title: "Sweeping", amount: 5.0, isPreset: true),
                ChoreTemplate(title: "Ironing", amount: 15.0, isPreset: true),
                ChoreTemplate(title: "Folding", amount: 5.0, isPreset: true),
                ChoreTemplate(title: "Load laundry", amount: 2.0, isPreset: true),
                ChoreTemplate(title: "Drying clothes", amount: 5.0, isPreset: true)
            ]
        }
    }
    
    func addKid(_ name: String) {
        let kid = Kid(name: name)
        kids.append(kid)
    }
    
    func addTemplate(_ title: String, amount: Double) {
        templates.append(ChoreTemplate(title: title, amount: amount, isPreset: false))
    }
    
    func deleteTemplate(_ id: String) {
        templates.removeAll { $0.id == id }
    }
    
    func assignChore(kidId: String, template: ChoreTemplate, date: Date) {
        let a = AssignedChore(kidId: kidId, choreTemplateId: template.id, title: template.title, amount: template.amount, assignedDate: date)
        assigned.append(a)
    }
    
    func markDone(_ id: String) {
        if let idx = assigned.firstIndex(where: { $0.id == id }) {
            assigned[idx].status = .done
            assigned[idx].completedAt = Date()
        }
    }
    
    func approve(_ id: String) {
        if let idx = assigned.firstIndex(where: { $0.id == id }),
           assigned[idx].status == .done {
            let kidId = assigned[idx].kidId
            let amt = assigned[idx].amount
            assigned[idx].status = .approved
            assigned[idx].approvedAt = Date()
            assigned[idx].history = true
            if let kidx = kids.firstIndex(where: { $0.id == kidId }) {
                kids[kidx].balance += amt
            }
            transactions.append(Transaction(kidId: kidId, amount: amt, reason: assigned[idx].title))
        }
    }
    
    func decline(_ id: String) {
        if let idx = assigned.firstIndex(where: { $0.id == id }) {
            assigned[idx].status = .declined
            assigned[idx].history = true
            assigned[idx].completedAt = assigned[idx].completedAt ?? Date()
        }
    }
    
    func duplicate(_ a: AssignedChore, to kidId: String, date: Date) {
        let copy = AssignedChore(kidId: kidId, choreTemplateId: a.choreTemplateId, title: a.title, amount: a.amount, assignedDate: date, status: .pending)
        assigned.append(copy)
    }
}
