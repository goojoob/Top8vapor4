import Fluent

struct CreatePlayer: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("player")
            .id()
            .field("name", .string, .required)
            .field("community_id", .uuid, .required, .references("community","id"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("player").delete()
    }
}