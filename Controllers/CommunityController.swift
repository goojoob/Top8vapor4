import Fluent
import Vapor

struct CommunityController: RouteCollection {
	
	func boot (routes: RoutesBuilder) throws {
		let communityRoutes = routes.grouped("api", "community")

		communityRoutes.get("get", ":paramID", use: getCommunityParam)
		communityRoutes.get("getAll", use: getAllCommunities)
		communityRoutes.get("getAllWith", use: getAllCommunitiesWith)

		communityRoutes.post("create", use: createCommunity)
	}



	func getCommunityParam(req: Request) throws -> EventLoopFuture<Community> {
		guard let paramID = req.parameters.get("paramID", as: UUID.self) else {
        	throw Abort(.badRequest)
    	}

		return Community.query(on: req.db)
			.filter(\.$id == paramID)
			.with(\.$players)
			.first()
			.unwrap(or: Top8Error.communityNotFound)
	}

	static func getCommunity(req: Request, communityId: UUID) throws -> EventLoopFuture<Community> {
        return Community.find(communityId, on: req.db)
			.unwrap(or: Top8Error.communityNotFound)
	}

	func getAllCommunities(req: Request) throws -> EventLoopFuture<[Community]> {
		return Community.query(on: req.db)
			.all()
	}

	func getAllCommunitiesWith(req: Request) throws -> EventLoopFuture<[Community]> {
		return Community.query(on: req.db)
			.with(\.$players)
			.sort(\.$name)
			.all()
	}



	func createCommunity(req: Request) throws -> EventLoopFuture<Community> {
		req.logger.info("Validating Community JSON")
		try Community.validate(content: req)

		let community: Community = try req.content.decode(Community.self)
		community.name = community.name.uppercased()

		return try existsCommunity(req: req, community: community).flatMap { existsCommunity in
			if existsCommunity {
				return req.eventLoop.makeFailedFuture(Top8Error.communityExists(community.name))
			} else {
				req.logger.info("Creating Community in Database")
				return community.create(on: req.db)
					.map { community }
			}
		}

	}

	func existsCommunity(req: Request, community: Community) throws -> EventLoopFuture<Bool> {
		Community.query(on: req.db)
			.filter(\.$name == community.name.uppercased())
			.count()
			.flatMap { numCommunities in
				if (numCommunities == 0) {
					return req.eventLoop.makeSucceededFuture(false)
				} else {
					return req.eventLoop.makeSucceededFuture(true)
				}
			}
	}

}