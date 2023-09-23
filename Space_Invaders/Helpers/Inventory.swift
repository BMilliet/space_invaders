import Swift2D
import Foundation

enum Inventory {


    static func getBullet2(col: Int, row: Int) -> Swift2DShape {

        let matrix = [
            [5]
        ]

        return Swift2DShape(
            id: "enemyBullet_\(UUID())",
            matrix: matrix,
            column: col, row: row,
            collisions: [.anotherShape]
        )
    }


    static func getBullet1(col: Int, row: Int) -> Swift2DShape {

        let matrix = [
            [3],
            [3],
        ]

        return Swift2DShape(
            id: "bullet_\(UUID())",
            matrix: matrix,
            column: col, row: row,
            collisions: [.anotherShape]
        )
    }


    static func getTank() -> Swift2DShape {

        let matrix = [
            [0,0,1,0,0],
            [1,1,1,1,1],
            [1,1,1,1,1],
        ]

        return Swift2DShape(
            id: "tank",
            matrix: matrix,
            column: GAME_SCALE/2, row: GAME_SCALE - matrix.count,
            collisions: CollisionFactory.all()
        )
    }


    static func getEnemies() -> [Swift2DShape] {

        var enemies = [Swift2DShape]()

        let matrix = [
            [2,2,2],
            [2,2,2],
        ]

        for l in 0..<5 {
            let row = (6 * l) + 10
            for i in 0..<9 {
                let col = (matrix.first!.count + (matrix.first!.count * i) + (i * 4) )
                let enemy = Swift2DShape(
                    id: "enemy_line_\(l)_id_\(i)",
                    matrix: matrix,
                    column: col, row: row,
                    collisions: CollisionFactory.all()
                )
                enemies.append(enemy)
            }
        }

        return enemies
    }


    static func getBonusShip() -> Swift2DShape {

        let matrix = [
            [6,6,6,6,6],
            [6,6,6,6,6],
        ]

        return Swift2DShape(
            id: "bonusShip_\(UUID())",
            matrix: matrix,
            column: -20, row: 10,
            collisions: [.anotherShape]
        )
    }


    static func getBases() -> [Swift2DShape] {

        var bases = [Swift2DShape]()

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
            let base = Swift2DShape(
                id: "base_\(i)",
                matrix: matrix,
                column: col, row: row,
                collisions: [.anotherShape]
            )
            bases.append(base)
        }

        return bases
    }
}
