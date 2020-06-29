import Fluent

struct CreateCommunity: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("community")
            .id()
            .field("name", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("community").delete()
    }
}
