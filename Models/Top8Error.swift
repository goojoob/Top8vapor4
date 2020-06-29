import Vapor

enum Top8Error {
    case communityNotFound
    case playerExistsCommunity(String)
    case tournamentExistsCommunity(String)
}

extension Top8Error: AbortError {
    var reason: String {
        switch self {
            case .communityNotFound:
                return "Community not found"
            case .playerExists(let name):
                return "The player \(name) already exists in the community"
            case .tournamentExists(let name):
                return "The tournament \(name) already exists in the community"
        }
    }

    var status: HTTPStatus {
        switch self {
            case .communityNotFound:
                return .notFound
            case .playerExists:
                return .badRequest
            case .tournamentExists:
                return .badRequest
        }
    }
}