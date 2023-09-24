import Foundation
import Swift2D

final class GameModel {
    
    private let swift2d: Swift2D = Swift2D(columns: GAME_SCALE, rows: GAME_SCALE)
    private var lives = 3
    private var score = 0
    private var gameOver = false
    private var effects = [String: EffectModel]()

    private var enemyLineMove = 4
    private var enemyLineMoveDirection = Move.right

    private var bonusShipMoveDirection = Move.right

    init() {}


    func getLives()   -> Int           { return lives }
    func getScore()   -> Int           { return score }
    func isGameOver() -> Bool          { return gameOver }
    func getCanvas()  -> [[Int]]       { return swift2d.canvas }
    func getEffect()  -> [EffectModel] { return Array(effects.values) }


    func reset() {
        let keys = swift2d.getShapes.keys
        keys.forEach { swift2d.remove(id: $0) }

        addTank()
        addEnemies()
        addBases()
        addBonusShip()

        lives = 3
        score = 0
        effects.removeAll()
    }


    func move(_ move: MoveDirection, id: String) {
        switch move {
        case .left:
            try? swift2d.move(.left, id: id)
        case .right:
            try? swift2d.move(.right, id: id)
        }
    }


    func moveAll(_ move: Move, _ prefix: String) {
        swift2d.getShapes
            .filter { $0.key.hasPrefix(prefix) }
            .forEach {
                let shape = $0.value
                try? swift2d.move(move, id: shape.id)
            }
    }


    func playerShoots() {
        let tank = swift2d.shape("tank")!
        let shape = Inventory.getBullet1(col: (tank.column + 2), row: (GAME_SCALE - 5))
        try? swift2d.addToCanvas(shape: shape)
    }


    func moveBonusShip() {
        guard let ship = swift2d.getShapes.filter({ $0.key.hasPrefix("bonusShip_") }).first?.value else {
            return
        }

        if ship.column < 0 {
            bonusShipMoveDirection = .right
        } else if ship.column > swift2d.canvas.first!.count + 10 {
            bonusShipMoveDirection = .left
        }

        try? swift2d.move(bonusShipMoveDirection, id: ship.id)
    }


    func removeOutOfBoundsBullets() {
        var toRemove = [String]()

        swift2d.getShapes.filter { $0.key.hasPrefix("bullet_") }.values
            .forEach {
                let row = $0.row
                let col = $0.column

                if row < 0 || row > GAME_SCALE || col < 0 || col > GAME_SCALE {
                    toRemove.append($0.id)
                }
            }

        toRemove.forEach {
            swift2d.remove(id: $0)
        }
    }


    func handleBulletHit() {
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

            let col = collidedShape.column
            let row = collidedShape.row


            switch collidedShape.id {

            case let e where e.contains("bullet_"):
                swift2d.remove(id: collidedShape.id)

            case let e where e.contains("enemy_"):
                swift2d.remove(id: collidedShape.id)
                effects["\(col)_\(row)"] = EffectModel(col: col, row: row, type: .enemyExplosion)
                score += 50

            case let e where e.contains("bonusShip_"):
                swift2d.remove(id: collidedShape.id)
                effects["\(col)_\(row)"] = EffectModel(col: col, row: row, type: .bonusShipExplosion)
                score += 250


            case let e where e.contains("tank"):
                effects["\(col)_\(row)"] = EffectModel(col: col, row: row, type: .tankExplosion)

                lives -= 1
                if lives <= 0 { gameOver = true }
                swift2d.remove(id: collidedShape.id)
                addTank()

            case let e where e.contains("base_"):
                swift2d.remove(id: collidedShape.id)

                let relative = collidedShape.lastRelativeCollisionPoint!
                let collision = collidedShape.lastCollidedPoint!
                var matrix = collidedShape.matrix
                matrix[relative.row][relative.column] = 0
                collidedShape.matrix = matrix

                effects["\(collision.column)_\(collision.row)"] =
                EffectModel(col: collision.column, row: collision.row, type: .baseHit)

                try! swift2d.addToCanvas(shape: collidedShape)

            default:
                print("")
            }

            swift2d.remove(id: $0.id)
        }
    }


    func moveEnemies() {
        let enemies = swift2d.getShapes.filter { $0.key.hasPrefix("enemy_line_\(enemyLineMove)") }.sorted { $0.key < $1.key }
        var nextDirection = enemyLineMoveDirection

        if enemies.count == 1 {
            let first = enemies.first?.value

            if first?.lastCollision == .leftWall {
                enemyLineMoveDirection = .down
                nextDirection = .right
            }

            if first?.lastCollision == .rightWall {
                enemyLineMoveDirection = .down
                nextDirection = .left
            }
        } else {
            let first = enemies.first?.value
            let last = enemies.last?.value

            if first?.lastCollision == .leftWall {
                enemyLineMoveDirection = .down
                nextDirection = .right
            }

            if last?.lastCollision == .rightWall {
                enemyLineMoveDirection = .down
                nextDirection = .left
            }
        }

        enemies.forEach {
            let shape = $0.value
            try? swift2d.move(enemyLineMoveDirection, id: shape.id)
        }

        enemyLineMoveDirection = nextDirection

        enemyLineMove -= 1

        if enemyLineMove < 0 {
            enemyLineMove = 4
        }
    }


    func enemyShoot() {

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
            let enemyShape = enemyToShoot.value
            let shape = Inventory.getBullet2(col: (enemyShape.column + 1), row: (enemyShape.row + 2))
            try? swift2d.addToCanvas(shape: shape)
        }
    }


    private func addTank() {
        try! swift2d.addToCanvas(shape: Inventory.getTank())
    }


    private func addEnemies() {
        Inventory.getEnemies().forEach {
            try! swift2d.addToCanvas(shape: $0)
        }
    }

    private func addBases() {
        Inventory.getBases().forEach {
            try! swift2d.addToCanvas(shape: $0)
        }
    }

    private func addBonusShip() {
        try! swift2d.addToCanvas(shape: Inventory.getBonusShip())
    }
}


enum MoveDirection {
    case right, left
}
