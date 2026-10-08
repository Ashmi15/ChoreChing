import SwiftUI

struct TemplatesView: View {
    @ObservedObject var store: Store
    @State private var title = ""
    @State private var amount = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Add Custom Chore")) {
                    TextField("Title", text: $title)
                    TextField("Amount ($)", text: $amount)
                        .keyboardType(.decimalPad)
                    Button(action: {
                        addTemplate()
                    }) {
                        HStack {
                            Spacer()
                            Text("Add")
                            Spacer()
                        }
                    }
                    .disabled(title.isEmpty || Double(amount) == nil)
                }
                
                Section(header: Text("Chore Templates")) {
                    ForEach(store.templates) { t in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(t.title)
                                    .font(.headline)
                                Text("$\(t.amount, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if !t.isPreset {
                                Button(role: .destructive) {
                                    store.deleteTemplate(t.id)
                                } label: {
                                    Image(systemName: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Chore List")
            .alert("Invalid amount", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please enter a valid number.")
            }
        }
    }
    
    private func addTemplate() {
        guard let amt = Double(amount), !title.isEmpty else {
            showingAlert = true
            return
        }
        store.addTemplate(title, amount: amt)
        title = ""
        amount = ""
    }
}
