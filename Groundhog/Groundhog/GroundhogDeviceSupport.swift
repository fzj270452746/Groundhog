
import SwiftUI
import UIKit

// MARK: - Device Type Detection

extension UIDevice {
    var groundhogDeviceType: GroundhogDeviceType {
        if userInterfaceIdiom == .pad {
            return .ipad
        } else {
            return .iphone
        }
    }
    
    var groundhogScreenSize: GroundhogScreenSize {
        let screenBounds = UIScreen.main.bounds
        let screenWidth = screenBounds.width
        let screenHeight = screenBounds.height
        let screenMax = max(screenWidth, screenHeight)
        
        if userInterfaceIdiom == .pad {
            if screenMax >= 1366 { // iPad Pro 12.9"
                return .ipadPro12_9
            } else if screenMax >= 1194 { // iPad Pro 11"
                return .ipadPro11
            } else { // iPad Air, iPad mini, etc.
                return .ipadRegular
            }
        } else {
            if screenMax >= 926 { // iPhone 14 Pro Max, 13 Pro Max, 12 Pro Max
                return .iphoneProMax
            } else if screenMax >= 844 { // iPhone 14 Pro, 13 Pro, 12 Pro, 13, 12
                return .iphonePro
            } else if screenMax >= 812 { // iPhone 13 mini, 12 mini, 11 Pro, X, XS
                return .iphoneCompact
            } else if screenMax >= 736 { // iPhone 8 Plus, 7 Plus, 6s Plus, 6 Plus
                return .iphonePlus
            } else { // iPhone SE, 8, 7, 6s, 6
                return .iphoneRegular
            }
        }
    }
}

enum GroundhogDeviceType {
    case iphone
    case ipad
}

enum GroundhogScreenSize {
    case iphoneRegular    // 4.7" and smaller
    case iphoneCompact    // 5.4" - 5.8"
    case iphonePro        // 6.1"
    case iphoneProMax     // 6.7"
    case iphonePlus       // 5.5"
    case ipadRegular      // iPad Air, mini
    case ipadPro11        // iPad Pro 11"
    case ipadPro12_9      // iPad Pro 12.9"
}

// MARK: - Responsive Layout Helper

struct GroundhogResponsiveLayout {
    let device: UIDevice
    
    init() {
        self.device = UIDevice.current
    }
    
    // MARK: - Spacing
    
    var groundhogBaseSpacing: CGFloat {
        switch device.groundhogScreenSize {
        case .iphoneRegular:
            return 12
        case .iphoneCompact, .iphonePro:
            return 16
        case .iphoneProMax, .iphonePlus:
            return 20
        case .ipadRegular:
            return 24
        case .ipadPro11:
            return 28
        case .ipadPro12_9:
            return 32
        }
    }
    
    var groundhogCardSpacing: CGFloat {
        switch device.groundhogScreenSize {
        case .iphoneRegular:
            return 3  // Reduced for better space utilization
        case .iphoneCompact, .iphonePro:
            return 4  // Reduced for better space utilization
        case .iphoneProMax, .iphonePlus:
            return 5  // Reduced for better space utilization
        case .ipadRegular:
            return 6  // Reduced for better space utilization
        case .ipadPro11:
            return 7  // Reduced for better space utilization
        case .ipadPro12_9:
            return 8  // Reduced for better space utilization
        }
    }
    
    // MARK: - Font Sizes
    
    var groundhogTitleFontSize: CGFloat {
        switch device.groundhogScreenSize {
        case .iphoneRegular:
            return 28
        case .iphoneCompact, .iphonePro:
            return 32
        case .iphoneProMax, .iphonePlus:
            return 36
        case .ipadRegular:
            return 44
        case .ipadPro11:
            return 48
        case .ipadPro12_9:
            return 56
        }
    }
    
    var groundhogSubtitleFontSize: CGFloat {
        switch device.groundhogScreenSize {
        case .iphoneRegular:
            return 18
        case .iphoneCompact, .iphonePro:
            return 20
        case .iphoneProMax, .iphonePlus:
            return 22
        case .ipadRegular:
            return 26
        case .ipadPro11:
            return 28
        case .ipadPro12_9:
            return 32
        }
    }
    
    var groundhogBodyFontSize: CGFloat {
        switch device.groundhogScreenSize {
        case .iphoneRegular:
            return 14
        case .iphoneCompact, .iphonePro:
            return 16
        case .iphoneProMax, .iphonePlus:
            return 17
        case .ipadRegular:
            return 19
        case .ipadPro11:
            return 20
        case .ipadPro12_9:
            return 22
        }
    }
    
    // MARK: - Card Sizes
    
    var groundhogCardSize: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let availableWidth = screenWidth - (groundhogHorizontalPadding * 2) - (groundhogCardSpacing * 3)
        let cardWidth = availableWidth / 4
        
        switch device.groundhogScreenSize {
        case .iphoneRegular:
            return min(cardWidth, 40)  // Further reduced for compatibility mode
        case .iphoneCompact, .iphonePro:
            return min(cardWidth, 45)  // Further reduced for compatibility mode
        case .iphoneProMax, .iphonePlus:
            return min(cardWidth, 50)  // Further reduced for compatibility mode
        case .ipadRegular:
            return min(cardWidth, 55)  // Significantly reduced for iPad compatibility mode
        case .ipadPro11:
            return min(cardWidth, 60)  // Significantly reduced for iPad compatibility mode
        case .ipadPro12_9:
            return min(cardWidth, 65)  // Significantly reduced for iPad compatibility mode
        }
    }
    
    // MARK: - Padding
    
    var groundhogHorizontalPadding: CGFloat {
        switch device.groundhogScreenSize {
        case .iphoneRegular:
            return 8   // Reduced to maximize card space
        case .iphoneCompact, .iphonePro:
            return 10  // Reduced to maximize card space
        case .iphoneProMax, .iphonePlus:
            return 12  // Reduced to maximize card space
        case .ipadRegular:
            return 20  // Reduced to maximize card space
        case .ipadPro11:
            return 30  // Reduced to maximize card space
        case .ipadPro12_9:
            return 40  // Reduced to maximize card space
        }
    }
    
    var groundhogVerticalPadding: CGFloat {
        switch device.groundhogScreenSize {
        case .iphoneRegular:
            return 12
        case .iphoneCompact, .iphonePro:
            return 16
        case .iphoneProMax, .iphonePlus:
            return 20
        case .ipadRegular:
            return 24
        case .ipadPro11:
            return 32
        case .ipadPro12_9:
            return 40
        }
    }
    
    // MARK: - Button Sizes
    
    var groundhogButtonHeight: CGFloat {
        switch device.groundhogScreenSize {
        case .iphoneRegular:
            return 44
        case .iphoneCompact, .iphonePro:
            return 50
        case .iphoneProMax, .iphonePlus:
            return 54
        case .ipadRegular:
            return 60
        case .ipadPro11:
            return 66
        case .ipadPro12_9:
            return 72
        }
    }
    
    var groundhogIconSize: CGFloat {
        switch device.groundhogScreenSize {
        case .iphoneRegular:
            return 20
        case .iphoneCompact, .iphonePro:
            return 22
        case .iphoneProMax, .iphonePlus:
            return 24
        case .ipadRegular:
            return 28
        case .ipadPro11:
            return 30
        case .ipadPro12_9:
            return 32
        }
    }
    
    // MARK: - Grid Layout
    
    var groundhogGameGridMaxWidth: CGFloat {
        switch device.groundhogDeviceType {
        case .iphone:
            return UIScreen.main.bounds.width - (groundhogHorizontalPadding * 2)
        case .ipad:
            // Limit game area on iPad to maintain iPhone-like aspect ratio
            return min(UIScreen.main.bounds.width * 0.6, 500)
        }
    }
    
    var groundhogShouldUseCompactLayout: Bool {
        return device.groundhogDeviceType == .iphone && 
               (device.groundhogScreenSize == .iphoneRegular || device.groundhogScreenSize == .iphoneCompact)
    }
}

// MARK: - Responsive View Modifier

struct GroundhogResponsiveModifier: ViewModifier {
    let layout = GroundhogResponsiveLayout()
    
    func body(content: Content) -> some View {
        content
            .environment(\.groundhogLayout, layout)
    }
}

extension View {
    func groundhogResponsive() -> some View {
        modifier(GroundhogResponsiveModifier())
    }
}

// MARK: - Environment Key

private struct GroundhogLayoutKey: EnvironmentKey {
    static let defaultValue = GroundhogResponsiveLayout()
}

extension EnvironmentValues {
    var groundhogLayout: GroundhogResponsiveLayout {
        get { self[GroundhogLayoutKey.self] }
        set { self[GroundhogLayoutKey.self] = newValue }
    }
}

// MARK: - iPad Specific Adaptations

struct GroundhogIPadGameContainer<Content: View>: View {
    let content: Content
    @Environment(\.groundhogLayout) private var layout
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        if UIDevice.current.groundhogDeviceType == .ipad {
            HStack {
                Spacer()
                content
                    .frame(maxWidth: layout.groundhogGameGridMaxWidth)
                Spacer()
            }
            .background(
                // Add subtle side gradients on iPad
                HStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.3),
                            Color.clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 100)
                    
                    Spacer()
                    
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.black.opacity(0.3)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 100)
                }
            )
        } else {
            content
        }
    }
}

// MARK: - Safe Area Helper

extension View {
    func groundhogSafeAreaPadding() -> some View {
        self.padding(.top, UIDevice.current.groundhogDeviceType == .ipad ? 20 : 0)
    }
    
    func groundhogAdaptiveCornerRadius() -> some View {
        let radius: CGFloat = UIDevice.current.groundhogDeviceType == .ipad ? 16 : 12
        return self.cornerRadius(radius)
    }
    
    func groundhogAdaptiveShadow() -> some View {
        let radius: CGFloat = UIDevice.current.groundhogDeviceType == .ipad ? 8 : 4
        let y: CGFloat = UIDevice.current.groundhogDeviceType == .ipad ? 4 : 2
        return self.shadow(color: .black.opacity(0.2), radius: radius, x: 0, y: y)
    }
}
