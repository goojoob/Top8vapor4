import Fluent
import Vapor

struct CommunityController: RouteCollection {
	
	func boot (routes: RoutesBuilder) throws {
		let communityRoutes = routes.grouped("api", "community")

		communityRoutes.get("get", ":paramID", use: getCommunity)
		communityRoutes.get("getAll", use: getAllCommunities)
		communityRoutes.get("getAllWith", use: getAllCommunitiesWith)

		communityRoutes.post("create", use: createCommunity)
	}



	func getCommunity(req: Request) throws -> EventLoopFuture<Community> {
		guard let paramID = req.parameters.get("paramID", as: UUID.self) else {
        	throw Abort(.badRequest)
    	}

		return Community.query(on: req.db)
			.filter(\.$id == paramID)
			.with(\.$players)
			.first()
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
		try Community.validate(req)

		req.logger.info("Creating Community in Database")
		let community: Community = try req.content.decode(Community.self)
		return community.create(on: req.db)
			.map { community }
	}

}