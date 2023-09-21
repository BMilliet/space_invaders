import SwiftUI

struct TankExplosionView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.red)
                .frame(width: isAnimating ? 400 : 50, height: isAnimating ? 400 : 50)
                .opacity(isAnimating ? 0 : 1)
        }

        .onAppear() {
            withAnimation(Animation.easeInOut(duration: 2.0)) {
                isAnimating = true
            }
        }
    }
}
