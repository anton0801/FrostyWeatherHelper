import SwiftUI

struct CompareView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedMetric: ComparisonMetric = .avgBiteScore
    @State private var selectedPeriod: AnalysisPeriod = .month
    
    var comparisonData: [ComparisonItem] {
        dataManager.getComparisonData(metric: selectedMetric, period: selectedPeriod)
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            if dataManager.trips.isEmpty {
                EmptyStateView(
                    icon: "chart.bar.xaxis",
                    title: "No data to analyze",
                    description: "Log more trips to see patterns and comparisons"
                )
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        HStack {
                            Text("Compare")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.appTextPrimary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Metric selector
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Metric")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.appTextSecondary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(ComparisonMetric.allCases, id: \.self) { metric in
                                        MetricChip(
                                            title: metric.rawValue,
                                            isSelected: selectedMetric == metric,
                                            action: { 
                                                withAnimation(.spring()) {
                                                    selectedMetric = metric
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // Period selector
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Period")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.appTextSecondary)
                                .padding(.horizontal, 20)
                            
                            HStack(spacing: 12) {
                                ForEach([AnalysisPeriod.week, .month], id: \.self) { period in
                                    PeriodChip(
                                        title: period.rawValue,
                                        isSelected: selectedPeriod == period,
                                        action: {
                                            withAnimation(.spring()) {
                                                selectedPeriod = period
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Chart
                        BarChartView(data: comparisonData, metric: selectedMetric)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        
                        // Data table
                        DataTableView(data: comparisonData)
                            .padding(.horizontal, 20)
                        
                        Spacer(minLength: 100)
                    }
                }
            }
        }
    }
}

// MARK: - Metric Chip
struct MetricChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : .appTextSecondary)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.appAccent : Color.appCard)
                )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Period Chip
struct PeriodChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : .appTextSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.appAccent : Color.appCard)
                )
        }
    }
}

// MARK: - Bar Chart View
struct BarChartView: View {
    let data: [ComparisonItem]
    let metric: ComparisonMetric
    
    @State private var animateChart = false
    
    var maxValue: Double {
        data.map { $0.value }.max() ?? 1.0
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Chart
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(data) { item in
                    VStack(spacing: 8) {
                        // Value label
                        Text(formatValue(item.value))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.appTextPrimary)
                            .opacity(animateChart ? 1 : 0)
                        
                        // Bar
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [Color.appAccent, Color.appSuccess],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(height: animateChart ? CGFloat((item.value / maxValue) * 200) : 0)
                            .overlay(
                                Text("\(item.count)")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(4)
                                , alignment: .top
                            )
                        
                        // Label
                        Text(item.label)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.appTextSecondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .frame(height: 30)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 280)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appCard)
            )
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animateChart = true
            }
        }
        .onChange(of: metric) { _ in
            animateChart = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    animateChart = true
                }
            }
        }
    }
    
    private func formatValue(_ value: Double) -> String {
        if metric == .catchCount {
            return String(Int(value))
        } else {
            return String(format: "%.1f", value)
        }
    }
}

// MARK: - Data Table View
struct DataTableView: View {
    let data: [ComparisonItem]
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Detailed Breakdown")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.appTextPrimary)
                
                Spacer()
            }
            
            VStack(spacing: 8) {
                ForEach(data) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.label)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.appTextPrimary)
                            
                            Text("\(item.count) trips")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.appTextSecondary)
                        }
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", item.value))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.appAccent)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.appCard)
                    )
                }
            }
        }
    }
}

struct CompareView_Previews: PreviewProvider {
    static var previews: some View {
        CompareView()
            .environmentObject(DataManager.shared)
    }
}
