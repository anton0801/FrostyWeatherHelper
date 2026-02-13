import Foundation
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var trips: [TripLog] = []
    @Published var quickTemplates: [QuickNoteTemplate] = []
    @Published var settings: AppSettings = .default
    
    private let tripsKey = "saved_trips"
    private let templatesKey = "quick_templates"
    private let settingsKey = "app_settings"
    
    private init() {
        loadData()
    }
    
    // MARK: - Data Persistence
    func loadData() {
        // Load trips
        if let data = UserDefaults.standard.data(forKey: tripsKey),
           let decoded = try? JSONDecoder().decode([TripLog].self, from: data) {
            trips = decoded
        }
        
        // Load templates
        if let data = UserDefaults.standard.data(forKey: templatesKey),
           let decoded = try? JSONDecoder().decode([QuickNoteTemplate].self, from: data) {
            quickTemplates = decoded
        } else {
            quickTemplates = QuickNoteTemplate.defaultTemplates
            saveTemplates()
        }
        
        // Load settings
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = decoded
        }
    }
    
    func saveTrips() {
        if let encoded = try? JSONEncoder().encode(trips) {
            UserDefaults.standard.set(encoded, forKey: tripsKey)
        }
    }
    
    func saveTemplates() {
        if let encoded = try? JSONEncoder().encode(quickTemplates) {
            UserDefaults.standard.set(encoded, forKey: templatesKey)
        }
    }
    
    func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
    }
    
    // MARK: - Trip Management
    func addTrip(_ trip: TripLog) {
        trips.insert(trip, at: 0)
        saveTrips()
    }
    
    func updateTrip(_ trip: TripLog) {
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[index] = trip
            saveTrips()
        }
    }
    
    func deleteTrip(_ trip: TripLog) {
        trips.removeAll { $0.id == trip.id }
        saveTrips()
    }
    
    func duplicateTrip(_ trip: TripLog) {
        var newTrip = trip
        newTrip.id = UUID()
        newTrip.date = Date()
        trips.insert(newTrip, at: 0)
        saveTrips()
    }
    
    // MARK: - Template Management
    func addTemplate(_ template: QuickNoteTemplate) {
        quickTemplates.append(template)
        saveTemplates()
    }
    
    func deleteTemplate(_ template: QuickNoteTemplate) {
        quickTemplates.removeAll { $0.id == template.id }
        saveTemplates()
    }
    
    // MARK: - Statistics
    func getStatistics() -> TripStatistics {
        let now = Date()
        let calendar = Calendar.current
        
        // Trips this month
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let tripsThisMonth = trips.filter { $0.date >= monthStart }.count
        
        // Average temperature
        let avgTemp = trips.isEmpty ? 0 : trips.map { $0.temperature }.reduce(0, +) / Double(trips.count)
        
        // Average bite score
        let avgBite = trips.isEmpty ? 0 : Double(trips.map { $0.biteScore }.reduce(0, +)) / Double(trips.count)
        
        // Total catch
        let totalCatch = trips.map { $0.catchCount }.reduce(0, +)
        
        // Current streak
        let streak = calculateStreak()
        
        return TripStatistics(
            totalTrips: trips.count,
            averageTemperature: avgTemp,
            averageBiteScore: avgBite,
            totalCatch: totalCatch,
            currentStreak: streak,
            tripsThisMonth: tripsThisMonth
        )
    }
    
    private func calculateStreak() -> Int {
        guard !trips.isEmpty else { return 0 }
        
        let sortedTrips = trips.sorted { $0.date > $1.date }
        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        for trip in sortedTrips {
            let tripDate = calendar.startOfDay(for: trip.date)
            let daysDiff = calendar.dateComponents([.day], from: tripDate, to: currentDate).day ?? 0
            
            if daysDiff == 0 || daysDiff == 1 {
                streak += 1
                currentDate = tripDate
            } else {
                break
            }
        }
        
        return streak
    }
    
    // MARK: - Filtering & Search
    func filteredTrips(searchText: String, temperatureRange: ClosedRange<Double>? = nil, windLevel: WindLevel? = nil, minBiteScore: Int? = nil) -> [TripLog] {
        var filtered = trips
        
        // Search text
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.placeName.localizedCaseInsensitiveContains(searchText) ||
                $0.notes.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Temperature range
        if let range = temperatureRange {
            filtered = filtered.filter { range.contains($0.temperature) }
        }
        
        // Wind level
        if let wind = windLevel {
            filtered = filtered.filter { $0.windLevel == wind }
        }
        
        // Bite score
        if let minScore = minBiteScore {
            filtered = filtered.filter { $0.biteScore >= minScore }
        }
        
        return filtered
    }
    
    // MARK: - Comparison Data
    func getComparisonData(metric: ComparisonMetric, period: AnalysisPeriod) -> [ComparisonItem] {
        let filteredTrips = filterByPeriod(period)
        
        switch metric {
        case .avgBiteScore:
            return generateTemperatureBins(trips: filteredTrips, useAvgBite: true)
        case .catchCount:
            return generateTemperatureBins(trips: filteredTrips, useAvgBite: false)
        case .windComparison:
            return generateWindComparison(trips: filteredTrips)
        }
    }
    
    private func filterByPeriod(_ period: AnalysisPeriod) -> [TripLog] {
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
            return trips.filter { $0.date >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
            return trips.filter { $0.date >= monthAgo }
        case .custom:
            return trips
        }
    }
    
    private func generateTemperatureBins(trips: [TripLog], useAvgBite: Bool) -> [ComparisonItem] {
        let bins: [(String, ClosedRange<Double>)] = [
            ("-20..-10°C", -20...(-10)),
            ("-10..0°C", -10...0),
            ("0..5°C", 0...5),
            ("5..10°C", 5...10)
        ]
        
        return bins.map { label, range in
            let tripsInRange = trips.filter { range.contains($0.temperature) }
            let value: Double
            
            if useAvgBite {
                value = tripsInRange.isEmpty ? 0 : Double(tripsInRange.map { $0.biteScore }.reduce(0, +)) / Double(tripsInRange.count)
            } else {
                value = Double(tripsInRange.map { $0.catchCount }.reduce(0, +))
            }
            
            return ComparisonItem(label: label, value: value, count: tripsInRange.count)
        }
    }
    
    private func generateWindComparison(trips: [TripLog]) -> [ComparisonItem] {
        return WindLevel.allCases.map { wind in
            let filtered = trips.filter { $0.windLevel == wind }
            let avgBite = filtered.isEmpty ? 0 : Double(filtered.map { $0.biteScore }.reduce(0, +)) / Double(filtered.count)
            
            return ComparisonItem(label: wind.rawValue, value: avgBite, count: filtered.count)
        }
    }
    
    // MARK: - Export
    func exportToCSV() -> String {
        var csv = "Date,Place,Temperature,Pressure,Wind,Cloud,Ice,Bite Score,Catch,Notes\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        for trip in trips.sorted(by: { $0.date > $1.date }) {
            let row = [
                dateFormatter.string(from: trip.date),
                trip.placeName,
                String(trip.temperature),
                trip.pressure.map { String($0) } ?? "",
                trip.windLevel.rawValue,
                trip.cloudCover.rawValue,
                trip.iceCondition.rawValue,
                String(trip.biteScore),
                String(trip.catchCount),
                trip.notes.replacingOccurrences(of: ",", with: ";")
            ].joined(separator: ",")
            
            csv += row + "\n"
        }
        
        return csv
    }
    
    func exportToJSON() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        if let data = try? encoder.encode(trips),
           let json = String(data: data, encoding: .utf8) {
            return json
        }
        
        return "{}"
    }
    
    // MARK: - Reset
    func resetAllData() {
        trips.removeAll()
        quickTemplates = QuickNoteTemplate.defaultTemplates
        settings = .default
        
        saveTrips()
        saveTemplates()
        saveSettings()
    }
}

// MARK: - Supporting Types
enum ComparisonMetric: String, CaseIterable {
    case avgBiteScore = "Avg Bite Score"
    case catchCount = "Catch Count"
    case windComparison = "Wind Impact"
}

struct ComparisonItem: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    let count: Int
}
