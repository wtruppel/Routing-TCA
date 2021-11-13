import SwiftUI
import TCA

@main
struct TCA: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                AScene.View(store: .init(
                    initialState: AScene.State(),
                    reducer: AScene.reducer,
                    environment: AScene.Environment()
                ))
            }
        }
    }
}
