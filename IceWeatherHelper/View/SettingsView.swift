import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showResetAlert = false
    @State private var showExportOptions = false
    @State private var exportFormat: ExportFormat = .csv
    @State private var shareURL: URL?
    
    enum ExportFormat: String, CaseIterable {
        case csv = "CSV"
        case json = "JSON"
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Text("Settings")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.appTextPrimary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Units section
                    SettingsSection(title: "Units") {
                        VStack(spacing: 12) {
                            SettingsRow(title: "Temperature") {
                                Picker("", selection: $dataManager.settings.temperatureUnit) {
                                    ForEach(TemperatureUnit.allCases, id: \.self) { unit in
                                        Text(unit.rawValue).tag(unit)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 120)
                            }
                            
                            SettingsRow(title: "Pressure") {
                                Picker("", selection: $dataManager.settings.pressureUnit) {
                                    ForEach(PressureUnit.allCases, id: \.self) { unit in
                                        Text(unit.rawValue).tag(unit)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 120)
                            }
                        }
                    }
                    
                    // Goals section
                    SettingsSection(title: "Goals") {
                        SettingsRow(title: "Monthly Log Goal") {
                            Stepper("\(dataManager.settings.monthlyGoal)", value: $dataManager.settings.monthlyGoal, in: 1...50)
                                .foregroundColor(.appAccent)
                        }
                    }
                    
                    // Data section
                    SettingsSection(title: "Data") {
                        VStack(spacing: 12) {
                            Button(action: {
                                showExportOptions = true
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 18))
                                        .foregroundColor(.appAccent)
                                    
                                    Text("Export Data")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.appTextPrimary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.appTextSecondary)
                                }
                            }
                            
                            Divider()
                                .background(Color.appDivider)
                            
                            Button(action: {
                                showResetAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                        .font(.system(size: 18))
                                        .foregroundColor(.appWarning)
                                    
                                    Text("Reset All Data")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.appWarning)
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    // Statistics section
                    let stats = dataManager.getStatistics()
                    
                    SettingsSection(title: "Statistics") {
                        VStack(spacing: 12) {
                            StatRow(title: "Total Trips", value: "\(stats.totalTrips)")
                            StatRow(title: "Total Catch", value: "\(stats.totalCatch)")
                            StatRow(title: "Avg Temperature", value: String(format: "%.1f°C", stats.averageTemperature))
                            StatRow(title: "Avg Bite Score", value: String(format: "%.1f", stats.averageBiteScore))
                        }
                    }
                    
                    // About section
                    SettingsSection(title: "About") {
                        VStack(spacing: 12) {
                            StatRow(title: "Version", value: "1.0.0")
                            StatRow(title: "Build", value: "2026.01")
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
            }
        }
        .onChange(of: dataManager.settings) { _ in
            dataManager.saveSettings()
        }
        .alert("Reset All Data", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                dataManager.resetAllData()
            }
        } message: {
            Text("This will permanently delete all your trip logs, templates, and settings. This action cannot be undone.")
        }
        .sheet(isPresented: $showExportOptions) {
            ExportView(exportFormat: $exportFormat)
        }
    }
}

// MARK: - Settings Section
struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.appTextPrimary)
                
                Spacer()
            }
            
            VStack(spacing: 0) {
                content
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appCard)
            )
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Settings Row
struct SettingsRow<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.appTextPrimary)
            
            Spacer()
            
            content
        }
    }
}

// MARK: - Stat Row
struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.appTextPrimary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.appAccent)
        }
    }
}

// MARK: - Export View
struct ExportView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    @Binding var exportFormat: SettingsView.ExportFormat
    
    @State private var isExporting = false
    @State private var shareURL: URL?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Format selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Export Format")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.appTextPrimary)
                        
                        Picker("Format", selection: $exportFormat) {
                            ForEach(SettingsView.ExportFormat.allCases, id: \.self) { format in
                                Text(format.rawValue).tag(format)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.appCard)
                    )
                    
                    // Info
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.appAccent)
                            
                            Text("Export includes all trip logs with dates, conditions, and results.")
                                .font(.system(size: 14))
                                .foregroundColor(.appTextSecondary)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.appCard)
                    )
                    
                    Spacer()
                    
                    // Export button
                    Button(action: exportData) {
                        if isExporting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 18))
                                
                                Text("Export Data")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [Color.appAccent, Color.appSuccess],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .disabled(isExporting)
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.appTextSecondary)
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Export Data")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                }
            }
        }
        .sheet(item: $shareURL) { url in
            ShareSheet(items: [url])
        }
    }
    
    private func exportData() {
        isExporting = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let content: String
            let filename: String
            
            switch exportFormat {
            case .csv:
                content = dataManager.exportToCSV()
                filename = "ice-weather-logs.csv"
            case .json:
                content = dataManager.exportToJSON()
                filename = "ice-weather-logs.json"
            }
            
            if let url = saveToFile(content: content, filename: filename) {
                shareURL = url
            }
            
            isExporting = false
        }
    }
    
    private func saveToFile(content: String, filename: String) -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(filename)
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error saving file: \(error)")
            return nil
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// Extension to make URL identifiable
extension URL: Identifiable {
    public var id: String { absoluteString }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(DataManager.shared)
    }
}
