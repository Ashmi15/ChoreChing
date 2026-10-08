import SwiftUI

struct HistoryView: View {
    @ObservedObject var store: Store
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.transactions) { tx in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(tx.reason)
                            Text(kidName(tx.kidId)).font(.caption).foregroundColor(.gray)
                        }
                        Spacer()
                        Text("+$\(tx.amount, specifier: "%.2f")").foregroundColor(.green)
                        Text(tx.date, style: .date).font(.caption)
                    }
                }
                Section(header: Text("Completed (Pending Approval)")) {
                    ForEach(store.assigned.filter { $0.status == .done && $0.history }) { a in
                        Text("\(a.title) - \(kidName(a.kidId))")
                    }
                }
            }
            .navigationTitle("History")
        }
    }
    
    func kidName(_ id: String) -> String {
        store.kids.first { $0.id == id }?.name ?? ""
    }
}
