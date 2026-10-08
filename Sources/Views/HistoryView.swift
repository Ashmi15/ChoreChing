import SwiftUI

struct HistoryView: View {
    @ObservedObject var store: Store
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Bank Balances")) {
                    ForEach(store.kids) { kid in
                        HStack {
                            Text(kid.name)
                            Spacer()
                            Text("$\(kid.balance, specifier: "%.2f")")
                                .foregroundColor(.green)
                                .font(.headline)
                        }
                    }
                }
                
                Section(header: Text("Approved Transactions")) {
                    ForEach(store.transactions.sorted(by: { $0.date > $1.date })) { tx in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(tx.reason)
                                    .font(.headline)
                                Text(kidName(tx.kidId))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(tx.date, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Text("+$\(tx.amount, specifier: "%.2f")")
                                .foregroundColor(.green)
                                .font(.headline)
                        }
                    }
                }
                
                Section(header: Text("Pending Approval")) {
                    ForEach(store.assigned.filter { $0.status == .done && $0.history }) { a in
                        HStack {
                            Text("\(a.title) - \(kidName(a.kidId))")
                            Spacer()
                            Text("$\(a.amount, specifier: "%.2f")")
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            .navigationTitle("History & Balances")
        }
    }
    
    func kidName(_ id: String) -> String {
        store.kids.first { $0.id == id }?.name ?? ""
    }
}
