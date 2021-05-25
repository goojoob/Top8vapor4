import Fluent

struct CreatePlayerTournament: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("player+tournament")
            .id()
            .field("player_id", .uuid, .required, .references("players","id"))
            .field("tournament_id", .uuid, .required, .references("tournaments","id"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "player_id", "tournament_id")
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("player+tournament").delete()
    }
}