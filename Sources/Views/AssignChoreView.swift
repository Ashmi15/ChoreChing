import SwiftUI

struct AssignChoreView: View {
    @ObservedObject var store: Store
    var kidId: String
    var date: Date
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List(store.templates) { t in
                HStack {
                    VStack(alignment: .leading) {
                        Text(t.title)
                            .font(.headline)
                        Text("$\(t.amount, specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button("Assign") {
                        store.assignChore(kidId: kidId, template: t, date: date)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Assign Chore")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}
