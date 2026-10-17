import SwiftUI

public extension Image {
    init?(imageSystemName: String?, imageName: String?, uiImage: UIImage? = nil, bundle: Bundle = .main) {
        if let imageSystemName {
            self.init(systemName: imageSystemName)
        } else if let imageName {
            self.init(imageName, bundle: bundle)
        } else if let uiImage {
            self.init(uiImage: uiImage)
        } else {
            return nil
        }
    }
}
