import SwiftUI

struct LogDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    
    let trip: TripLog
    
    @State private var showEditView = false
    @State private var showDeleteAlert = false
    @State private var expandNotes = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Temperature header
                        VStack(spacing: 8) {
                            Text("\(Int(trip.temperature))°C")
                                .font(.system(size: 64, weight: .bold, design: .rounded))
                                .foregroundColor(.appAccent)
                            
                            Text(trip.placeName.isEmpty ? "Unknown Location" : trip.placeName)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.appTextPrimary)
                            
                            Text(formatDate(trip.date))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.appTextSecondary)
                        }
                        .padding(.top, 20)
                        
                        // Weather details grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            if let pressure = trip.pressure {
                                DetailCard(icon: "barometer", title: "Pressure", value: "\(Int(pressure)) hPa", color: .appAccent)
                            }
                            
                            DetailCard(icon: trip.windLevel.icon, title: "Wind", value: trip.windLevel.rawValue, color: .appSuccess)
                            
                            DetailCard(icon: trip.cloudCover.icon, title: "Cloud", value: trip.cloudCover.rawValue, color: Color.cyan)
                            
                            DetailCard(icon: trip.iceCondition.icon, title: "Ice", value: trip.iceCondition.rawValue, color: Color.blue)
                        }
                        
                        // Results section
                        VStack(spacing: 16) {
                            HStack {
                                Text("Results")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.appTextPrimary)
                                
                                Spacer()
                            }
                            
                            HStack(spacing: 20) {
                                // Bite score
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Bite Score")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.appTextSecondary)
                                    
                                    HStack(spacing: 4) {
                                        ForEach(1...5, id: \.self) { index in
                                            Image(systemName: index <= trip.biteScore ? "star.fill" : "star")
                                                .font(.system(size: 20))
                                                .foregroundColor(index <= trip.biteScore ? Color.orange : .appTextSecondary.opacity(0.3))
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                // Catch count
                                VStack(alignment: .trailing, spacing: 8) {
                                    Text("Catch Count")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.appTextSecondary)
                                    
                                    HStack(spacing: 8) {
                                        Image(systemName: "fish.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.appSuccess)
                                        
                                        Text("\(trip.catchCount)")
                                            .font(.system(size: 24, weight: .bold, design: .rounded))
                                            .foregroundColor(.appTextPrimary)
                                    }
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.appCard)
                            )
                        }
                        
                        // Notes section
                        if !trip.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Notes")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.appTextPrimary)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        withAnimation {
                                            expandNotes.toggle()
                                        }
                                    }) {
                                        Image(systemName: expandNotes ? "chevron.up" : "chevron.down")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.appAccent)
                                    }
                                }
                                
                                if expandNotes {
                                    Text(trip.notes)
                                        .font(.system(size: 15))
                                        .foregroundColor(.appTextSecondary)
                                        .lineSpacing(4)
                                        .transition(.opacity)
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.appCard)
                            )
                        }
                        
                        // Action buttons
                        HStack(spacing: 12) {
                            ActionButton(title: "Edit", icon: "pencil", color: .appAccent) {
                                showEditView = true
                            }
                            
                            ActionButton(title: "Duplicate", icon: "doc.on.doc", color: .appSuccess) {
                                dataManager.duplicateTrip(trip)
                                let impact = UINotificationFeedbackGenerator()
                                impact.notificationOccurred(.success)
                                presentationMode.wrappedValue.dismiss()
                            }
                            
                            ActionButton(title: "Delete", icon: "trash", color: .appWarning) {
                                showDeleteAlert = true
                            }
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.appTextSecondary)
                    }
                }
            }
        }
        .sheet(isPresented: $showEditView) {
            AddEditLogView(trip: trip)
        }
        .alert("Delete Log", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                dataManager.deleteTrip(trip)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this log? This action cannot be undone.")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Detail Card
struct DetailCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.appTextSecondary)
                
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appTextPrimary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appCard)
        )
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 0.95
            }
            
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.0
                }
                action()
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
            )
        }
        .scaleEffect(scale)
    }
}

struct LogDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LogDetailView(trip: TripLog())
            .environmentObject(DataManager.shared)
    }
}
