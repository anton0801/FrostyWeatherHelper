import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showAddLog = false
    @State private var animateStats = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dashboard")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.appTextPrimary)
                        
                        Text(formattedDate)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.appTextSecondary)
                    }
                    
                    Spacer()
                    
                    // Add button
                    Button(action: {
                        showAddLog = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.appAccent)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Last trip card
                if let lastTrip = dataManager.trips.first {
                    LastTripCard(trip: lastTrip)
                        .padding(.horizontal, 20)
                }
                
                // Quick stats
                let stats = dataManager.getStatistics()
                
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        StatCard(
                            title: "Trips This Month",
                            value: "\(stats.tripsThisMonth)",
                            icon: "calendar",
                            color: .appAccent,
                            animate: animateStats
                        )
                        
                        StatCard(
                            title: "Avg Temperature",
                            value: String(format: "%.1f°", stats.averageTemperature),
                            icon: "thermometer.medium",
                            color: .appSuccess,
                            animate: animateStats
                        )
                    }
                    
                    HStack(spacing: 16) {
                        StatCard(
                            title: "Avg Bite Score",
                            value: String(format: "%.1f", stats.averageBiteScore),
                            icon: "star.fill",
                            color: Color.orange,
                            animate: animateStats
                        )
                        
                        StatCard(
                            title: "Current Streak",
                            value: "\(stats.currentStreak) days",
                            icon: "flame.fill",
                            color: Color.red,
                            animate: animateStats
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                // Goals section
                GoalProgressView()
                    .padding(.horizontal, 20)
                
                Spacer(minLength: 100)
            }
        }
        .background(Color.appBackground)
        .sheet(isPresented: $showAddLog) {
            AddEditLogView(trip: nil)
        }
        .onAppear {
            withAnimation(.spring().delay(0.2)) {
                animateStats = true
            }
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }
}

// MARK: - Last Trip Card
struct LastTripCard: View {
    let trip: TripLog
    @State private var scale: CGFloat = 0.95
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Last Trip")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appTextSecondary)
                    
                    Text(trip.placeName.isEmpty ? "Unknown Location" : trip.placeName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                }
                
                Spacer()
                
                Text(formatDate(trip.date))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.appTextSecondary)
            }
            
            // Weather info
            HStack(spacing: 20) {
                WeatherInfoItem(icon: "thermometer.medium", value: "\(Int(trip.temperature))°C", color: .appAccent)
                WeatherInfoItem(icon: trip.windLevel.icon, value: trip.windLevel.rawValue, color: .appSuccess)
                if let pressure = trip.pressure {
                    WeatherInfoItem(icon: "barometer", value: "\(Int(pressure)) hPa", color: Color.orange)
                }
            }
            
            // Result
            HStack {
                Text("Bite Score:")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appTextSecondary)
                
                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= trip.biteScore ? "star.fill" : "star")
                            .font(.system(size: 14))
                            .foregroundColor(index <= trip.biteScore ? Color.orange : .appTextSecondary.opacity(0.3))
                    }
                }
                
                Spacer()
                
                Text("\(trip.catchCount) fish")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appSuccess)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.appCard)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                scale = 1.0
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

struct WeatherInfoItem: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appTextPrimary)
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let animate: Bool
    
    @State private var displayValue: Double = 0
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.appTextPrimary)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appCard)
                .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Goal Progress View
struct GoalProgressView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        let stats = dataManager.getStatistics()
        let progress = Double(stats.tripsThisMonth) / Double(dataManager.settings.monthlyGoal)
        
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Monthly Goal")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.appTextPrimary)
                
                Spacer()
                
                Text("\(stats.tripsThisMonth) / \(dataManager.settings.monthlyGoal)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appAccent)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.appDivider)
                        .frame(height: 12)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color.appAccent, Color.appSuccess],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * min(progress, 1.0), height: 12)
                }
            }
            .frame(height: 12)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.appCard)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(DataManager.shared)
    }
}
