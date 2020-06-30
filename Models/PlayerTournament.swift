import Fluent
import Vapor

final class PlayerTournament: Model {
    static let schema = "player+tournament"

    @ID(key: .id)
	var id: UUID?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Parent(key: "player_id")
	var player: Player

    @Parent(key: "tournament_id")
	var tournament: Tournament

    init() { }

    init(id: UUID? = nil, player: Player, tournament: Tournament) throws {
        self.id = id
        self.$player.id = try player.requireID()
        self.$tournament.id = try tournament.requireID()
    }

}


struct ParamPlayerTournament: Content {
    let tournamentId: UUID
    let playerId: UUID
}