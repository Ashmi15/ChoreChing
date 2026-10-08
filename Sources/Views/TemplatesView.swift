import SwiftUI

struct TemplatesView: View {
    @ObservedObject var store: Store
    @State private var title = ""
    @State private var amount = ""
    @State private var showingAlert = false
    @State private var editingTemplate: ChoreTemplate?
    @State private var editTitle = ""
    @State private var editAmount = ""
    
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
                            Button("Edit") {
                                editingTemplate = t
                                editTitle = t.title
                                editAmount = String(format: "%.2f", t.amount)
                            }
                            .buttonStyle(.bordered)
                            Button(role: .destructive) {
                                store.deleteTemplate(t.id)
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Chore List")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Undo") { store.undo() }
                        .disabled(!store.canUndo)
                }
            }
            .alert("Invalid amount", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please enter a valid number.")
            }
            .sheet(isPresented: Binding(
                get: { editingTemplate != nil },
                set: { if !$0 { editingTemplate = nil } }
            )) {
                NavigationView {
                    Form {
                        TextField("Title", text: $editTitle)
                        TextField("Amount ($)", text: $editAmount)
                            .keyboardType(.decimalPad)
                    }
                    .navigationTitle("Edit Chore")
                    .navigationBarItems(leading: Button("Cancel") {
                        editingTemplate = nil
                    }, trailing: Button("Save") {
                        if let template = editingTemplate,
                           let idx = store.templates.firstIndex(where: { $0.id == template.id }) {
                            let oldTitle = template.title
                            let oldAmt = template.amount
                            if let amt = Double(editAmount), !editTitle.isEmpty {
                                store.updateTemplate(template.id, oldTitle: oldTitle, oldAmount: oldAmt, newTitle: editTitle, newAmount: amt)
                                editingTemplate = nil
                            }
                        }
                    })
                }
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
