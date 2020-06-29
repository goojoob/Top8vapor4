import Fluent
import Vapor

final class Player: Model, Content, Validatable {
	static let schema = "player"
	
	@ID(key: .id)
	var id: UUID?

	@Field(key: "name")
	var name: String

	@Parent(key: "community_id")
	var community: Community

	init() {}

	init(id: UUID? = nil, name: String, communityID: UUID) {
		self.id = id
		self.name = name
		self.$community.id = communityID
	}

	static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty && .count(3...))
    }
}