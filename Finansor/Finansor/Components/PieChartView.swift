import SwiftUI

struct PieChartView: View {
    var segments: [ChartSegment]
    var width: CGFloat = 150
    var showLegend: Bool = true
    
    private var totalValue: Double {
        segments.reduce(0) { $0 + $1.value }
    }
    
    var body: some View {
        VStack {
            ZStack {
                ForEach(segments.indices, id: \.self) { index in
                    PieSlice(
                        data: segments,
                        index: index
                    )
                }
            }
            .frame(width: width, height: width)
            
            if showLegend && !segments.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(segments) { segment in
                        PieLegendItem(segment: segment, total: totalValue)
                    }
                }
                .padding(.top, 8)
            }
        }
    }
}

struct PieSlice: View {
    var data: [ChartSegment]
    var index: Int
    
    private var gradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: [data[index].color.opacity(0.8), data[index].color]),
            center: .center,
            startAngle: startAngle,
            endAngle: endAngle
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            let width = min(geometry.size.width, geometry.size.height)
            let radius = width / 2
            
            let path = Path { path in
                path.move(to: CGPoint(x: width / 2, y: width / 2))
                path.addArc(
                    center: CGPoint(x: width / 2, y: width / 2),
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false
                )
                path.closeSubpath()
            }
            
            path
                .fill(gradient)
                .overlay(
                    path
                        .stroke(Color.white, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
    }
    
    private var totalValue: Double {
        data.reduce(0) { $0 + $1.value }
    }
    
    private var startAngle: Angle {
        let startValue = data.prefix(index).reduce(0) { $0 + $1.value }
        return Angle(degrees: -90 + 360 * (startValue / totalValue))
    }
    
    private var endAngle: Angle {
        let endValue = data.prefix(index + 1).reduce(0) { $0 + $1.value }
        return Angle(degrees: -90 + 360 * (endValue / totalValue))
    }
}

struct PieLegendItem: View {
    var segment: ChartSegment
    var total: Double
    
    private var percentage: Int {
        Int(segment.value / total * 100)
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(segment.color)
                .frame(width: 12, height: 12)
            
            Text(segment.name)
                .font(.caption)
                .foregroundColor(AppColors.textDark)
            
            Spacer()
            
            Text("₺\(Int(segment.value))")
                .font(.caption)
                .bold()
                .foregroundColor(AppColors.textDark)
            
            Text("(\(percentage)%)")
                .font(.caption)
                .foregroundColor(AppColors.secondaryTextDark)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PieChartView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppColors.backgroundDark.ignoresSafeArea()
            
            PieChartView(
                segments: [
                    ChartSegment(name: "Yemek", value: 1200, color: .orange),
                    ChartSegment(name: "Kira", value: 2500, color: .blue),
                    ChartSegment(name: "Faturalar", value: 800, color: .yellow),
                    ChartSegment(name: "Eğlence", value: 500, color: .purple)
                ]
            )
        }
        .padding()
    }
} 