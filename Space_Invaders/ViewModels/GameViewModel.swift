import Foundation
import Swift2D
import SwiftUI

let GAME_SCALE = 80

let BLOCK_SIZE: CGFloat  = 8
let CANVAS_SIZE: CGFloat = CGFloat(GAME_SCALE) * BLOCK_SIZE

final class GameViewModel: ObservableObject {

    private let gameModel = GameModel()

    @Published var board: AnyView = AnyView(Rectangle().fill(Color.clear))
    @Published var boardOverlay: AnyView = AnyView(Rectangle().fill(Color.clear))
    @Published var boardEffect: AnyView = AnyView(Rectangle().fill(Color.clear))

    private var renderTime: Timer?
    private var shootCoolDown: Timer?
    private var enemyMovementTime: Timer?
    private var enemyShootCoolDown: Timer?

    private var playerShootCoolDown = false

    init() {
        generateMenu()
    }


    func move(_ move: Move, id: String) {
        gameModel.move(move, id: id)
    }


    func shoot() {
        if playerShootCoolDown { return }

        gameModel.playerShoots()

        playerShootCoolDown = true
        shootCoolDown = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.removeCoolDown()
        }
    }


    private func startGame() {
        gameModel.reset()

        boardOverlay = AnyView(Rectangle().fill(Color.clear))

        renderTime = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.moveParticles()
        }

        enemyMovementTime = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.gameModel.moveEnemies()
        }

        enemyShootCoolDown = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self] _ in
            self?.gameModel.enemyShoot()
        }
    }


    private func removeCoolDown() {
        shootCoolDown?.invalidate()
        playerShootCoolDown = false
    }


    private func render() {
        checkGameStatus()
        gameModel.removeOutOfBounds()
        gameModel.handleBulletHit()
        generateBoardEffect()
        generateBoard()
    }


    private func  checkGameStatus() {
        if gameModel.isGameOver() { startGame() }
        // check score
    }


    private func moveParticles() {
        gameModel.moveAll(.up, "bullet_")
        gameModel.moveAll(.down, "enemyBullet_")
        render()
    }


    private func gameOver() {
        renderTime?.invalidate()
        renderTime = nil
        enemyMovementTime?.invalidate()
        enemyMovementTime = nil
        enemyShootCoolDown?.invalidate()
        enemyShootCoolDown = nil
        shootCoolDown?.invalidate()
        shootCoolDown = nil

        generateMenu()
    }


    private func generateMenu() {
        boardOverlay = AnyView(
            ZStack(alignment: .center) {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: CANVAS_SIZE / 2, height: CANVAS_SIZE / 2)

                VStack {
                    Spacer()
                    Button("new game") {
                        self.startGame()
                    }
                    .keyboardShortcut(KeyEquivalent.return, modifiers: [])
                    .frame(width: CANVAS_SIZE / 2, height: CANVAS_SIZE / 4)
                    .padding()
                }
            })
    }


    private func generateBoardEffect() {

        let offset = BLOCK_SIZE / 2
        let _effects = gameModel.getEffect()

        boardOverlay = AnyView(
            ZStack(alignment: .topLeading) {

                ForEach(_effects, id: \.self) { effect in
                    switch effect.type {

                    case .enemyExplosion:

                        ExplosionView(radius: 160)
                            .position(
                                x: CGFloat(effect.col) * BLOCK_SIZE,
                                y: CGFloat(effect.row) * BLOCK_SIZE
                            )
                            .offset(
                                x: offset,
                                y: offset
                            )

                    case .tankExplosion:

                        ExplosionView(radius: 600)
                            .position(
                                x: CGFloat(effect.col) * BLOCK_SIZE,
                                y: CGFloat(effect.row) * BLOCK_SIZE
                            )
                            .offset(
                                x: offset,
                                y: offset
                            )

                    case .baseHit:

                        ExplosionView(radius: 44)
                            .position(
                                x: CGFloat(effect.col) * BLOCK_SIZE,
                                y: CGFloat(effect.row) * BLOCK_SIZE
                            )
                            .offset(
                                x: offset,
                                y: offset
                            )
                    }
                }
            }
        )
    }


    private func generateBoard() {

        let matrix = gameModel.getCanvas()
        let offSet = BLOCK_SIZE / 2

        board = AnyView(
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(Color.black)
                    .frame(width: CANVAS_SIZE, height: CANVAS_SIZE)


                ForEach(0..<matrix.count, id: \.self) { row in
                    ForEach(0..<matrix[row].count, id: \.self) { column in

                        switch matrix[row][column] {
                        case 1:

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


                        case 2:

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


                        case 3:

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


                        case 4:

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


                        case 5:

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

                        default:
                            EmptyView()

                        }
                    }
                }
            }
        )
    }


    deinit {
        gameOver()
    }
}
