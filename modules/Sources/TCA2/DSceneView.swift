import ComposableArchitecture
import SwiftUI

// MARK: - View

extension DScene {

    public struct View: SwiftUI.View {

        @SwiftUI.Environment(\.dismiss) private var dismiss
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
                        Button(action: { dismiss() }) { Text("Dismiss") }.padding()
                    }

                    Spacer()

                    VStack {
                        Text("scene A: \(viewStore.countA)")
                        Text("scene B: \(viewStore.countB)")
                        Text("scene C: \(viewStore.countC)")
                        Text("scene D: \(viewStore.countD)")
                    }

                    Spacer()
                }
                .padding()
                //.navigationBarHidden(true)
                .navigationTitle(Text(viewStore.navBarName))
                .ignoresSafeArea()
            .onAppear { viewStore.send(.viewDidAppear) }
            }
        }

    }

}

// MARK: - Previews

struct DScene_Previews: PreviewProvider {

    static var previews: some View {
        NavigationView {
            DScene.View(
                store: .init(
                    initialState: DScene.State(),
                    reducer: DScene.reducer,
                    environment: .init()
                )
            )
        }
    }

}
