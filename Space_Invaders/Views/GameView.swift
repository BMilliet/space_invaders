import Swift2D
import SwiftUI

struct GameView: View {

    @ObservedObject private var viewModel = GameViewModel()

    var body: some View {
        VStack {

            ZStack {
                viewModel.board
                viewModel.boardEffect
                viewModel.boardOverlay
            }

            HStack {

                Button("<") {
                    viewModel.move(.left, id: "tank")
                }
                .keyboardShortcut(KeyEquivalent.leftArrow, modifiers: [])
                .padding()

                Button(">") {
                    viewModel.move(.right, id: "tank")
                }
                .keyboardShortcut(KeyEquivalent.rightArrow, modifiers: [])

            }

            Button("space") {
                viewModel.shoot()
            }
            .keyboardShortcut(KeyEquivalent.space, modifiers: [])
            .padding()
        }
    }
}

