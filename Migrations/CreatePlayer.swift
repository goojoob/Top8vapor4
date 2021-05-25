import Fluent

struct CreatePlayer: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("players")
            .id()
            .field("name", .string, .required)
            .field("community_id", .uuid, .required, .references("communities","id"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("players").delete()
    }
}