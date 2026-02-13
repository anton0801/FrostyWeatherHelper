import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @State private var dragOffset: CGFloat = 0
    
    private let pages = OnboardingPage.allPages
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.appTextSecondary)
                    .padding()
                }
                
                // Pages
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index], index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.appAccent : Color.appTextSecondary.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentPage == index ? 1.2 : 1.0)
                            .animation(.spring(), value: currentPage)
                    }
                }
                .padding(.bottom, 20)
                
                // Continue button
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation(.spring()) {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                }) {
                    Text(currentPage == pages.count - 1 ? "Get Started" : "Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [Color.appAccent, Color.appAccent.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.appAccent.opacity(0.4), radius: 15, x: 0, y: 8)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func completeOnboarding() {
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage
    let index: Int
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Animated illustration
            ZStack {
                // Background circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.appCard.opacity(0.6), Color.appCard.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 240, height: 240)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                
                // Icon animation
                page.animatedContent(isAnimating)
            }
            .frame(height: 280)
            
            // Title
            Text(page.title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.appTextPrimary)
                .multilineTextAlignment(.center)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
            
            // Description
            Text(page.description)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Onboarding Page Model
struct OnboardingPage {
    let title: String
    let description: String
    let animatedContent: (Bool) -> AnyView
    
    static let allPages: [OnboardingPage] = [
        OnboardingPage(
            title: "Log Weather Conditions",
            description: "Track temperature, pressure, wind, and ice conditions for every fishing trip",
            animatedContent: { isAnimating in
                AnyView(
                    VStack(spacing: 20) {
                        Image(systemName: "thermometer.medium")
                            .font(.system(size: 60))
                            .foregroundColor(.appAccent)
                            .offset(y: isAnimating ? 0 : 30)
                            .opacity(isAnimating ? 1 : 0)
                            .animation(.spring().delay(0.2), value: isAnimating)
                        
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.appCard)
                            .frame(width: 150, height: 80)
                            .overlay(
                                VStack(spacing: 4) {
                                    Text("-5°C")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.appSuccess)
                                    Text("Pressure: 1013 hPa")
                                        .font(.system(size: 12))
                                        .foregroundColor(.appTextSecondary)
                                }
                            )
                            .offset(y: isAnimating ? 0 : -30)
                            .opacity(isAnimating ? 1 : 0)
                            .animation(.spring().delay(0.4), value: isAnimating)
                    }
                )
            }
        ),
        
        OnboardingPage(
            title: "Add Notes & Results",
            description: "Record bite scores, catch counts, and detailed notes to remember what worked",
            animatedContent: { isAnimating in
                AnyView(
                    HStack(spacing: 15) {
                        Image(systemName: "note.text")
                            .font(.system(size: 50))
                            .foregroundColor(.appAccent)
                            .scaleEffect(isAnimating ? 1.0 : 0.5)
                            .opacity(isAnimating ? 1 : 0)
                            .animation(.spring().delay(0.2), value: isAnimating)
                        
                        Image(systemName: "fish.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.appSuccess)
                            .scaleEffect(isAnimating ? 1.0 : 0.5)
                            .opacity(isAnimating ? 1 : 0)
                            .rotationEffect(.degrees(isAnimating ? 0 : -180))
                            .animation(.spring().delay(0.4), value: isAnimating)
                    }
                )
            }
        ),
        
        OnboardingPage(
            title: "Discover Patterns",
            description: "Analyze your trips to find the best conditions for successful fishing",
            animatedContent: { isAnimating in
                AnyView(
                    HStack(spacing: 8) {
                        ForEach(0..<4) { index in
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.appAccent, Color.appSuccess],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .frame(width: 40, height: CGFloat(50 + index * 20))
                                .offset(y: isAnimating ? 0 : 100)
                                .animation(.spring().delay(Double(index) * 0.1 + 0.2), value: isAnimating)
                        }
                    }
                )
            }
        )
    ]
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(hasCompletedOnboarding: .constant(false))
    }
}
