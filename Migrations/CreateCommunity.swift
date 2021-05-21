import Fluent

struct CreateCommunity: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("communities")
            .id()
            .field("name", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("communities").delete()
    }
}