import SwiftUI

struct AddEditLogView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    
    let trip: TripLog?
    
    @State private var date: Date
    @State private var hasTime: Bool
    @State private var time: Date
    @State private var placeName: String
    @State private var tripType: TripType
    @State private var temperature: String
    @State private var pressure: String
    @State private var windLevel: WindLevel
    @State private var cloudCover: CloudCover
    @State private var precipitation: Precipitation
    @State private var iceCondition: IceCondition
    @State private var biteScore: Int
    @State private var catchCount: String
    @State private var notes: String
    
    @State private var showTemplates = false
    
    init(trip: TripLog?) {
        self.trip = trip
        
        _date = State(initialValue: trip?.date ?? Date())
        _hasTime = State(initialValue: trip?.time != nil)
        _time = State(initialValue: trip?.time ?? Date())
        _placeName = State(initialValue: trip?.placeName ?? "")
        _tripType = State(initialValue: trip?.tripType ?? .ice)
        _temperature = State(initialValue: trip != nil ? String(Int(trip!.temperature)) : "")
        _pressure = State(initialValue: trip?.pressure != nil ? String(Int(trip!.pressure!)) : "")
        _windLevel = State(initialValue: trip?.windLevel ?? .low)
        _cloudCover = State(initialValue: trip?.cloudCover ?? .normal)
        _precipitation = State(initialValue: trip?.precipitation ?? .none)
        _iceCondition = State(initialValue: trip?.iceCondition ?? .clear)
        _biteScore = State(initialValue: trip?.biteScore ?? 3)
        _catchCount = State(initialValue: trip != nil ? String(trip!.catchCount) : "0")
        _notes = State(initialValue: trip?.notes ?? "")
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Trip info section
                        SectionHeader(title: "Trip Details")
                        
                        VStack(spacing: 16) {
                            // Date picker
                            DatePicker("Date", selection: $date, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .accentColor(.appAccent)
                                .foregroundColor(.appTextPrimary)
                            
                            // Time toggle
                            Toggle("Include time", isOn: $hasTime)
                                .foregroundColor(.appTextPrimary)
                            
                            if hasTime {
                                DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(.compact)
                                    .accentColor(.appAccent)
                                    .foregroundColor(.appTextPrimary)
                            }
                            
                            // Place name
                            CustomTextField(title: "Location", text: $placeName, placeholder: "e.g., North Lake")
                            
                            // Trip type
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Trip Type")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.appTextSecondary)
                                
                                HStack(spacing: 12) {
                                    ForEach(TripType.allCases, id: \.self) { type in
                                        SelectionChip(
                                            title: type.rawValue,
                                            icon: type.icon,
                                            isSelected: tripType == type,
                                            action: { tripType = type }
                                        )
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.appCard)
                        )
                        
                        // Weather section
                        SectionHeader(title: "Weather Conditions")
                        
                        VStack(spacing: 16) {
                            CustomTextField(title: "Temperature (°C)", text: $temperature, placeholder: "e.g., -5", keyboardType: .numbersAndPunctuation)
                            
                            CustomTextField(title: "Pressure (hPa) - Optional", text: $pressure, placeholder: "e.g., 1013", keyboardType: .numberPad)
                            
                            // Wind level
                            ChipSelector(title: "Wind", options: WindLevel.allCases, selection: $windLevel)
                            
                            // Cloud cover
                            ChipSelector(title: "Cloud Cover", options: CloudCover.allCases, selection: $cloudCover)
                            
                            // Precipitation
                            ChipSelector(title: "Precipitation", options: Precipitation.allCases, selection: $precipitation)
                            
                            // Ice condition
                            ChipSelector(title: "Ice Condition", options: IceCondition.allCases, selection: $iceCondition)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.appCard)
                        )
                        
                        // Results section
                        SectionHeader(title: "Results")
                        
                        VStack(spacing: 16) {
                            // Bite score
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Bite Score")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.appTextSecondary)
                                
                                HStack(spacing: 8) {
                                    ForEach(1...5, id: \.self) { score in
                                        Button(action: {
                                            withAnimation(.spring(response: 0.3)) {
                                                biteScore = score
                                            }
                                            let impact = UIImpactFeedbackGenerator(style: .light)
                                            impact.impactOccurred()
                                        }) {
                                            Image(systemName: score <= biteScore ? "star.fill" : "star")
                                                .font(.system(size: 28))
                                                .foregroundColor(score <= biteScore ? Color.orange : .appTextSecondary.opacity(0.3))
                                        }
                                        .scaleEffect(score == biteScore ? 1.15 : 1.0)
                                    }
                                }
                            }
                            
                            CustomTextField(title: "Catch Count", text: $catchCount, placeholder: "0", keyboardType: .numberPad)
                            
                            // Notes
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Notes")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.appTextSecondary)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        showTemplates = true
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "text.badge.plus")
                                                .font(.system(size: 12))
                                            Text("Template")
                                                .font(.system(size: 12, weight: .medium))
                                        }
                                        .foregroundColor(.appAccent)
                                    }
                                }
                                
                                TextEditor(text: $notes)
                                    .font(.system(size: 15))
                                    .foregroundColor(.appTextPrimary)
                                    .frame(height: 100)
                                    .padding(8)
                                    .background(Color.appBackground)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.appCard)
                        )
                        
                        Spacer(minLength: 100)
                    }
                    .padding(20)
                }
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
                    Text(trip == nil ? "Add Log" : "Edit Log")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveLog()
                    }
                    .foregroundColor(.appAccent)
                    .disabled(!isValid)
                }
            }
        }
        .sheet(isPresented: $showTemplates) {
            TemplateSelectionView(selectedTemplate: { template in
                notes = template.content
            })
        }
    }
    
    private var isValid: Bool {
        !placeName.isEmpty && !temperature.isEmpty
    }
    
    private func saveLog() {
        guard let temp = Double(temperature) else { return }
        let pressureValue = Double(pressure)
        let catchValue = Int(catchCount) ?? 0
        
        let newTrip = TripLog(
            id: trip?.id ?? UUID(),
            date: date,
            time: hasTime ? time : nil,
            placeName: placeName,
            tripType: tripType,
            temperature: temp,
            pressure: pressureValue,
            windLevel: windLevel,
            cloudCover: cloudCover,
            precipitation: precipitation,
            iceCondition: iceCondition,
            biteScore: biteScore,
            catchCount: catchValue,
            notes: notes
        )
        
        if trip == nil {
            dataManager.addTrip(newTrip)
        } else {
            dataManager.updateTrip(newTrip)
        }
        
        let impact = UINotificationFeedbackGenerator()
        impact.notificationOccurred(.success)
        
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.appTextPrimary)
            
            Spacer()
        }
    }
}

// MARK: - Custom Text Field
struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.appTextSecondary)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .foregroundColor(.appTextPrimary)
                .keyboardType(keyboardType)
                .padding(12)
                .background(Color.appBackground)
                .cornerRadius(8)
        }
    }
}

// MARK: - Selection Chip
struct SelectionChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : .appTextSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.appAccent : Color.appBackground)
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

struct ChipSelector<T: RawRepresentable & CaseIterable & Hashable>: View where T.RawValue == String {
    let title: String
    let options: [T]
    @Binding var selection: T
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.appTextSecondary)
            
            FlowLayout(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            selection = option
                        }
                    }) {
                        Text(option.rawValue)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(selection == option ? .white : .appTextSecondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selection == option ? Color.appAccent : Color.appBackground)
                            )
                    }
                    .scaleEffect(selection == option ? 1.05 : 1.0)
                }
            }
        }
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

struct AddEditLogView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditLogView(trip: nil)
            .environmentObject(DataManager.shared)
    }
}
