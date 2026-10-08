import SwiftUI

struct KidsView: View {
    @ObservedObject var store: Store
    @Binding var selectedKidId: String?
    @Binding var selectedDate: Date
    @Binding var showWeek: Bool
    @State private var showAddKid = false
    @State private var newKidName = ""
    
    var selectedKid: Kid? {
        store.kids.first { $0.id == selectedKidId }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                if !store.kids.isEmpty {
                    Picker("Kid", selection: $selectedKidId) {
                        ForEach(store.kids) { kid in
                            Text(kid.name).tag(kid.id as String?)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    if let kid = selectedKid {
                        Text("Balance: $\(kid.balance, specifier: "%.2f")")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                }
                
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
                                    .font(.headline)
                                Text("$\(a.amount, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            switch a.status {
                            case .pending:
                                Button("Mark Done") {
                                    store.markDone(a.id)
                                }
                                .buttonStyle(.borderedProminent)
                            case .done:
                                HStack(spacing: 8) {
                                    Button("Approve") { store.approve(a.id) }
                                        .buttonStyle(.borderedProminent)
                                        .tint(.green)
                                    Button("Decline") { store.decline(a.id) }
                                        .buttonStyle(.bordered)
                                        .tint(.red)
                                }
                            case .approved:
                                Label("Approved", systemImage: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            case .declined:
                                Label("Declined", systemImage: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                if let kid = selectedKid {
                    NavigationLink(destination: AssignChoreView(store: store, kidId: kid.id, date: selectedDate)) {
                        Text("Assign Chore")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                } else {
                    Button("Add Your First Kid") {
                        showAddKid = true
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            }
            .navigationTitle("Chores")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Kid") { showAddKid = true }
                }
            }
            .sheet(isPresented: $showAddKid) {
                NavigationView {
                    Form {
                        TextField("Kid's name", text: $newKidName)
                    }
                    .navigationTitle("Add Kid")
                    .navigationBarItems(leading: Button("Cancel") {
                        showAddKid = false
                        newKidName = ""
                    }, trailing: Button("Save") {
                        if !newKidName.isEmpty {
                            store.addKid(newKidName)
                            selectedKidId = store.kids.last?.id
                            showAddKid = false
                            newKidName = ""
                        }
                    })
                }
            }
        }
    }
    
    func filteredAssigned() -> [AssignedChore] {
        store.assigned.filter { a in
            (selectedKidId == nil || a.kidId == selectedKidId) &&
            Calendar.current.isDate(a.assignedDate, inSameDayAs: selectedDate) &&
            !a.history
        }
    }
}
