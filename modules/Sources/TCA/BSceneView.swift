import ComposableArchitecture
import SwiftUI

// MARK: - View

extension BScene {

    public struct View: SwiftUI.View {

        private let store: Store<BScene.State, BScene.Action>

        public init(store: Store<BScene.State, BScene.Action>) {
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
                        }.padding()
                    }

                    if viewStore.presentWithSheets {
                        Button(action: { viewStore.send(.presentChild(true)) }) { Text("Present") }
                        .sheet(
                            isPresented: boolBinding(viewStore),
                            content: { destView() }
                        )
                    } else {
                        Button(action: { viewStore.send(.presentChild(true)) }) { Text("Push") }
                        NavigationLink("",
                            destination: destView(),
                         // destination: Lazy(destView()),
                            isActive: boolBinding(viewStore)
                        )
                    }

                    Spacer()
                }
                .padding()
                //.navigationBarHidden(true)
                .navigationTitle(Text(viewStore.navBarName))
                .ignoresSafeArea()
            }
        }

        private func boolBinding(_ viewStore: ViewStore<BScene.State, BScene.Action>) -> Binding<Bool> {
            viewStore.binding(
                get: { $0.isRoutingTo(/BScene.State.Route.child) },
                send: BScene.Action.presentChild
            )
        }

        @ViewBuilder
        private func destView() -> some SwiftUI.View {
            IfLetStore(
                store.scope(
                    state: { $0.state(for: /BScene.State.Route.child) },
                    action: BScene.Action.child
                ),
                then: CScene.View.init(store:)
            )
        }

    }

}

// MARK: - Previews

struct BScene_Previews: PreviewProvider {

    static var previews: some View {
        NavigationView {
            BScene.View(
                store: .init(
                    initialState: BScene.State(),
                    reducer: BScene.reducer,
                    environment: .init()
                )
            )
        }
    }

}
