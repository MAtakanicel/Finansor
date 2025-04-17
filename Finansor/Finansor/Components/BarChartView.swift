import SwiftUI

struct BarChartView: View {
    var data: [BarChartData]
    var title: String? = nil
    var maxBarHeight: CGFloat = 200
    var showAxisLabels: Bool = true
    var barCornerRadius: CGFloat = 6
    var barSpacing: CGFloat = 20
    var barWidth: CGFloat = 30
    
    private var maxValue: Double {
        data.map { $0.value }.max() ?? 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppColors.textDark)
                    .padding(.bottom, 8)
            }
            
            HStack(alignment: .bottom, spacing: barSpacing) {
                ForEach(data) { item in
                    VStack {
                        Text("₺\(Int(item.value))")
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryTextDark)
                        
                        BarView(
                            value: item.value,
                            maxValue: maxValue,
                            maxHeight: maxBarHeight,
                            color: item.color,
                            cornerRadius: barCornerRadius,
                            width: barWidth
                        )
                        
                        if showAxisLabels {
                            Text(item.label)
                                .font(.caption)
                                .foregroundColor(AppColors.secondaryTextDark)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                                .frame(width: barWidth + 5)
                        }
                    }
                }
            }
            .frame(height: maxBarHeight + 50)
            .padding(.horizontal)
        }
        .padding()
        .background(AppColors.cardDark)
        .cornerRadius(12)
    }
}

struct BarView: View {
    var value: Double
    var maxValue: Double
    var maxHeight: CGFloat
    var color: Color
    var cornerRadius: CGFloat
    var width: CGFloat
    
    private var barHeight: CGFloat {
        let ratio = value / maxValue
        return CGFloat(ratio) * maxHeight
    }
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [color.opacity(0.7), color]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .frame(width: width, height: max(barHeight, 10))
                .cornerRadius(cornerRadius)
                .shadow(color: color.opacity(0.3), radius: 2, x: 0, y: 2)
        }
    }
}

struct BarChartData: Identifiable {
    var id = UUID()
    var label: String
    var value: Double
    var color: Color
}

struct BarChartView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppColors.backgroundDark.ignoresSafeArea()
            
            BarChartView(
                data: [
                    BarChartData(label: "Ocak", value: 1500, color: .blue),
                    BarChartData(label: "Şubat", value: 2200, color: .green),
                    BarChartData(label: "Mart", value: 1800, color: .orange),
                    BarChartData(label: "Nisan", value: 2500, color: .purple),
                    BarChartData(label: "Mayıs", value: 3000, color: .pink)
                ],
                title: "Aylık Giderler"
            )
            .padding()
        }
    }
} 