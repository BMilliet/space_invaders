import SwiftUI

struct ExplosionView: View {
    @State private var isAnimating = false
    let radius: CGFloat

    var body: some View {
        ZStack {

            Circle()
                .stroke(Color.cyan, lineWidth: 4)
                .frame(width: isAnimating ? radius : (radius/4), height: isAnimating ? radius : (radius/4))
                .opacity(isAnimating ? 0 : 0.5)

            Circle()
                .fill(Color.white)
                .frame(width: isAnimating ? radius/1.8 : (radius/6), height: isAnimating ? radius/1.8 : (radius/6))
                .opacity(isAnimating ? 0 : 0.5)
        }

        .onAppear() {
            withAnimation(Animation.easeInOut(duration: 2.0)) {
                isAnimating = true
            }
        }
    }
}
