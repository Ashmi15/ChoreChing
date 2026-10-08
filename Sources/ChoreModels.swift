import Foundation

struct Family: Identifiable, Codable {
    var id = UUID().uuidString
    var name: String
    var members: [String] = []
    var familyCode: String
}

struct Kid: Identifiable, Codable {
    var id = UUID().uuidString
    var name: String
    var familyId: String
    var balance: Double = 0.0
    var avatar: String?
}

struct Chore: Identifiable, Codable {
    var id = UUID().uuidString
    var familyId: String
    var title: String
    var amount: Double
    var isRecurring: Bool = false
    var frequency: Frequency = .none
    var description: String?
}

enum Frequency: String, Codable, CaseIterable {
    case none, daily, weekly
}

struct Assignment: Identifiable, Codable {
    var id = UUID().uuidString
    var choreId: String
    var kidId: String
    var assignedBy: String
    var assignedAt: Date = Date()
    var dueDate: Date?
    var status: Status = .pending
    
    enum Status: String, Codable {
        case pending, done, approved, declined
    }
}

struct Transaction: Identifiable, Codable {
    var id = UUID().uuidString
    var kidId: String
    var amount: Double
    var reason: String
    var actorId: String
    var date: Date = Date()
}
