import Vapor

enum Top8Error {
    case communityNotFound
    case tournamentNotFound
    case playerNotFound
    case communityExists(String)
    case playerExistsCommunity(String)
    case playerExistsTournament(String, String)
    case tournamentExistsCommunity(String)
}

extension Top8Error: AbortError {
    var reason: String {
        switch self {
            case .communityNotFound:
                return "Community not found"
            case .tournamentNotFound:
                return "Tournament not found"
            case .playerNotFound:
                return "Player not found"
            case .communityExists(let name):
                return "The community \(name) already exists"                
            case .playerExistsCommunity(let name):
                return "The player \(name) already exists in the community"
            case .playerExistsTournament(let namePlayer, let nameTournament):
                return "The player \(namePlayer) already exists in the tournament \(nameTournament)"                
            case .tournamentExistsCommunity(let name):
                return "The tournament \(name) already exists in the community"
        }
    }

    var status: HTTPStatus {
        switch self {
            case .communityNotFound:
                return .notFound
            case .tournamentNotFound:
                return .notFound
            case .playerNotFound:
                return .notFound             
            case .communityExists:
                return .badRequest                                   
            case .playerExistsCommunity:
                return .badRequest
            case .playerExistsTournament:
                return .badRequest                
            case .tournamentExistsCommunity:
                return .badRequest
        }
    }
}