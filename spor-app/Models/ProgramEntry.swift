import Foundation
import SwiftData

@Model
final class ProgramEntry {
    @Attribute(.unique) var id: UUID
    var dayIndex: Int // 0..6 (Mon..Sun)
    var exerciseId: String
    var exerciseName: String
    var sets: Int
    var reps: Int
    var exerciseImageData: Data?
    var createdAt: Date
    var sortOrder: Int
    
    init(
        id: UUID = UUID(),
        dayIndex: Int,
        exerciseId: String,
        exerciseName: String,
        sets: Int,
        reps: Int,
        exerciseImageData: Data? = nil,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.dayIndex = dayIndex
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.sets = sets
        self.reps = reps
        self.exerciseImageData = exerciseImageData
        self.createdAt = Date()
        self.sortOrder = sortOrder
    }
}
