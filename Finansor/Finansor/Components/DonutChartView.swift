import SwiftUI

struct DonutChartView: View {
    var segments: [AnalysisChartSegment]
    var width: CGFloat = 150
    var innerRadiusFraction: CGFloat = 0.6
    var title: String? = nil
    var subtitle: String? = nil
    
    private var totalValue: Double {
        let total = segments.reduce(0) { $0 + $1.value }
        return total > 0 ? total : 1 // Sıfıra bölünmeyi önlemek için
    }
    
    // Sadece en fazla 5 segmenti gösterip, geri kalanları "Diğer" kategorisinde birleştirir
    private var processedSegments: [AnalysisChartSegment] {
        guard segments.count > 5 else { return segments }
        
        var mainSegments = Array(segments.prefix(4))
        let otherSegments = Array(segments.suffix(from: 4))
        let otherTotal = otherSegments.reduce(0) { $0 + $1.value }
        
        if otherTotal > 0 {
            mainSegments.append(AnalysisChartSegment(
                name: "Diğer",
                value: otherTotal,
                color: Color.gray
            ))
        }
        
        return mainSegments
    }
    
    var body: some View {
        VStack {
            ZStack {
                ForEach(processedSegments.indices, id: \.self) { index in
                    if processedSegments[index].value > 0 {
                        DonutSegment(
                            data: processedSegments,
                            index: index,
                            innerRadiusFraction: innerRadiusFraction,
                            total: totalValue
                        )
                    }
                }
                
                if let title {
                    VStack(spacing: 4) {
                        Text(title)
                            .font(.system(size: width/8))
                            .bold()
                            .foregroundColor(.white)
                        
                        if let subtitle {
                            Text(subtitle)
                                .font(.system(size: width/12))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(8)
                    .background(FinansorColors.cardDark)
                    .cornerRadius(width/8)
                }
            }
            .frame(width: width, height: width)
            
            if !processedSegments.isEmpty {
                HStack(spacing: 8) {
                    // En fazla 3 öğeyi yan yana gösteriyoruz
                    ForEach(Array(processedSegments.prefix(3))) { segment in
                        if segment.value > 0 {
                            LegendItem(segment: segment, total: totalValue)
                        }
                    }
                }
                .padding(.top, 8)
                
                // Ekstra legandları ekliyoruz
                if processedSegments.count > 3 {
                    HStack(spacing: 8) {
                        ForEach(Array(processedSegments.dropFirst(3))) { segment in
                            if segment.value > 0 {
                                LegendItem(segment: segment, total: totalValue)
                            }
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
    }
}

struct DonutSegment: View {
    var data: [AnalysisChartSegment]
    var index: Int
    var innerRadiusFraction: CGFloat
    var total: Double
    
    private var gradientColors: [Color] {
        [data[index].color.opacity(0.8), data[index].color]
    }
    
    var body: some View {
        GeometryReader { geometry in
            let width = min(geometry.size.width, geometry.size.height)
            let radius = width / 2
            let innerRadius = radius * innerRadiusFraction
            
            let path = Path { path in
                path.addArc(
                    center: CGPoint(x: width / 2, y: width / 2),
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false
                )
                
                path.addArc(
                    center: CGPoint(x: width / 2, y: width / 2),
                    radius: innerRadius,
                    startAngle: endAngle,
                    endAngle: startAngle,
                    clockwise: true
                )
                
                path.closeSubpath()
            }
            
            path
                .fill(
                    AngularGradient(
                        gradient: Gradient(colors: gradientColors),
                        center: .center,
                        startAngle: startAngle,
                        endAngle: endAngle
                    )
                )
                .overlay(
                    path.stroke(Color.black.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: data[index].color.opacity(0.3), radius: 2, x: 0, y: 1)
        }
    }
    
    private var startAngle: Angle {
        let startValue = data.prefix(index).reduce(0) { $0 + $1.value }
        return Angle(degrees: -90 + 360 * (startValue / total))
    }
    
    private var endAngle: Angle {
        let endValue = data.prefix(index + 1).reduce(0) { $0 + $1.value }
        return Angle(degrees: -90 + 360 * (endValue / total))
    }
}

struct LegendItem: View {
    var segment: AnalysisChartSegment
    var total: Double
    
    private var percentage: Int {
        Int((segment.value / total) * 100)
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(segment.color)
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(segment.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white) // AppColors.textDark
                    .lineLimit(1)
                
                HStack(spacing: 2) {
                    Text("₺\(Int(segment.value))")
                        .font(.caption2)
                        .bold()
                        .foregroundColor(segment.color)
                    
                    Text("\(percentage)%")
                        .font(.caption2)
                        .foregroundColor(Color.gray.opacity(0.6)) // AppColors.secondaryTextDark
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
    }
}

struct DonutChartView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(red: 0.10, green: 0.15, blue: 0.20).ignoresSafeArea() // Using explicit color instead of ambiguous reference
            
            DonutChartView(
                segments: [
                    AnalysisChartSegment(name: "Yemek", value: 1200, color: .orange),
                    AnalysisChartSegment(name: "Kira", value: 2500, color: .blue),
                    AnalysisChartSegment(name: "Faturalar", value: 800, color: .red),
                    AnalysisChartSegment(name: "Eğlence", value: 550, color: .purple),
                    AnalysisChartSegment(name: "Alışveriş", value: 450, color: .pink)
                ],
                title: "₺4,500",
                subtitle: "Toplam"
            )
        }
    }
} 