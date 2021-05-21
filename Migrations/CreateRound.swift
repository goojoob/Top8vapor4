import Fluent

struct CreateRound: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("rounds")
            .id()
            .field("num_round", .int8, .required)
            .field("tournament_id", .uuid, .required, .references("tournament","id"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("rounds").delete()
    }
}