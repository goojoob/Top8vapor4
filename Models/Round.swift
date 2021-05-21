import Fluent
import Vapor

final class Round: Model, Content, Validatable {
	static let schema = "rounds"
	
	@ID(key: .id)
	var id: UUID?

	@Field(key: "num_round")
	var numRound: Int

	@Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

	@Parent(key: "tournament_id")
	var tournament: Tournament

	init() {}

	init(id: UUID? = nil, numRound: Int, tournamentID: UUID) {
		self.id = id
		self.numRound = numRound
		self.$tournament.id = tournamentID
	}

	static func validations(_ validations: inout Validations) {
        validations.add("numRound", as: Int.self, is: .range(0...))
    }
}