import Fluent

struct CreateTournament: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("tournaments")
            .id()
            .field("name", .string, .required)
            .field("num_rounds", .int8, .required)
            .field("current_round", .int8, .required)
            .field("started", .bool, .required)            
            .field("community_id", .uuid, .required, .references("communities","id"))
            .field("started_at", .datetime)
            .field("finished_at", .datetime)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("tournaments").delete()
    }
}