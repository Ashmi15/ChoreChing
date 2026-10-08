import SwiftUI

struct KidsView: View {
    @ObservedObject var store: Store
    @Binding var selectedKidId: String?
    @Binding var selectedDate: Date
    @Binding var showWeek: Bool
    
    var selectedKid: Kid? {
        store.kids.first { $0.id == selectedKidId }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Kid", selection: $selectedKidId) {
                    ForEach(store.kids) { kid in
                        Text(kid.name).tag(Optional(kid.id))
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                DatePicker("Date", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(.compact)
                    .padding(.horizontal)
                
                Picker("View", selection: $showWeek) {
                    Text("Daily").tag(false)
                    Text("Weekly").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                List {
                    ForEach(filteredAssigned()) { a in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(a.title)
                                Text("$\(a.amount, specifier: "%.2f")")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            if a.status == .pending {
                                Button("Done") { store.markDone(a.id) }
                            } else if a.status == .done {
                                HStack {
                                    Button("Approve") { store.approve(a.id) }
                                    Button("Decline") { store.decline(a.id) }
                                }
                            } else if a.status == .approved {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                            } else {
                                Text("Declined").foregroundColor(.red)
                            }
                        }
                    }
                }
                
                if let kid = selectedKid {
                    NavigationLink("Assign Chore") {
                        AssignChoreView(store: store, kidId: kid.id, date: selectedDate)
                    }
                    .padding()
                }
            }
            .navigationTitle(selectedKid?.name ?? "No Kids")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Kid") { addKid() }
                }
            }
        }
    }
    
    func addKid() {
        let alert = UIAlertController(title: "Add Kid", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Name" }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            if let name = alert.textFields?.first?.text, !name.isEmpty {
                store.addKid(name)
                selectedKidId = store.kids.last?.id
            }
        })
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }
    
    func filteredAssigned() -> [AssignedChore] {
        store.assigned.filter { a in
            (selectedKidId == nil || a.kidId == selectedKidId) &&
            Calendar.current.isDate(a.assignedDate, inSameDayAs: selectedDate) &&
            !a.history
        }
    }
}
