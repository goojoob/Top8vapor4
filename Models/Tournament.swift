import Fluent
import Vapor

final class Tournament: Model, Content, Validatable {
	static let schema = "tournaments"
	
	@ID(key: .id)
	var id: UUID?

	@Field(key: "name")
	var name: String

	@Field(key: "num_rounds")
	var numRounds: Int

	@Field(key: "current_round")
    var currentRound: Int

	@Field(key: "started")
    var started: Bool

	@OptionalField(key: "started_at")
	var startedAt: Date?

	@OptionalField(key: "finished_at")
	var finishedAt: Date?

	@Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

	@Parent(key: "community_id")
	var community: Community

	@Siblings(through: PlayerTournament.self, from: \.$tournament, to: \.$player)
    public var players: [Player]

	@Children(for: \.$tournament)
	var rounds: [Round]

	init() {}

	init(id: UUID? = nil, name: String, communityID: UUID) {
		self.id = id
		self.name = name
		self.$community.id = communityID
		self.numRounds = 0
		self.currentRound = 0
		self.started = false
	}

	static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty && .count(3...))
    }
}