import Foundation

// MARK: - Trip Log Model
struct TripLog: Identifiable, Codable {
    var id: UUID
    var date: Date
    var time: Date?
    var placeName: String
    var tripType: TripType
    
    // Weather conditions
    var temperature: Double
    var pressure: Double?
    var windLevel: WindLevel
    var cloudCover: CloudCover
    var precipitation: Precipitation
    var iceCondition: IceCondition
    
    // Results
    var biteScore: Int // 1-5
    var catchCount: Int
    var notes: String
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        time: Date? = nil,
        placeName: String = "",
        tripType: TripType = .ice,
        temperature: Double = 0,
        pressure: Double? = nil,
        windLevel: WindLevel = .low,
        cloudCover: CloudCover = .normal,
        precipitation: Precipitation = .none,
        iceCondition: IceCondition = .clear,
        biteScore: Int = 3,
        catchCount: Int = 0,
        notes: String = ""
    ) {
        self.id = id
        self.date = date
        self.time = time
        self.placeName = placeName
        self.tripType = tripType
        self.temperature = temperature
        self.pressure = pressure
        self.windLevel = windLevel
        self.cloudCover = cloudCover
        self.precipitation = precipitation
        self.iceCondition = iceCondition
        self.biteScore = biteScore
        self.catchCount = catchCount
        self.notes = notes
    }
}

// MARK: - Enums
enum TripType: String, Codable, CaseIterable {
    case ice = "Ice"
    case shore = "Shore"
    case boat = "Boat"
    
    var icon: String {
        switch self {
        case .ice: return "snowflake"
        case .shore: return "figure.walk"
        case .boat: return "ferry"
        }
    }
}

enum WindLevel: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var icon: String {
        switch self {
        case .low: return "wind"
        case .medium: return "wind"
        case .high: return "tornado"
        }
    }
}

enum CloudCover: String, Codable, CaseIterable {
    case clear = "Clear"
    case normal = "Normal"
    case overcast = "Overcast"
    
    var icon: String {
        switch self {
        case .clear: return "sun.max.fill"
        case .normal: return "cloud.sun.fill"
        case .overcast: return "cloud.fill"
        }
    }
}

enum Precipitation: String, Codable, CaseIterable {
    case none = "None"
    case snow = "Snow"
    case rain = "Rain"
    
    var icon: String {
        switch self {
        case .none: return "sun.max"
        case .snow: return "snow"
        case .rain: return "cloud.rain.fill"
        }
    }
}

enum IceCondition: String, Codable, CaseIterable {
    case clear = "Clear"
    case snowy = "Snowy"
    case slush = "Slush"
    case unknown = "Unknown"
    
    var icon: String {
        switch self {
        case .clear: return "drop.triangle"
        case .snowy: return "snowflake"
        case .slush: return "water.waves"
        case .unknown: return "questionmark.circle"
        }
    }
}

// MARK: - Quick Note Template
struct QuickNoteTemplate: Identifiable, Codable {
    var id: UUID
    var title: String
    var content: String
    var isCustom: Bool
    
    static let defaultTemplates: [QuickNoteTemplate] = [
        QuickNoteTemplate(id: UUID(), title: "Short Bites", content: "Fish were biting but not holding the hook well", isCustom: false),
        QuickNoteTemplate(id: UUID(), title: "Active Morning", content: "Very active in the morning, slowed down by noon", isCustom: false),
        QuickNoteTemplate(id: UUID(), title: "Windy Day", content: "Strong winds made fishing challenging", isCustom: false),
        QuickNoteTemplate(id: UUID(), title: "Ice Quality", content: "Ice conditions were excellent for fishing", isCustom: false),
        QuickNoteTemplate(id: UUID(), title: "Slow Day", content: "Very few bites throughout the day", isCustom: false)
    ]
}

// MARK: - App Settings
struct AppSettings: Codable, Equatable {
    var temperatureUnit: TemperatureUnit
    var pressureUnit: PressureUnit
    var defaultPeriod: AnalysisPeriod
    var monthlyGoal: Int
    
    static let `default` = AppSettings(
        temperatureUnit: .celsius,
        pressureUnit: .hpa,
        defaultPeriod: .month,
        monthlyGoal: 10
    )
    
    static func ==(l: AppSettings, r: AppSettings) -> Bool {
        return l.temperatureUnit == r.temperatureUnit && l.pressureUnit == r.pressureUnit && l.defaultPeriod == r.defaultPeriod && l.monthlyGoal == r.monthlyGoal
    }
}

enum TemperatureUnit: String, Codable, CaseIterable {
    case celsius = "°C"
    case fahrenheit = "°F"
    
    func convert(_ celsius: Double) -> Double {
        switch self {
        case .celsius: return celsius
        case .fahrenheit: return celsius * 9/5 + 32
        }
    }
}

enum PressureUnit: String, Codable, CaseIterable {
    case hpa = "hPa"
    case mmhg = "mmHg"
    
    func convert(_ hpa: Double) -> Double {
        switch self {
        case .hpa: return hpa
        case .mmhg: return hpa * 0.75006
        }
    }
}

enum AnalysisPeriod: String, Codable, CaseIterable {
    case week = "Week"
    case month = "Month"
    case custom = "Custom"
}

// MARK: - Statistics
struct TripStatistics {
    var totalTrips: Int
    var averageTemperature: Double
    var averageBiteScore: Double
    var totalCatch: Int
    var currentStreak: Int
    var tripsThisMonth: Int
}
