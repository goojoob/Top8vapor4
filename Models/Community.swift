import Fluent
import Vapor

final class Community: Model, Content, Validatable {
	static let schema = "community"
	
	@ID(key: .id)
	var id: UUID?

	@Field(key: "name")
	var name: String

	@Children(for: \.$community)
	var players: [Player]

	init() {}

	init(id: UUID? = nil, name: String) {
		self.id = id
		self.name = name
	}

	static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty && .count(3...) && .alphanumeric)
    }
}