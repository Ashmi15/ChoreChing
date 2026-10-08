import Foundation

struct Kid: Identifiable, Codable {
    var id = UUID().uuidString
    var name: String
    var balance: Double = 0.0
}

enum ChoreFrequency: String, Codable, CaseIterable {
    case none, daily, weekly
}

struct ChoreTemplate: Identifiable, Codable {
    var id = UUID().uuidString
    var title: String
    var amount: Double
    var isPreset: Bool = true
}

struct AssignedChore: Identifiable, Codable {
    var id = UUID().uuidString
    var kidId: String
    var choreTemplateId: String
    var title: String
    var amount: Double
    var assignedDate: Date
    var assignedBy: String?
    var status: Status = .pending
    var completedAt: Date?
    var approvedAt: Date?
    var history: Bool = false
    
    enum Status: String, Codable {
        case pending, done, approved, declined
    }
}

struct Transaction: Identifiable, Codable {
    var id = UUID().uuidString
    var kidId: String
    var amount: Double
    var reason: String
    var date: Date = Date()
}
