import SwiftUI

@main
struct Space_InvadersApp: App {
    var body: some Scene {
        WindowGroup {
            GameView()
        }
    }
}

let GAME_SCALE = 80

let BLOCK_SIZE: CGFloat  = 8
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

    let swift2d: Swift2D

    @Published var board: AnyView = AnyView(ZStack{Rectangle()})

    private var timer: Timer?


    init() {
        swift2d = Swift2D(
            columns: GAME_SCALE, rows: GAME_SCALE,
            collisions: [.leftWall, .rightWall, .floor, .anotherShape]
        )
    }


    func startGame() {
        addTank()
        addEnemies()
        addBases()

        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak self] _ in
            self?.moveParticles()
        }
    }


    func move(_ move: Move, id: String) {
        try? swift2d.move(move, id: id)
        render()
    }


    func shoot() {
        let matrix = [
            [3],
            [3],
        ]
        let tank = swift2d.shape("tank")!
        let shape = Shape(id: "bullet_\(UUID())", matrix: matrix, column: tank.column + matrix.count, row: GAME_SCALE - 5)
        try? swift2d.addToCanvas(shape: shape)

        render()
    }


    func render() {
        removeOutOfBounds()
        handleCollisions()
        generateBoard()
    }


    private func addTank() {
        let matrix = [
            [0,0,1,0,0],
            [1,1,1,1,1],
            [1,1,1,1,1],
        ]
        let tank = Shape(id: "tank", matrix: matrix, column: GAME_SCALE/2, row: GAME_SCALE - matrix.count)
        try? swift2d.addToCanvas(shape: tank)
    }


    private func addEnemies() {
        let matrix = [
            [2,2,2],
            [2,2,2],
        ]

        for l in 0..<5 {
            let row = (6 * l) + 10
            for i in 0..<9 {
                let col = (matrix.first!.count + (matrix.first!.count * i) + (i * 4) )
                let tank = Shape(id: "enemy_line_\(l)_id_\(i)", matrix: matrix, column: col, row: row)
                try! swift2d.addToCanvas(shape: tank)
            }
        }
    }

    private func addBases() {
        let matrix = [
            [4,4,4,4,4,4,4],
            [4,4,4,4,4,4,4],
            [4,4,4,4,4,4,4],
            [4,4,0,0,0,4,4],
            [4,4,0,0,0,4,4],
        ]

        let row = GAME_SCALE - (matrix.count * 3)

        for i in 0..<4 {
            let col = (matrix.first!.count + (matrix.first!.count * i) + (i * 12) )
            let tank = Shape(id: "base_\(i)", matrix: matrix, column: col, row: row)
            try! swift2d.addToCanvas(shape: tank)
        }
    }


    private func generateBoard() {

        let matrix = swift2d.canvas
        let offSet = BLOCK_SIZE / 2

        board = AnyView(
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(Color.black)
                    .frame(width: CANVAS_SIZE, height: CANVAS_SIZE)


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
                                    x: offSet,
                                    y: offSet
                                )


                        } else if point == 2 {

                            Rectangle()
                                .fill(Color.purple)
                                .frame(width: BLOCK_SIZE, height: BLOCK_SIZE)
                                .position(
                                    x: CGFloat(column) * BLOCK_SIZE,
                                    y: CGFloat(row) * BLOCK_SIZE
                                )
                                .offset(
                                    x: offSet,
                                    y: offSet
                                )


                        } else if point == 3 {

                            Rectangle()
                                .fill(Color.red)
                                .frame(width: BLOCK_SIZE / 2, height: BLOCK_SIZE / 2)
                                .position(
                                    x: CGFloat(column) * BLOCK_SIZE,
                                    y: CGFloat(row) * BLOCK_SIZE
                                )
                                .offset(
                                    x: offSet,
                                    y: offSet
                                )


                        } else if point == 4 {

                            Rectangle()
                                .fill(Color.green)
                                .frame(width: BLOCK_SIZE, height: BLOCK_SIZE)
                                .position(
                                    x: CGFloat(column) * BLOCK_SIZE,
                                    y: CGFloat(row) * BLOCK_SIZE
                                )
                                .offset(
                                    x: offSet,
                                    y: offSet
                                )
                        }
                    }
                }
            }
        )
    }


    private func moveParticles() {
        swift2d.getShapes
            .filter { $0.key.hasPrefix("bullet_") }
            .forEach {
                let shape = $0.value
                try? swift2d.move(.up, id: shape.id)
            }

        render()
    }


    private func moveEnemies() {
        swift2d.getShapes
            .filter { $0.key.hasPrefix("enemy_") }
            .forEach {
                let shape = $0.value
              //  try? swift2d.move(.up, id: shape.id)
            }

        render()
    }


    private func removeOutOfBounds() {
        var toRemove = [String]()

        swift2d.getShapes.values
            .forEach {
                let row = $0.row
                let col = $0.column

                if row < 0 || row > GAME_SCALE || col < 0 || col > GAME_SCALE {
                    toRemove.append($0.id)
                }
            }

        toRemove.forEach {
            print("removing \($0)")
            swift2d.remove(id: $0)
        }
    }

    private func handleCollisions() {

        let bullets = swift2d.getShapes.filter { $0.key.hasPrefix("bullet_") }.values.filter { !$0.lastCollidedShape.isEmpty }

        bullets.forEach {
            let collidedShape = swift2d.getShapes[$0.lastCollidedShape]!

            if collidedShape.id.contains("enemy_") {
                print("hit enemy at \(collidedShape.lastCollidedPoint)")
                swift2d.remove(id: collidedShape.id)

            } else if collidedShape.id.contains("bullet_") {
                print("hit bullet at \(collidedShape.lastCollidedPoint)")
                swift2d.remove(id: collidedShape.id)

            } else if collidedShape.id.contains("base_") {

                swift2d.remove(id: collidedShape.id)

                let relative = collidedShape.lastRelativeCollisionPoint!
                var matrix = collidedShape.matrix //[relative.column][relative.row]
                matrix[relative.row][relative.column] = 0
                collidedShape.matrix = matrix
                collidedShape.printMatrix()

                try! swift2d.addToCanvas(shape: collidedShape)

                print("hit base at \(collidedShape.lastCollidedPoint), relative collision point \(collidedShape.lastRelativeCollisionPoint)")
            }

            swift2d.remove(id: $0.id)
        }
    }


    deinit {
        timer?.invalidate()
        timer = nil
    }
}
