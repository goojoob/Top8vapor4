import Fluent

struct UpdateTournament: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("tournament")
            .field("num_rounds", .int8, .required)
            .field("current_round", .int8, .required)
            .field("started", .bool, .required)
            .update()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("tournament").delete()
    }
}