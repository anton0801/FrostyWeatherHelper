import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            Group {
                switch selectedTab {
                case 0:
                    DashboardView()
                        .transition(.opacity)
                case 1:
                    LogsListView()
                        .transition(.opacity)
                case 2:
                    CompareView()
                        .transition(.opacity)
                case 3:
                    SettingsView()
                        .transition(.opacity)
                default:
                    DashboardView()
                }
            }
            
            // Custom tab bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .background(Color.appBackground.ignoresSafeArea())
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @State private var tappedTab: Int?
    
    private let tabs: [(icon: String, title: String)] = [
        ("chart.line.uptrend.xyaxis", "Dashboard"),
        ("list.bullet.clipboard", "Logs"),
        ("chart.bar.xaxis", "Compare"),
        ("gearshape.fill", "Settings")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                TabBarItem(
                    icon: tabs[index].icon,
                    title: tabs[index].title,
                    isSelected: selectedTab == index,
                    isTapped: tappedTab == index
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                    
                    // Haptic feedback
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    
                    // Tap animation
                    tappedTab = index
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        tappedTab = nil
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.appCard)
                .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: -5)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }
}

struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let isTapped: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .appAccent : .appTextSecondary)
                .scaleEffect(isTapped ? 0.85 : 1.0)
            
            Text(title)
                .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .appAccent : .appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.appAccent.opacity(0.15) : Color.clear)
        )
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(DataManager.shared)
    }
}
