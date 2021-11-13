import ComposableArchitecture
import SwiftUI

// MARK: - View

extension Detail {

    public struct View: SwiftUI.View {
        
        private let store: Store<State, Action>

        public init(store: Store<State, Action>) {
            self.store = store
        }

        public var body: some SwiftUI.View {
            WithViewStore(store) { viewStore in
                VStack {
                    Spacer()

                    Text(viewStore.name)
                    if let parentName = viewStore.parentName {
                        Text("Presented by \(parentName)")
                        Button(action: { viewStore.send(.sceneDismissed) }) {
                            Text("Dismiss")
                        }
                    } else {
                        Text("<SwiftUI preview>")
                    }

                    Spacer()
                }
                .padding()
                //.navigationBarHidden(true)
                .navigationTitle(Text("Detail"))
                .ignoresSafeArea()
            }
        }
        
    }
    
}

// MARK: - Previews

struct GDetail_Previews: PreviewProvider {

    static var previews: some View {
        NavigationView {
            Detail.View(
                store: .init(
                    initialState: Detail.State(),
                    reducer: Detail.reducer,
                    environment: .init()
                )
            )
        }
    }

}
