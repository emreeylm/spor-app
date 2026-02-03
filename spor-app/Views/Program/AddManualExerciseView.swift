import SwiftUI
import SwiftData
import PhotosUI

struct AddManualExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let dayIndex: Int
    
    @State private var exerciseName = ""
    @State private var sets = 3
    @State private var reps = 12
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Egzersiz Bilgileri") {
                    TextField("Egzersiz Adı", text: $exerciseName)
                        .font(.system(.body, design: .rounded))
                    
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        HStack {
                            if let data = selectedImageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.red.opacity(0.05))
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        VStack(spacing: 4) {
                                            Image(systemName: "camera.fill")
                                                .font(.title2)
                                            Text("Fotoğraf")
                                                .font(.caption2)
                                        }
                                        .foregroundColor(.red.opacity(0.6))
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(selectedImageData == nil ? "Resim Seç" : "Resmi Değiştir")
                                    .font(.system(.headline, design: .rounded))
                                    .foregroundColor(.primary)
                                Text("Hareketin yapılışını gösteren bir görsel ekleyin")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.leading, 8)
                        }
                    }
                    .padding(.vertical, 8)
                    .onChange(of: selectedItem) { oldValue, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                        }
                    }
                }
                
                Section("Set ve Tekrar") {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Set Sayısı")
                                .font(.system(.subheadline, design: .rounded).bold())
                            Stepper("\(sets)", value: $sets, in: 1...20)
                        }
                        
                        Divider()
                            .padding(.horizontal, 8)
                        
                        VStack(alignment: .leading) {
                            Text("Tekrar Sayısı")
                                .font(.system(.subheadline, design: .rounded).bold())
                            Stepper("\(reps)", value: $reps, in: 1...100)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Yeni Egzersiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                        .foregroundColor(.primary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ekle") {
                        saveEntry()
                        dismiss()
                    }
                    .font(.system(.body, design: .rounded).bold())
                    .disabled(exerciseName.isEmpty)
                }
            }
        }
        .accentColor(.red)
    }
    
    private func saveEntry() {
        let newEntry = ProgramEntry(
            dayIndex: dayIndex,
            exerciseId: UUID().uuidString,
            exerciseName: exerciseName,
            sets: sets,
            reps: reps,
            exerciseImageData: selectedImageData
        )
        
        modelContext.insert(newEntry)
    }
}
