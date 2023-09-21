struct EffectModel: Hashable {
    let col: Int
    let row: Int
    let type: EffectType
}

enum EffectType {
    case enemyExplosion, tankExplosion
}
