import SwiftUI
import SwiftData
import PhotosUI

struct ProgramView: View {
    @Query private var allEntries: [ProgramEntry]
    
    let days = ["Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar"]
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(0..<7, id: \.self) { index in
                        NavigationLink(destination: ProgramDayDetailView(dayIndex: index)) {
                            let count = allEntries.filter { $0.dayIndex == index }.count
                            DayCard(
                                dayName: days[index],
                                subtitle: count > 0 ? "\(count) Hareket" : "Boş",
                                icon: "figure.strengthtraining.traditional"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Programım")
        }
        .accentColor(.red)
    }
}

struct ProgramDayDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ProgramEntry.sortOrder) private var allEntries: [ProgramEntry]
    
    let dayIndex: Int
    @State private var editingEntry: ProgramEntry?
    @State private var showAddExercise = false
    
    let days = ["Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar"]
    
    var dayEntries: [ProgramEntry] {
        allEntries.filter { $0.dayIndex == dayIndex }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if dayEntries.isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 80))
                        .foregroundColor(.red.opacity(0.2))
                    
                    Text("Henüz Hareket Yok")
                        .font(.system(.title3, design: .rounded).bold())
                    
                    Text("\(days[dayIndex]) günü için antrenman programı oluşturmaya yukarıdaki + butonuna basarak başlayabilirsin.")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button(action: { showAddExercise = true }) {
                        Text("Hemen Ekle")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 14)
                            .background(Color.red)
                            .cornerRadius(30)
                            .shadow(color: .red.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                }
            } else {
                List {
                    ForEach(dayEntries) { entry in
                        ProgramEntryRow(entry: entry)
                            .onTapGesture {
                                editingEntry = entry
                            }
                    }
                    .onDelete(perform: deleteEntry)
                    .onMove(perform: moveEntry)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
                .listStyle(.plain)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(days[dayIndex])
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    EditButton()
                    Button(action: { showAddExercise = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .sheet(item: $editingEntry) { entry in
            EditProgramEntrySheet(entry: entry)
        }
        .sheet(isPresented: $showAddExercise) {
            AddManualExerciseView(dayIndex: dayIndex)
        }
    }
    
    private func deleteEntry(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(dayEntries[index])
        }
    }
    
    private func moveEntry(from source: IndexSet, to destination: Int) {
        var revisedItems = dayEntries
        revisedItems.move(fromOffsets: source, toOffset: destination)
        
        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1) {
            revisedItems[reverseIndex].sortOrder = reverseIndex
        }
    }
}

struct ProgramEntryRow: View {
    let entry: ProgramEntry
    
    var body: some View {
        HStack(spacing: 16) {
            if let data = entry.exerciseImageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 90, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(colors: [.red.opacity(0.1), .red.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 90, height: 90)
                    .overlay(
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.title)
                            .foregroundColor(.red.opacity(0.4))
                    )
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(entry.exerciseName)
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 12) {
                    MetricBadge(value: "\(entry.sets)", label: "SET", icon: "number")
                    MetricBadge(value: "\(entry.reps)", label: "TEKRAR", icon: "repeat")
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.secondary.opacity(0.4))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
}

struct MetricBadge: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 24, height: 24)
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.red)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.system(.subheadline, design: .rounded).bold())
                Text(label)
                    .font(.system(size: 8, design: .rounded).bold())
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct EditProgramEntrySheet: View {
    @Bindable var entry: ProgramEntry
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Egzersiz") {
                    TextField("Egzersiz Adı", text: $entry.exerciseName)
                        .font(.system(.body, design: .rounded).bold())
                    
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        HStack(spacing: 16) {
                            if let data = entry.exerciseImageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.red.opacity(0.05))
                                    .frame(width: 80, height: 80)
                                    .overlay(Image(systemName: "camera.fill").foregroundColor(.red.opacity(0.6)))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Resmi Değiştir")
                                    .font(.system(.subheadline, design: .rounded).bold())
                                Text("Hareketin görselini güncelle")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .onChange(of: selectedItem) { oldValue, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                entry.exerciseImageData = data
                            }
                        }
                    }
                }
                
                Section("Set ve Tekrar") {
                    Stepper(value: $entry.sets, in: 1...20) {
                        HStack {
                            Image(systemName: "number")
                                .foregroundColor(.red)
                            Text("Set Sayısı: \(entry.sets)")
                        }
                    }
                    
                    Stepper(value: $entry.reps, in: 1...100) {
                        HStack {
                            Image(systemName: "repeat")
                                .foregroundColor(.red)
                            Text("Tekrar Sayısı: \(entry.reps)")
                        }
                    }
                }
            }
            .navigationTitle("Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .font(.system(.body, design: .rounded).bold())
                }
            }
        }
        .accentColor(.red)
    }
}
