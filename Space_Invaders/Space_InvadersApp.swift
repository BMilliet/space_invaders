import SwiftUI

@main
struct Space_InvadersApp: App {
    var body: some Scene {
        WindowGroup {
            GameView()
        }
    }
}

let GAME_SCALE = 32

let BLOCK_SIZE: CGFloat  = 20
let CANVAS_SIZE: CGFloat = CGFloat(GAME_SCALE) * BLOCK_SIZE  //640

import Swift2D

struct GameView: View {

    @ObservedObject private var viewModel = GameViewModel()

    var body: some View {
        VStack {

            viewModel.board

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
        .onAppear {
            viewModel.startGame()
        }
    }

    func render() {

    }
}

final class GameViewModel: ObservableObject {

    let controller: CanvasController

    @Published var board: AnyView = AnyView(ZStack{Rectangle()})

    private var timer: Timer?


    init() {
        controller = CanvasController(columns: GAME_SCALE, rows: GAME_SCALE,
                                      collisions: [.leftWall, .rightWall, .floor, .anotherShape])
    }


    func startGame() {
        addTank()
        addEnemies()

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.moveParticles()
        }
    }


    func move(_ move: Move, id: String) {
        try? controller.move(move, id: id)
        render()
    }


    func shoot() {
        let tank = controller.shape("tank")!
        let shape = Shape(id: "bullet_\(UUID())", matrix: [[3]], column: tank.column + 1, row: GAME_SCALE - 3)
        try? controller.addToCanvas(shape: shape)

        render()
    }


    func render() {
        removeOutOfBounds()
        generateBoard()
    }


    private func addTank() {
        let tank = Shape(id: "tank", matrix: [[0,1,0],[1,1,1]], column: GAME_SCALE/2, row: GAME_SCALE - 2)
        try? controller.addToCanvas(shape: tank)
    }


    private func addEnemies() {
        let enemy = Shape(id: "enemy_\(UUID())", matrix: [[2]], column: GAME_SCALE / 2, row: 0)
        try? controller.addToCanvas(shape: enemy)
    }


    private func generateBoard() {

        let matrix = controller.canvas

        board = AnyView(
            ZStack {
                Rectangle().frame(width: CANVAS_SIZE, height: CANVAS_SIZE)
                    .background(.gray)


                ForEach(0..<matrix.count, id: \.self) { row in
                    ForEach(0..<matrix[row].count, id: \.self) { column in

                        let point = matrix[row][column]

                        if point == 1 {
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: BLOCK_SIZE, height: BLOCK_SIZE)
                                .position(
                                    x: CGFloat(column) * BLOCK_SIZE,
                                    y: CGFloat(row) * BLOCK_SIZE
                                )
                                .offset(
                                    x: 83.5,
                                    y: 10
                                )


                        } else if point == 2 {

                            Text("👾")
                                .font(Font.system(size: 32))
                                .position(
                                    x: CGFloat(column) * BLOCK_SIZE,
                                    y: CGFloat(row) * BLOCK_SIZE
                                )
                                .offset(
                                    x: 83.5,
                                    y: 10
                                )


                        } else if point == 3 {

                            Circle()
                                .fill(Color.red)
                                .frame(width: BLOCK_SIZE - 10, height: BLOCK_SIZE - 10)
                                .position(
                                    x: CGFloat(column) * BLOCK_SIZE,
                                    y: CGFloat(row) * BLOCK_SIZE
                                )
                                .offset(
                                    x: 83.5,
                                    y: 10
                                )
                        }
                    }
                }
            }
        )
    }


    private func moveParticles() {
        controller.register.keys
            .filter { $0.hasPrefix("bullet_") }
            .compactMap { controller.register[$0] }
            .forEach {
                try? controller.move(.up, id: $0.id)
            }

        render()
    }


    private func moveEnemies() {
        controller.register.keys
            .filter { $0.hasPrefix("enemy_") }
            .compactMap { controller.register[$0] }
            .forEach {
                //try! controller.move(.right, id: $0.id)
            }

        render()
    }


    private func removeOutOfBounds() {
        var toRemove = [String]()

        controller.register.keys
            .compactMap { controller.register[$0] }
            .forEach {
                let row = $0.row
                let col = $0.column

                if row < 0 || row > GAME_SCALE || col < 0 || col > GAME_SCALE {
                    toRemove.append($0.id)
                }
            }

        toRemove.forEach {
            print("removing \($0)")
            controller.remove(id: $0)
        }
    }


    deinit {
        timer?.invalidate()
        timer = nil
    }
}
