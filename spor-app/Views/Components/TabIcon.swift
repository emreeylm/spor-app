import SwiftUI

struct TabIcon: View {
    let iconName: String
    let label: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.system(size: 20, weight: isSelected ? .bold : .regular))
                .scaleEffect(isSelected ? 1.2 : 1.0)
            Text(label)
                .font(.caption2)
        }
        .foregroundColor(isSelected ? .blue : .gray)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}
