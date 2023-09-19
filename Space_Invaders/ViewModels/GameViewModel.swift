import Foundation
import Swift2D
import SwiftUI

let GAME_SCALE = 80

let BLOCK_SIZE: CGFloat  = 8
let CANVAS_SIZE: CGFloat = CGFloat(GAME_SCALE) * BLOCK_SIZE

final class GameViewModel: ObservableObject {

    let swift2d: Swift2D

    @Published var board: AnyView = AnyView(ZStack{Rectangle()})

    private var bulletMovementTime: Timer?
    private var enemyMovementTime: Timer?

    private var shootCoolDown: Timer?
    private var enemyShootCoolDown: Timer?


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

        bulletMovementTime = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.moveParticles()
        }

        enemyMovementTime = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.moveEnemies()
        }

        enemyShootCoolDown = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self] _ in
            self?.enemyShoot()
        }
    }

    private func enemyShoot() {

        let enemies = swift2d.getShapes.filter { $0.key.hasPrefix("enemy_line_") }.sorted { $0.key < $1.key }
        let lastEnemy = enemies.last?.key ?? ""

        let pattern = "_id_\\d+"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(lastEnemy.startIndex..<lastEnemy.endIndex, in: lastEnemy)

        let lastLineSubString = regex.stringByReplacingMatches(
            in: lastEnemy,
            options: [],
            range: range,
            withTemplate: ""
        )

        let frontLine = enemies.filter { $0.key.contains(lastLineSubString) }

        if let enemyToShoot = frontLine.randomElement() {
            let matrix = [
                [5]
            ]
            let enemyShape = enemyToShoot.value
            let shape = Swift2DShape(id: "enemyBullet_\(UUID())", matrix: matrix, column: enemyShape.column + 1, row: enemyShape.row + 2)
            try? swift2d.addToCanvas(shape: shape)
        }
    }


    func move(_ move: Move, id: String) {
        try? swift2d.move(move, id: id)
    }


    private var coolDown = false
    func shoot() {
        if coolDown { return }

        let matrix = [
            [3],
            [3],
        ]
        let tank = swift2d.shape("tank")!
        let shape = Swift2DShape(id: "bullet_\(UUID())", matrix: matrix, column: tank.column + matrix.count, row: GAME_SCALE - 5)
        try? swift2d.addToCanvas(shape: shape)

        coolDown = true
        shootCoolDown = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.removeCoolDown()
        }
    }

    private func removeCoolDown() {
        shootCoolDown?.invalidate()
        coolDown = false
    }


    private func render() {
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
        let tank = Swift2DShape(id: "tank", matrix: matrix, column: GAME_SCALE/2, row: GAME_SCALE - matrix.count)
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
                let tank = Swift2DShape(id: "enemy_line_\(l)_id_\(i)", matrix: matrix, column: col, row: row)
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
            let tank = Swift2DShape(id: "base_\(i)", matrix: matrix, column: col, row: row)
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
                                .fill(Color.white)
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


                        } else if point == 5 {

                            Rectangle()
                                .fill(Color.cyan)
                                .frame(width: BLOCK_SIZE / 1.3, height: BLOCK_SIZE / 1.3)
                                .rotationEffect(.degrees(45))
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

        swift2d.getShapes
            .filter { $0.key.hasPrefix("enemyBullet_") }
            .forEach {
                let shape = $0.value
                try? swift2d.move(.down, id: shape.id)
            }


        render()
    }

    private var enemyLineMove = 4
    private var direction = Move.right

    private func moveEnemies() {
        let enemies = swift2d.getShapes.filter { $0.key.hasPrefix("enemy_line_\(enemyLineMove)") }.sorted { $0.key < $1.key }
        var nextDirection = direction

        if enemies.count == 1 {
            let first = enemies.first?.value

            if first?.lastCollision == .leftWall {
                direction = .down
                nextDirection = .right
            }

            if first?.lastCollision == .rightWall {
                direction = .down
                nextDirection = .left
            }
        } else {
            let first = enemies.first?.value
            let last = enemies.last?.value

            if first?.lastCollision == .leftWall {
                direction = .down
                nextDirection = .right
            }

            if last?.lastCollision == .rightWall {
                direction = .down
                nextDirection = .left
            }
        }

        enemies.forEach {
            let shape = $0.value
            try? swift2d.move(direction, id: shape.id)
        }

        direction = nextDirection

        enemyLineMove -= 1

        if enemyLineMove < 0 {
            enemyLineMove = 4
        }
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
        handleBulletHit()
    }

    private func handleBulletHit() {
        var bullets = swift2d.getShapes.filter { $0.key.hasPrefix("bullet_") }.values
            .filter { $0.lastCollision != .none }

        swift2d.getShapes.filter { $0.key.hasPrefix("enemyBullet_") }.values
            .filter { $0.lastCollision != .none }
            .forEach { bullets.append($0) }

        bullets.forEach {

            if $0.lastCollision != .anotherShape {
                swift2d.remove(id: $0.id)
                return
            }

            guard let collidedShape = swift2d.getShapes[$0.lastCollidedShape] else {
                swift2d.remove(id: $0.id)
                return
            }

            if collidedShape.id.contains("enemy_") {
                swift2d.remove(id: collidedShape.id)

            } else if collidedShape.id.contains("bullet_") {
                swift2d.remove(id: collidedShape.id)

            } else if collidedShape.id.contains("tank") {
                swift2d.remove(id: collidedShape.id)

            } else if collidedShape.id.contains("base_") {

                swift2d.remove(id: collidedShape.id)

                let relative = collidedShape.lastRelativeCollisionPoint!
                var matrix = collidedShape.matrix
                matrix[relative.row][relative.column] = 0
                collidedShape.matrix = matrix
                collidedShape.printMatrix()

                try! swift2d.addToCanvas(shape: collidedShape)
            }

            swift2d.remove(id: $0.id)
        }
    }


    deinit {
        bulletMovementTime?.invalidate()
        bulletMovementTime = nil

        enemyMovementTime?.invalidate()
        enemyMovementTime = nil
    }
}
