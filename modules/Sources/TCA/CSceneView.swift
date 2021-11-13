import ComposableArchitecture
import SwiftUI

// MARK: - View

extension CScene {

    public struct View: SwiftUI.View {

        private let store: Store<CScene.State, CScene.Action>

        public init(store: Store<CScene.State, CScene.Action>) {
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

        private func boolBinding(_ viewStore: ViewStore<CScene.State, CScene.Action>) -> Binding<Bool> {
            viewStore.binding(
                get: { $0.isRoutingTo(/CScene.State.Route.child) },
                send: CScene.Action.presentChild
            )
        }

        @ViewBuilder
        private func destView() -> some SwiftUI.View {
            IfLetStore(
                store.scope(
                    state: { $0.state(for: /CScene.State.Route.child) },
                    action: CScene.Action.child
                ),
                then: DScene.View.init(store:)
            )
        }

    }

}

// MARK: - Previews

struct CScene_Previews: PreviewProvider {

    static var previews: some View {
        NavigationView {
            CScene.View(
                store: .init(
                    initialState: CScene.State(),
                    reducer: CScene.reducer,
                    environment: .init()
                )
            )
        }
    }

}
