import SwiftUI

struct StepIndicatorView: View {
    var currentStep: Int
    var totalSteps: Int = 5
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? FinansorColors.accentYellow : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

#Preview {
    StepIndicatorView(currentStep: 2)
        .preferredColorScheme(.dark)
} 