import Fluent

struct CreateTournament: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("tournament")
            .id()
            .field("name", .string, .required)
            .field("community_id", .uuid, .references("community","id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("tournament").delete()
    }
}