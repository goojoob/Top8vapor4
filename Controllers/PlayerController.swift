import Fluent
import Vapor

struct PlayerController: RouteCollection {
	
	func boot (routes: RoutesBuilder) throws {
		let playerRoutes = routes.grouped("api", "player")

		playerRoutes.get("get", ":paramID", use: getPlayerParam)
		playerRoutes.get("getAll", use: getAllPlayers)
		playerRoutes.get("getAllWith", use: getAllPlayersWith)
		
		playerRoutes.post("create", use: createPlayer)

		playerRoutes.get("getTournaments", ":paramID", use: getTournaments)
	}



	func getPlayerParam(req: Request) throws -> EventLoopFuture<Player> {
		guard let paramID = req.parameters.get("paramID", as: UUID.self) else {
        	throw Abort(.badRequest)
    	}

		return Player.query(on: req.db)
			.filter(\.$id == paramID)
			.first()
			.unwrap(or: Top8Error.playerNotFound)
	}

	static func getPlayer(req: Request, playerId: UUID) throws -> EventLoopFuture<Player> {
        return Player.find(playerId, on: req.db)
			.unwrap(or: Top8Error.playerNotFound)
	}

	func getAllPlayers(req: Request) throws -> EventLoopFuture<[Player]> {
		return Player.query(on: req.db)
			.all()
	}

	func getAllPlayersWith(req: Request) throws -> EventLoopFuture<[Player]> {
		return Player.query(on: req.db)
			.with(\.$community)
			.sort(\.$name)
			.all()
	}



	func createPlayer(req: Request) throws -> EventLoopFuture<Player> {
		req.logger.info("Validating Player JSON")
		try Player.validate(content: req)
		
		let player: Player = try req.content.decode(Player.self)
		player.name = player.name.uppercased()

		return try existsPlayerInCommunity(req: req, player: player).flatMap { existsPlayer in

			if existsPlayer {
				return req.eventLoop.makeFailedFuture(Top8Error.playerExistsCommunity(player.name))
			} else {
				req.logger.info("Creating Player \(player.name) in Database")
				return player.create(on: req.db)
					.map { player }
			}

		}
	}

	func existsPlayerInCommunity(req: Request, player: Player) throws -> EventLoopFuture<Bool> {
		return try CommunityController
			.getCommunity(req: req, communityId: player.$community.id)
			.flatMap { community in

				return community.$players.query(on: req.db)
					.filter(\Player.$name == player.name.uppercased())
					.count()
					.flatMap { numPlayers in
						if (numPlayers == 0) {
							return req.eventLoop.makeSucceededFuture(false)
						} else {
							return req.eventLoop.makeSucceededFuture(true)
						}
					}

			}
	}



    func getTournaments(req: Request) throws -> EventLoopFuture<[Tournament]> {
		guard let paramID = req.parameters.get("paramID", as: UUID.self) else {
        	throw Abort(.badRequest)
    	}

		return Player.query(on: req.db)
			.filter(\.$id == paramID)
			.first()
			.unwrap(or: Top8Error.playerNotFound)
            .flatMap { player in
                return player.$tournaments
                    .get(on: req.db)
            }
	}

}