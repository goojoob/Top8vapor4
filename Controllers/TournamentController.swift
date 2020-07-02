import Fluent
import Vapor

struct TournamentController: RouteCollection {
	
	func boot (routes: RoutesBuilder) throws {
		let tournamentRoutes = routes.grouped("api", "tournament")

		tournamentRoutes.get("get", ":paramID", use: getTournament)
        tournamentRoutes.get("getWith", ":paramID", use: getTournamentWith)
		tournamentRoutes.get("getAll", use: getAllTournaments)
		tournamentRoutes.get("getAllWith", use: getAllTournamentsWith)

		tournamentRoutes.post("create", use: createTournament)

        tournamentRoutes.post("addPlayer", use: addPlayer)
        tournamentRoutes.get("getPlayers", ":paramID", use: getPlayers)
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

    static func getTournament(req: Request, tournamentId: UUID) throws -> EventLoopFuture<Tournament> {
        return Tournament
            .find(tournamentId, on: req.db)
            .unwrap(or: Top8Error.tournamentNotFound)
    }

    func getTournamentWith(req: Request) throws -> EventLoopFuture<Tournament> {
		guard let paramID = req.parameters.get("paramID", as: UUID.self) else {
        	throw Abort(.badRequest)
    	}

		return Tournament.query(on: req.db)
            .with(\.$players)
			.with(\.$rounds)
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
            .with(\.$players)
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
		return try CommunityController
			.getCommunity(req: req, communityId: tourn.$community.id)
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



    func addPlayer(req: Request) throws -> EventLoopFuture<HTTPResponseStatus> {
        let paramPlayerTournament: ParamPlayerTournament = try req.content.decode(ParamPlayerTournament.self)

        return try TournamentController
            .getTournament(req: req, tournamentId: paramPlayerTournament.tournamentId)
            .flatMap { tournament in
                do {
                    return try PlayerController
                        .getPlayer(req: req, playerId: paramPlayerTournament.playerId)
                        .flatMap { player in 

                            return tournament.$players.isAttached(to: player, on:req.db)
                                .flatMap { playerExistsInTournament in
                                    if playerExistsInTournament {
                                        return req.eventLoop.makeFailedFuture(Top8Error.playerExistsTournament(player.name, tournament.name))
                                    } else {
                                        return tournament.$players
                                            .attach(player, method: .ifNotExists, on: req.db)
                                            .transform(to: HTTPStatus.ok)
                                    }
                            }

                        }
                } catch {
                    return req.eventLoop.makeFailedFuture(Top8Error.playerNotFound)
                }
            }
    }



    func getPlayers(req: Request) throws -> EventLoopFuture<[Player]> {
		guard let paramID = req.parameters.get("paramID", as: UUID.self) else {
        	throw Abort(.badRequest)
    	}

		return Tournament.query(on: req.db)
			.filter(\.$id == paramID)
			.first()
			.unwrap(or: Top8Error.tournamentNotFound)
            .flatMap { tournament in
                return tournament.$players
                    .get(on: req.db)
            }

	}


}