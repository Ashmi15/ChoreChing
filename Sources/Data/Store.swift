import Foundation
import SwiftUI

struct UndoAction {
    let action: () -> Void
    let description: String
}

class Store: ObservableObject {
    @Published var kids: [Kid] = []
    @Published var templates: [ChoreTemplate] = []
    @Published var assigned: [AssignedChore] = []
    @Published var transactions: [Transaction] = []
    
    private var undoStack: [UndoAction] = []
    
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
    
    func addUndo(_ action: @escaping () -> Void, description: String) {
        undoStack.append(UndoAction(action: action, description: description))
    }
    
    func undo() {
        if let last = undoStack.popLast() {
            last.action()
        }
    }
    
    var canUndo: Bool {
        !undoStack.isEmpty
    }
    
    func addKid(_ name: String) {
        let kid = Kid(name: name)
        addUndo({ [weak self] in self?.kids.removeAll { $0.id == kid.id } }, description: "Add Kid")
        kids.append(kid)
    }
    
    func updateKidName(_ id: String, oldName: String, newName: String) {
        if let idx = kids.firstIndex(where: { $0.id == id }) {
            addUndo({ [weak self] in
                if let i = self?.kids.firstIndex(where: { $0.id == id }) {
                    self?.kids[i].name = oldName
                }
            }, description: "Rename Kid")
            kids[idx].name = newName
        }
    }
    
    func addTemplate(_ title: String, amount: Double) {
        let t = ChoreTemplate(title: title, amount: amount, isPreset: false)
        addUndo({ [weak self] in self?.templates.removeAll { $0.id == t.id } }, description: "Add Chore")
        templates.append(t)
    }
    
    func deleteTemplate(_ id: String) {
        guard let t = templates.first(where: { $0.id == id }) else { return }
        let idx = templates.firstIndex(where: { $0.id == id })
        addUndo({ [weak self] in
            if let i = idx { self?.templates.insert(t, at: i) }
        }, description: "Delete Chore")
        templates.removeAll { $0.id == id }
    }
    
    func updateTemplate(_ id: String, oldTitle: String, oldAmount: Double, newTitle: String, newAmount: Double) {
        if let idx = templates.firstIndex(where: { $0.id == id }) {
            addUndo({ [weak self] in
                if let i = self?.templates.firstIndex(where: { $0.id == id }) {
                    self?.templates[i].title = oldTitle
                    self?.templates[i].amount = oldAmount
                }
            }, description: "Edit Chore")
            templates[idx].title = newTitle
            templates[idx].amount = newAmount
        }
    }
    
    func assignChore(kidId: String, template: ChoreTemplate, date: Date) {
        let a = AssignedChore(kidId: kidId, choreTemplateId: template.id, title: template.title, amount: template.amount, assignedDate: date)
        addUndo({ [weak self] in self?.assigned.removeAll { $0.id == a.id } }, description: "Assign Chore")
        assigned.append(a)
    }
    
    func markDone(_ id: String) {
        if let idx = assigned.firstIndex(where: { $0.id == id }) {
            let old = assigned[idx].status
            let oldDate = assigned[idx].completedAt
            addUndo({ [weak self] in
                if let i = self?.assigned.firstIndex(where: { $0.id == id }) {
                    self?.assigned[i].status = old
                    self?.assigned[i].completedAt = oldDate
                }
            }, description: "Mark Done")
            assigned[idx].status = .done
            assigned[idx].completedAt = Date()
        }
    }
    
    func approve(_ id: String) {
        if let idx = assigned.firstIndex(where: { $0.id == id }),
           assigned[idx].status == .done {
            let kidId = assigned[idx].kidId
            let amt = assigned[idx].amount
            let oldStatus = assigned[idx].status
            let title = assigned[idx].title
            addUndo({ [weak self] in
                if let i = self?.assigned.firstIndex(where: { $0.id == id }) {
                    self?.assigned[i].status = oldStatus
                    self?.assigned[i].history = false
                    if let kidx = self?.kids.firstIndex(where: { $0.id == kidId }) {
                        self?.kids[kidx].balance -= amt
                    }
                }
                self?.transactions.removeAll { $0.reason == title && $0.kidId == kidId && abs($0.amount - amt) < 0.01 }
            }, description: "Approve")
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
            let old = assigned[idx].status
            addUndo({ [weak self] in
                if let i = self?.assigned.firstIndex(where: { $0.id == id }) {
                    self?.assigned[i].status = old
                    self?.assigned[i].history = false
                }
            }, description: "Decline")
            assigned[idx].status = .declined
            assigned[idx].history = true
            assigned[idx].completedAt = assigned[idx].completedAt ?? Date()
        }
    }
    
    func duplicate(_ a: AssignedChore, to kidId: String, date: Date) {
        let copy = AssignedChore(kidId: kidId, choreTemplateId: a.choreTemplateId, title: a.title, amount: a.amount, assignedDate: date, status: .pending)
        addUndo({ [weak self] in self?.assigned.removeAll { $0.id == copy.id } }, description: "Reassign")
        assigned.append(copy)
    }
}
