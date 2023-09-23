import SwiftUI

struct Explosion1View: View {
    @State private var isAnimating = false
    let radius: CGFloat

    var body: some View {
        ZStack {

            Circle()
                .stroke(Color.red, lineWidth: 2)
                .frame(width: isAnimating ? radius : (radius/4), height: isAnimating ? radius : (radius/4))
                .opacity(isAnimating ? 0 : 0.5)

            Circle()
                .stroke(Color.pink, lineWidth: 4)
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

struct Explosion2View: View {
    @State private var isAnimating = false
    let radius: CGFloat

    var body: some View {
        ZStack {

            Circle()
                .stroke(Color.red, lineWidth: 2)
                .frame(width: isAnimating ? radius : (radius/4), height: isAnimating ? radius : (radius/4))
                .opacity(isAnimating ? 0 : 0.5)

            Circle()
                .stroke(Color.pink, lineWidth: 4)
                .frame(width: isAnimating ? radius/1.8 : (radius/6), height: isAnimating ? radius/1.8 : (radius/6))
                .opacity(isAnimating ? 0 : 0.5)

            Circle()
                .stroke(Color.orange, lineWidth: 6)
                .frame(width: isAnimating ? radius/1.2 : (radius/8), height: isAnimating ? radius/1.2 : (radius/8))
                .opacity(isAnimating ? 0 : 0.5)
        }

        .onAppear() {
            withAnimation(Animation.easeInOut(duration: 2.0)) {
                isAnimating = true
            }
        }
    }
}

struct Explosion3View: View {
    @State private var isAnimating = false
    let radius: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.red)
                .frame(width: isAnimating ? radius : (radius/4), height: isAnimating ? radius : (radius/4))
                .opacity(isAnimating ? 0 : 0.8)
        }

        .onAppear() {
            withAnimation(Animation.easeInOut(duration: 2.0)) {
                isAnimating = true
            }
        }
    }
}
