import SwiftUI

struct EnemyExplosionView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.purple)
                .frame(width: isAnimating ? 200 : 50, height: isAnimating ? 200 : 50)
                .opacity(isAnimating ? 0 : 1)
        }

        .onAppear() {
            withAnimation(Animation.easeInOut(duration: 2.0)) {
                isAnimating = true
            }
        }
    }
}
