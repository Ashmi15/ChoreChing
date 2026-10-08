import SwiftUI

struct TemplatesView: View {
    @ObservedObject var store: Store
    @State private var title = ""
    @State private var amount = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Add Custom")) {
                    TextField("Title", text: $title)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    Button("Add") {
                        if let amt = Double(amount), !title.isEmpty {
                            store.addTemplate(title, amount: amt)
                            title = ""; amount = ""
                        }
                    }
                }
                Section(header: Text("Templates")) {
                    ForEach(store.templates) { t in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(t.title)
                                Text("$\(t.amount, specifier: "%.2f")").font(.caption).foregroundColor(.gray)
                            }
                            Spacer()
                            if !t.isPreset {
                                Button("Delete") { store.deleteTemplate(t.id) }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Chore List")
        }
    }
}
