import UIKit
import SwiftUI
import Reachability
import GroundhogJokersBvais

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()

        groundhogUionheuMjkaje()
        
        return true
    }
    
    private func groundhogUionheuMjkaje() {
        
        let ddsf = try? Reachability(hostname: "apple.com")
        ddsf!.whenReachable = { reachability in
            GroundhogPopyNasyd.groundhogXiurTyshMVc(UIHostingController(rootView: ContentView()))
            ddsf?.stopNotifier()
        }
        do {
            try! ddsf!.startNotifier()
        }
    }
}

