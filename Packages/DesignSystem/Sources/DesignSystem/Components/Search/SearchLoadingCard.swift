import SwiftUI

public struct SearchLoadingCard: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                DSSkeletonBlock(height: DSSize.listingImageHeight, cornerRadius: 0)

                HStack {
                    DSSkeletonBlock(width: 88, height: 24)
                    Spacer()
                    DSSkeletonBlock(width: 40, height: 40, cornerRadius: 20)
                }
                .padding(DSSpacing.small)
            }

            VStack(alignment: .leading, spacing: DSSpacing.small) {
                HStack(spacing: DSSpacing.xSmall) {
                    DSSkeletonBlock(width: 88, height: 16)
                    DSSkeletonBlock(width: 104, height: 16)
                }
                DSSkeletonBlock(width: 180, height: 24)
                DSSkeletonBlock(width: 240, height: 16)
                HStack(spacing: DSSpacing.medium) {
                    DSSkeletonBlock(width: 72, height: 16)
                    DSSkeletonBlock(width: 72, height: 16)
                    DSSkeletonBlock(width: 64, height: 16)
                }
            }
            .padding(DSSpacing.small)

            Divider()

            HStack(spacing: DSSpacing.xSmall) {
                DSSkeletonBlock(width: 116, height: 16)
                Spacer(minLength: DSSpacing.xxSmall)
                ForEach(0 ..< 3, id: \.self) { _ in
                    DSSkeletonBlock(width: DSSize.contactButton, height: DSSize.contactButton, cornerRadius: DSRadius.medium)
                }
            }
            .padding(DSSpacing.small)

            DSSkeletonBlock(height: 20, cornerRadius: 0)
        }
        .frame(maxWidth: .infinity)
        .shimmer()
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.xLarge))
        .overlay(
            RoundedRectangle(cornerRadius: DSRadius.xLarge)
                .stroke(DSColor.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.10), radius: 8, x: 0, y: 4)
        .accessibilityHidden(true)
    }
}
