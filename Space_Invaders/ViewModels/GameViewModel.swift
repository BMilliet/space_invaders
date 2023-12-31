import Foundation
import SwiftUI

let GAME_SCALE = 80

let BLOCK_SIZE: CGFloat  = 8
let CANVAS_SIZE: CGFloat = CGFloat(GAME_SCALE) * BLOCK_SIZE

final class GameViewModel: ObservableObject {

    private let gameModel = GameModel()

    @Published var board: AnyView = AnyView(Rectangle().fill(Color.clear))
    @Published var boardEffect: AnyView = AnyView(Rectangle().fill(Color.clear))
    @Published var boardOverlay: AnyView = AnyView(Rectangle().fill(Color.clear))

    private var renderTime: Timer?
    private var shootCoolDown: Timer?
    private var bonusShipMove: Timer?
    private var enemyMovementTime: Timer?
    private var enemyShootCoolDown: Timer?

    private var playerShootCoolDown = false

    init() {
        generateMenu()
    }


    func move(_ move: MoveDirection, id: String) {
        gameModel.move(move, id: id)
    }


    func shoot() {
        if playerShootCoolDown { return }
        gameModel.playerShoots()
        playerShootCoolDown = true
        shootCoolDown = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.shootCoolDown?.invalidate()
            self?.playerShootCoolDown = false
        }
    }


    private func startGame() {
        gameModel.reset()

        boardOverlay = AnyView(Rectangle().fill(Color.clear))
        boardEffect = AnyView(Rectangle().fill(Color.clear))

        /*
         renderTime have the most impact on CPU usage.
         Keep in mind lowering the timeInterval makes the game faster and raises the CPU usage.
         */
        renderTime = Timer.scheduledTimer(withTimeInterval: 0.06, repeats: true) { [weak self] _ in
            self?.moveParticles()
        }

        enemyMovementTime = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.gameModel.moveEnemies()
        }

        enemyShootCoolDown = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self] _ in
            self?.gameModel.enemyShoot()
        }

        bonusShipMove = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.gameModel.moveBonusShip()
        }
    }


    private func render() {
        checkGameStatus()
        gameModel.removeOutOfBoundsBullets()
        gameModel.handleBulletHit()
        generateBoardEffect()
        generateBoard()
        ganerateStatusBoard()
    }


    private func  checkGameStatus() {
        if gameModel.isGameOver() { startGame() }
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


    private func ganerateStatusBoard() {
        boardOverlay = AnyView(
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: CANVAS_SIZE, height: CANVAS_SIZE)

                Text("score: \(gameModel.getScore())")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .position(
                        x: CANVAS_SIZE/2,
                        y: 32
                    )

                Text("lives: \(gameModel.getLives())")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .position(
                        x: CANVAS_SIZE/1.1,
                        y: 32
                    )
            })
    }


    private func generateBoardEffect() {

        let offset = BLOCK_SIZE / 2
        let _effects = gameModel.getEffect()

        boardEffect = AnyView(
            ZStack(alignment: .topLeading) {

                ForEach(_effects, id: \.self) { effect in
                    switch effect.type {

                    case .enemyExplosion:

                        Explosion1View(radius: 160)
                            .position(
                                x: CGFloat(effect.col) * BLOCK_SIZE,
                                y: CGFloat(effect.row) * BLOCK_SIZE
                            )
                            .offset(
                                x: offset,
                                y: offset
                            )

                    case .tankExplosion:

                        Explosion2View(radius: 600)
                            .position(
                                x: CGFloat(effect.col) * BLOCK_SIZE,
                                y: CGFloat(effect.row) * BLOCK_SIZE
                            )
                            .offset(
                                x: offset,
                                y: offset
                            )

                    case .baseHit:

                        Explosion3View(radius: 60)
                            .position(
                                x: CGFloat(effect.col) * BLOCK_SIZE,
                                y: CGFloat(effect.row) * BLOCK_SIZE
                            )
                            .offset(
                                x: offset,
                                y: offset
                            )

                    case .bonusShipExplosion:

                        Explosion4View(radius: 300)
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

                        case 6:

                            Rectangle()
                                .fill(Color.pink)
                                .frame(width: BLOCK_SIZE, height: BLOCK_SIZE)
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
