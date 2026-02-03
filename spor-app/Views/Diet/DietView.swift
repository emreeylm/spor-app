import SwiftUI
import SwiftData

struct DietView: View {
    @Query private var allEntries: [DietEntry]
    
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
                        NavigationLink(destination: DietDayDetailView(dayIndex: index)) {
                            let dayEntries = allEntries.filter { $0.dayIndex == index }
                            let totalProtein = dayEntries.compactMap { $0.protein }.reduce(0, +)
                            
                            DayCard(
                                dayName: days[index],
                                subtitle: totalProtein > 0 ? "\(String(format: "%.0f", totalProtein))g Protein" : "Boş",
                                icon: "fork.knife"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Diyet")
        }
        .accentColor(.red)
    }
}

struct DietDayDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DietEntry.createdAt) private var allEntries: [DietEntry]
    
    let dayIndex: Int
    @State private var showAddMeal = false
    @State private var editingEntry: DietEntry?
    
    let days = ["Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar"]
    let mealTypes = ["Kahvaltı", "Öğle Yemeği", "Akşam Yemeği", "Atıştırmalık"]
    
    var dayEntries: [DietEntry] {
        allEntries.filter { $0.dayIndex == dayIndex }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Summary Card
                    DailySummaryCard(protein: totalProtein, 
                                     carb: totalCarb, 
                                     fat: totalFat)
                    
                    // Meal Sections
                    ForEach(mealTypes, id: \.self) { mealType in
                        MealSectionView(
                            title: mealType, 
                            entries: dayEntries.filter { $0.mealType == mealType },
                            onEdit: { editingEntry = $0 },
                            onDelete: { modelContext.delete($0) }
                        )
                    }
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(days[dayIndex])
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddMeal = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
            }
        }
        .sheet(isPresented: $showAddMeal) {
            AddDietEntrySheet(dayIndex: dayIndex)
        }
        .sheet(item: $editingEntry) { entry in
            AddDietEntrySheet(dayIndex: dayIndex, existingEntry: entry)
        }
    }
    
    var totalProtein: Double { dayEntries.compactMap { $0.protein }.reduce(0, +) }
    var totalCarb: Double { dayEntries.compactMap { $0.carb }.reduce(0, +) }
    var totalFat: Double { dayEntries.compactMap { $0.fat }.reduce(0, +) }
}

struct DailySummaryCard: View {
    let protein: Double
    let carb: Double
    let fat: Double
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("GÜNLÜK ÖZET")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text("Makro Besinler")
                        .font(.system(.title2, design: .rounded).bold())
                        .foregroundColor(.primary)
                }
                Spacer()
                Image(systemName: "chart.pie.fill")
                    .font(.title)
                    .foregroundColor(.red.opacity(0.8))
            }
            
            HStack(spacing: 12) {
                MacroCircleItem(label: "PROTEİN", value: protein, color: .red, icon: "figure.strengthtraining.traditional")
                MacroCircleItem(label: "KARB", value: carb, color: .orange, icon: "leaf.fill")
                MacroCircleItem(label: "YAĞ", value: fat, color: .yellow, icon: "drop.fill")
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 10)
        )
    }
}

struct MacroCircleItem: View {
    let label: String
    let value: Double
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.1), lineWidth: 6)
                    .frame(width: 65, height: 65)
                
                Circle()
                    .trim(from: 0, to: min(value / 200, 1.0)) // Placeholder scale
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 65, height: 65)
                    .rotationEffect(.degrees(-90))
                
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
            }
            
            VStack(spacing: 2) {
                Text(label)
                    .font(.system(size: 8, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                Text("\(String(format: "%.0f", value))g")
                    .font(.system(.subheadline, design: .rounded).bold())
                    .foregroundColor(.primary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct MacroSummaryItem: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 8, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(.subheadline, design: .rounded).bold())
                    .foregroundColor(color)
                Text("g")
                    .font(.system(size: 10, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MealSectionView: View {
    let title: String
    let entries: [DietEntry]
    var onEdit: (DietEntry) -> Void
    var onDelete: (DietEntry) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.system(.headline, design: .rounded).bold())
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(entries.count) ürün")
                    .font(.system(size: 12, design: .rounded).bold())
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)
            
            if entries.isEmpty {
                HStack {
                    Text("Henüz ekleme yapılmadı")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.secondary.opacity(0.5))
                        .italic()
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.secondary.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [5]))
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(entries) { entry in
                        DietEntryCard(entry: entry)
                            .onTapGesture { onEdit(entry) }
                            .contextMenu {
                                Button(role: .destructive) { onDelete(entry) } label: {
                                    Label("Sil", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        }
    }
}

struct DietEntryCard: View {
    let entry: DietEntry
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.05))
                    .frame(width: 48, height: 48)
                
                Image(systemName: iconForMealType(entry.mealType))
                    .font(.system(size: 20))
                    .foregroundColor(.red)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.system(.subheadline, design: .rounded).bold())
                    .foregroundColor(.primary)
                
                HStack(spacing: 12) {
                    if let p = entry.protein {
                        MacroLabel(value: p, color: .red, label: "P")
                    }
                    if let c = entry.carb {
                        MacroLabel(value: c, color: .orange, label: "K")
                    }
                    if let f = entry.fat {
                        MacroLabel(value: f, color: .yellow, label: "Y")
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.secondary.opacity(0.3))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
        )
    }
    
    private func iconForMealType(_ type: String) -> String {
        switch type {
        case "Kahvaltı": return "sunrise.fill"
        case "Öğle Yemeği": return "sun.max.fill"
        case "Akşam Yemeği": return "moon.stars.fill"
        default: return "leaf.fill"
        }
    }
}

struct MacroLabel: View {
    let value: Double
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .padding(4)
                .background(color.opacity(0.1))
                .foregroundColor(color)
                .clipShape(Circle())
            
            Text("\(String(format: "%.0f", value))g")
                .font(.system(size: 11, design: .rounded).bold())
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Add/Edit Meal Sheet
struct AddDietEntrySheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let dayIndex: Int
    var existingEntry: DietEntry? = nil
    
    @State private var title = ""
    @State private var mealType = "Kahvaltı"
    @State private var protein = 0.0
    @State private var carb = 0.0
    @State private var fat = 0.0
    
    let mealTypes = ["Kahvaltı", "Öğle Yemeği", "Akşam Yemeği", "Atıştırmalık"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Öğün Bilgisi") {
                    TextField("Yemek Adı", text: $title)
                        .font(.system(.body, design: .rounded))
                    
                    Picker("Öğün Tipi", selection: $mealType) {
                        ForEach(mealTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Besin Değerleri (Makrolar)") {
                    VStack(alignment: .leading, spacing: 12) {
                        MacroStepper(label: "Protein", value: $protein, color: .red)
                        MacroStepper(label: "Karbonhidrat", value: $carb, color: .orange)
                        MacroStepper(label: "Yağ", value: $fat, color: .yellow)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle(existingEntry == nil ? "Öğün Ekle" : "Öğünü Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let entry = existingEntry {
                    title = entry.title
                    mealType = entry.mealType
                    protein = entry.protein ?? 0
                    carb = entry.carb ?? 0
                    fat = entry.fat ?? 0
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                        .foregroundColor(.primary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        save()
                        dismiss()
                    }
                    .font(.system(.body, design: .rounded).bold())
                    .disabled(title.isEmpty)
                }
            }
        }
        .accentColor(.red)
    }
    
    private func save() {
        if let entry = existingEntry {
            entry.title = title
            entry.mealType = mealType
            entry.protein = protein > 0 ? protein : nil
            entry.carb = carb > 0 ? carb : nil
            entry.fat = fat > 0 ? fat : nil
        } else {
            let newEntry = DietEntry(
                dayIndex: dayIndex,
                mealType: mealType,
                title: title,
                protein: protein > 0 ? protein : nil,
                carb: carb > 0 ? carb : nil,
                fat: fat > 0 ? fat : nil
            )
            modelContext.insert(newEntry)
        }
    }
}

struct MacroStepper: View {
    let label: String
    @Binding var value: Double
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(.caption, design: .rounded).bold())
                    .foregroundColor(.secondary)
                Text("\(String(format: "%.1f", value))g")
                    .font(.system(.body, design: .rounded).bold())
                    .foregroundColor(color)
            }
            
            Spacer()
            
            Stepper("", value: $value, in: 0...500, step: 0.5)
                .labelsHidden()
        }
    }
}
