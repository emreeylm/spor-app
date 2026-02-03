import SwiftUI

struct DayPickerView: View {
    @Binding var selectedDayIndex: Int
    let days = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(0..<7) { index in
                    VStack(spacing: 4) {
                        Text(days[index])
                            .font(.system(size: 14, weight: .medium))
                        
                        Circle()
                            .fill(selectedDayIndex == index ? Color.blue : Color.clear)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("\(index + 1)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(selectedDayIndex == index ? .white : .primary)
                            )
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedDayIndex == index ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
                    )
                    .onTapGesture {
                        withAnimation(.spring()) {
                            selectedDayIndex = index
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}
