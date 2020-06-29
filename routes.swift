import Vapor
import Fluent

func routes(_ app: Application) throws {

    try app.register(collection: CommunityController())
    try app.register(collection: PlayerController())
    try app.register(collection: TournamentController())

}