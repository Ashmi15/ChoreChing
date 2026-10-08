import SwiftUI

struct ParentDashboard: View {
    @State private var kids: [Kid] = []
    @State private var assignments: [Assignment] = []
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Kids")) {
                    ForEach(kids) { kid in
                        HStack {
                            Text(kid.name)
                            Spacer()
                            Text("$\(kid.balance, specifier: "%.2f")")
                        }
                    }
                }
                Section(header: Text("Pending Approvals")) {
                    ForEach(assignments.filter { $0.status == .done }) { assignment in
                        HStack {
                            Text(assignment.id)
                            Spacer()
                            Button("Approve") {}
                        }
                    }
                }
            }
            .navigationTitle("Parent Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Kid") {}
                }
            }
        }
    }
}
#Preview {
    ParentDashboard()
}
