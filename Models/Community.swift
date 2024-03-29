import Fluent
import Vapor

final class Community: Model, Content, Validatable {
	static let schema = "communities"
	
	@ID(key: .id)
	var id: UUID?

	@Field(key: "name")
	var name: String

	@Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
	
	@Children(for: \.$community)
	var players: [Player]

	@Children(for: \.$community)
	var tournaments: [Tournament]

	init() {}

	init(id: UUID? = nil, name: String) {
		self.id = id
		self.name = name
	}

	static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty && .count(3...))
    }
}