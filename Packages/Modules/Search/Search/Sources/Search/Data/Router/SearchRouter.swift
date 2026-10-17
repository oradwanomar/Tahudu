import Networking

public enum SearchRouter {
    case getList
}

extension SearchRouter: APIEndpointProtocol {
    public var method: HTTPMethod {
        switch self {
        case .getList:
            .get
        }
    }

    public var baseURL: String {
        "https://simplejsoncms.com"
    }

    public var path: String {
        switch self {
        case .getList:
            "api/m6nfoc4jlw"
        }
    }
}
