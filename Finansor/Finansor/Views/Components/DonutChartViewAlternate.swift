import SwiftUI

struct DonutChartViewAlternate: View {
    var segments: [AnalysisChartSegment]
    var width: CGFloat
    var title: String
    var subtitle: String
    
    private var totalValue: Double {
        segments.reduce(0) { $0 + $1.value }
    }
    
    var body: some View {
        ZStack {
            // Donut chart
            ZStack {
                ForEach(0..<segments.count, id: \.self) { index in
                    DonutSegmentAlternate(
                        data: segments,
                        index: index,
                        width: width * 0.8,
                        innerRadiusFraction: 0.6
                    )
                }
            }
            .frame(width: width, height: width)
            
            // Center text
            VStack(spacing: 4) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}

struct DonutSegmentAlternate: View {
    var data: [AnalysisChartSegment]
    var index: Int
    var width: CGFloat
    var innerRadiusFraction: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                let radius = min(geometry.size.width, geometry.size.height) / 2
                let innerRadius = radius * innerRadiusFraction
                
                let totalValue = data.reduce(0) { $0 + $1.value }
                var endDegree: Double = 0
                
                // Calculate the start and end angles for this segment
                var startDegree: Double = 0
                if index > 0 {
                    for i in 0..<index {
                        startDegree += (data[i].value / totalValue) * 360
                    }
                }
                endDegree = startDegree + (data[index].value / totalValue) * 360
                
                // Convert to radians and adjust for path drawing
                let startAngle = Angle(degrees: startDegree - 90)
                let endAngle = Angle(degrees: endDegree - 90)
                
                // Draw segment
                path.move(to: center)
                path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                path.addArc(center: center, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: true)
                path.closeSubpath()
            }
            .fill(data[index].color)
        }
    }
}

struct DonutChartViewAlternate_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            DonutChartViewAlternate(
                segments: [
                    AnalysisChartSegment(name: "Yemek", value: 580, color: .red),
                    AnalysisChartSegment(name: "Ulaşım", value: 320, color: .blue),
                    AnalysisChartSegment(name: "Alışveriş", value: 450, color: .green),
                    AnalysisChartSegment(name: "Diğer", value: 250, color: .orange),
                ],
                width: 200,
                title: "₺1.600",
                subtitle: "Toplam Gider"
            )
        }
    }
} 