import SwiftUI

public enum ContactType {
    case phone
    case email
    case whatsApp
    case sms

    var imageName: String? {
        switch self {
        case .whatsApp:
            return "whatsapp"
        default:
            return nil
        }
    }

    var imageNameFilled: String? {
        imageName.map { $0 + ".fill" }
    }

    var imageSystemName: String? {
        switch self {
        case .phone:
            return "phone"
        case .email:
            return "envelope"
        case .sms:
            return "message"
        default:
            return nil
        }
    }

    var imageSystemNameFilled: String? {
        imageSystemName.map { $0 + ".fill" }
    }

    var backgroundColor: Color {
        switch self {
        case .phone, .email, .sms:
            return DSColor.brand
        case .whatsApp:
            return DSColor.whatsApp
        }
    }
}
