import Fluent
import Vapor

struct RoundController: RouteCollection {
	
	func boot (routes: RoutesBuilder) throws {
		let roundRoutes = routes.grouped("api", "round")
	
		roundRoutes.post("create", use: createRound)
	}

	func createRound(req: Request) throws -> EventLoopFuture<Round> {
		req.logger.info("Validating Round JSON")
		try Round.validate(content: req)
		
		let round: Round = try req.content.decode(Round.self)

        return try TournamentController
            .getTournament(req: req, tournamentId: round.$tournament.id)
            .flatMap { tournament in
                req.logger.info("Creating Round \(round.numRound) in Tournament")
                return round.create(on: req.db)
                    .map { round }
            }
	}

}