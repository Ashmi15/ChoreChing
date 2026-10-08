import SwiftUI

struct AssignChoreView: View {
    @ObservedObject var store: Store
    var kidId: String
    var date: Date
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        List(store.templates) { t in
            HStack {
                VStack(alignment: .leading) {
                    Text(t.title)
                    Text("$\(t.amount, specifier: "%.2f")").font(.caption).foregroundColor(.gray)
                }
                Spacer()
                Button("Assign") {
                    store.assignChore(kidId: kidId, template: t, date: date)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("Assign Chore")
    }
}
