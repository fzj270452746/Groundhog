

import SwiftUI

struct ContentView: View {
    var body: some View {
        GroundhogHomeView()
            .preferredColorScheme(.dark)
            .statusBarHidden(false)
    }
}

#Preview {
    ContentView()
}
