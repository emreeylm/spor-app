import Foundation
import SwiftData

@Model
final class DietEntry {
    @Attribute(.unique) var id: UUID
    var dayIndex: Int // 0..6
    var mealType: String // "Breakfast", "Lunch", "Dinner", "Snack"
    var title: String
    var protein: Double?
    var carb: Double?
    var fat: Double?
    var note: String?
    var createdAt: Date
    var sortOrder: Int
    
    init(
        id: UUID = UUID(),
        dayIndex: Int,
        mealType: String,
        title: String,
        protein: Double? = nil,
        carb: Double? = nil,
        fat: Double? = nil,
        note: String? = nil,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.dayIndex = dayIndex
        self.mealType = mealType
        self.title = title
        self.protein = protein
        self.carb = carb
        self.fat = fat
        self.note = note
        self.createdAt = Date()
        self.sortOrder = sortOrder
    }
}
