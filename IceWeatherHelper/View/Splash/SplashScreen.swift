import SwiftUI

struct SplashScreen: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var snowflakes: [Snowflake] = []
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.appBackground, Color.appCard],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated snowflakes
            ForEach(snowflakes) { flake in
                SnowflakeView(flake: flake)
            }
            
            VStack(spacing: 20) {
                // Icon container
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.appAccent.opacity(0.3), Color.clear],
                                center: .center,
                                startRadius: 20,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                    
                    // Icon background
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.appCard)
                        .frame(width: 120, height: 120)
                        .shadow(color: Color.appAccent.opacity(0.5), radius: 20, x: 0, y: 10)
                    
                    // Icons
                    HStack(spacing: -10) {
                        Image(systemName: "snowflake")
                            .font(.system(size: 40, weight: .light))
                            .foregroundColor(.appAccent)
                            .rotationEffect(.degrees(opacity * 360))
                        
                        Image(systemName: "thermometer.medium")
                            .font(.system(size: 40, weight: .regular))
                            .foregroundColor(.appSuccess)
                    }
                }
                .scaleEffect(scale)
                .opacity(opacity)
                
                // App name
                Text("Ice Weather Helper")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.appTextPrimary)
                    .opacity(opacity)
                
                // Tagline
                Text("Track • Analyze • Catch More")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appTextSecondary)
                    .opacity(opacity * 0.8)
            }
        }
        .onAppear {
            // Generate snowflakes
            generateSnowflakes()
            
            // Animate icon
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0.3).delay(0.2)) {
                scale = 1.0
            }
            
            withAnimation(.easeIn(duration: 0.6).delay(0.1)) {
                opacity = 1.0
            }
        }
    }
    
    private func generateSnowflakes() {
        for _ in 0..<20 {
            let flake = Snowflake(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: -100...UIScreen.main.bounds.height),
                size: CGFloat.random(in: 4...12),
                speed: Double.random(in: 2...5),
                delay: Double.random(in: 0...2)
            )
            snowflakes.append(flake)
        }
    }
}

// MARK: - Snowflake Model
struct Snowflake: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let speed: Double
    let delay: Double
}

// MARK: - Snowflake View
struct SnowflakeView: View {
    let flake: Snowflake
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 0
    
    var body: some View {
        Image(systemName: "snowflake")
            .font(.system(size: flake.size))
            .foregroundColor(.appAccent.opacity(0.6))
            .position(x: flake.x, y: flake.y + offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    Animation.linear(duration: flake.speed)
                        .repeatForever(autoreverses: false)
                        .delay(flake.delay)
                ) {
                    offset = UIScreen.main.bounds.height + 100
                }
                
                withAnimation(.easeIn(duration: 0.5).delay(flake.delay)) {
                    opacity = 1.0
                }
            }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
