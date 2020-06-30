import Fluent
import Vapor

final class Tournament: Model, Content, Validatable {
	static let schema = "tournament"
	
	@ID(key: .id)
	var id: UUID?

	@Field(key: "name")
	var name: String

	@Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

	@Parent(key: "community_id")
	var community: Community

	@Siblings(through: PlayerTournament.self, from: \.$tournament, to: \.$player)
    public var players: [Player]

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