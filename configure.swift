import Fluent
import FluentSQLiteDriver
import Vapor

public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    app.migrations.add(CreateCommunity())
    app.migrations.add(CreatePlayer())
    app.migrations.add(CreateTournament())
    app.migrations.add(CreatePlayerTournament())
    app.migrations.add(CreateRound())

    // register routes
    try routes(app)
}