import SwiftUI

let tankWidth = 30.0
let tankHeight = 30.0

struct ContentView: View {

    @State var ye = false

    @State var animate = false
    @State var moveHorizontal = 0.0
    @State var moveHorizontalOld = 0.0

    var body: some View {
        VStack {

            Rectangle()
                .foregroundColor(.gray)
                .frame(width: 600, height: 600)
                .overlay(
                    Rectangle()
                        .foregroundColor(.blue)
                        .frame(width: tankWidth, height: tankHeight)
                        .position(x: moveHorizontal, y: 600 - (tankHeight / 2))
                        .animation(.linear(duration: 0.2), value: moveHorizontal)
                )


            HStack {

                Button("<") {
                    move(-10)
                }
                .keyboardShortcut(KeyEquivalent.leftArrow, modifiers: [])
                .padding()

                Button(">") {
                    move(10)
                }
                .keyboardShortcut(KeyEquivalent.rightArrow, modifiers: [])

            }
        }
    }

    func move(_ value: CGFloat) {
        let newValue = moveHorizontal + value

        print("move: \(newValue)")

        if newValue < 585 || newValue > 0 {
            moveHorizontal = newValue
        } else {
            print("invalid move")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
