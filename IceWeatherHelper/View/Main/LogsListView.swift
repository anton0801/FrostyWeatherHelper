import SwiftUI

struct LogsListView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var searchText = ""
    @State private var selectedWindFilter: WindLevel?
    @State private var showAddLog = false
    @State private var selectedTrip: TripLog?
    
    var filteredTrips: [TripLog] {
        dataManager.filteredTrips(
            searchText: searchText,
            windLevel: selectedWindFilter
        )
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Logs")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.appTextPrimary)
                    
                    Spacer()
                    
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
                
                // Search bar
                SearchBar(text: $searchText)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterChip(
                            title: "All",
                            isSelected: selectedWindFilter == nil,
                            action: { selectedWindFilter = nil }
                        )
                        
                        ForEach(WindLevel.allCases, id: \.self) { wind in
                            FilterChip(
                                title: wind.rawValue,
                                isSelected: selectedWindFilter == wind,
                                action: { selectedWindFilter = wind }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 16)
                
                // List
                if filteredTrips.isEmpty {
                    EmptyStateView(
                        icon: "tray",
                        title: searchText.isEmpty ? "No logs yet" : "No results",
                        description: searchText.isEmpty ? "Add your first trip log to get started" : "Try adjusting your search"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredTrips) { trip in
                                TripLogCard(trip: trip)
                                    .onTapGesture {
                                        selectedTrip = trip
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddLog) {
            AddEditLogView(trip: nil)
        }
        .sheet(item: $selectedTrip) { trip in
            LogDetailView(trip: trip)
        }
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundColor(.appTextSecondary)
            
            TextField("Search logs...", text: $text)
                .font(.system(size: 16))
                .foregroundColor(.appTextPrimary)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.appTextSecondary)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appCard)
        )
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? .white : .appTextSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.appAccent : Color.appCard)
                )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Trip Log Card
struct TripLogCard: View {
    let trip: TripLog
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.placeName.isEmpty ? "No location" : trip.placeName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                    
                    Text(formatDate(trip.date))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                }
                
                Spacer()
                
                Image(systemName: trip.tripType.icon)
                    .font(.system(size: 20))
                    .foregroundColor(.appAccent)
            }
            
            // Weather conditions
            HStack(spacing: 16) {
                ConditionBadge(icon: "thermometer.medium", value: "\(Int(trip.temperature))°", color: .appAccent)
                ConditionBadge(icon: trip.windLevel.icon, value: trip.windLevel.rawValue, color: .appSuccess)
                ConditionBadge(icon: trip.iceCondition.icon, value: trip.iceCondition.rawValue, color: Color.cyan)
            }
            
            Divider()
                .background(Color.appDivider)
            
            // Results
            HStack {
                // Bite score
                HStack(spacing: 4) {
                    Text("Bite:")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                    
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= trip.biteScore ? "star.fill" : "star")
                                .font(.system(size: 12))
                                .foregroundColor(index <= trip.biteScore ? Color.orange : .appTextSecondary.opacity(0.3))
                        }
                    }
                }
                
                Spacer()
                
                // Catch count
                HStack(spacing: 4) {
                    Image(systemName: "fish.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.appSuccess)
                    
                    Text("\(trip.catchCount)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appTextPrimary)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appCard)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(scale)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 0.98
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.0
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Condition Badge
struct ConditionBadge: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.appTextSecondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.15))
        )
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    
    @State private var pulse = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.appTextSecondary.opacity(0.5))
                .scaleEffect(pulse ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulse)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.appTextPrimary)
                
                Text(description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            pulse = true
        }
    }
}

struct LogsListView_Previews: PreviewProvider {
    static var previews: some View {
        LogsListView()
            .environmentObject(DataManager.shared)
    }
}
