import Fluent
import Vapor

struct TournamentController: RouteCollection {
	
	func boot (routes: RoutesBuilder) throws {
		let tournamentRoutes = routes.grouped("api", "tournament")

		tournamentRoutes.get("get", ":paramID", use: getTournament)
		tournamentRoutes.get("getAll", use: getAllTournaments)
		tournamentRoutes.get("getAllWith", use: getAllTournamentsWith)

		tournamentRoutes.post("create", use: createTournament)
	}


    func getTournament(req: Request) throws -> EventLoopFuture<Tournament> {
		guard let paramID = req.parameters.get("paramID", as: UUID.self) else {
        	throw Abort(.badRequest)
    	}

		return Tournament.query(on: req.db)
			.filter(\.$id == paramID)
			.first()
			.unwrap(or: Top8Error.tournamentNotFound)
	}

	func getAllTournaments(req: Request) throws -> EventLoopFuture<[Tournament]> {
		return Tournament.query(on: req.db)
			.all()
	}

	func getAllTournamentsWith(req: Request) throws -> EventLoopFuture<[Tournament]> {
		return Tournament.query(on: req.db)
			.with(\.$community)
			.sort(\.$name)
			.all()
	}



	func createTournament(req: Request) throws -> EventLoopFuture<Tournament> {
		req.logger.info("Validating Tournament JSON")
		try Tournament.validate(req)
		
		let tournament: Tournament = try req.content.decode(Tournament.self)
		tournament.name = tournament.name.uppercased()

		return try existsTournamentInCommunity(req: req, tourn: tournament).flatMap { existsTourn in

			if existsTourn {
				return req.eventLoop.makeFailedFuture(Top8Error.tournamentExistsCommunity(tournament.name))
			} else {
				req.logger.info("Creating Tournament \(tournament.name) in Database")
				return tournament.create(on: req.db)
					.map { tournament }
			}

		}
	}

    func existsTournamentInCommunity(req: Request, tourn: Tournament) throws -> EventLoopFuture<Bool> {
    return Community.query(on: req.db)
        .filter(\.$id == tourn.$community.id)
        .first()
        .unwrap(or: Top8Error.communityNotFound)
        .flatMap { community in

            return community.$tournaments.query(on: req.db)
                .filter(\Tournament.$name == tourn.name.uppercased())
                .count()
                .flatMap { numTourns in
                    if (numTourns == 0) {
                        return req.eventLoop.makeSucceededFuture(false)
                    } else {
                        return req.eventLoop.makeSucceededFuture(true)
                    }
                }

        }
	}
    
}