import ComposableArchitecture
import SwiftUI

// MARK: - View

extension DScene {

    public struct View: SwiftUI.View {

        private let store: Store<DScene.State, DScene.Action>

        public init(store: Store<DScene.State, DScene.Action>) {
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

        private func boolBinding(_ viewStore: ViewStore<DScene.State, DScene.Action>) -> Binding<Bool> {
            viewStore.binding(
                get: { $0.isRoutingTo(/DScene.State.Route.child) },
                send: DScene.Action.presentChild
            )
        }

        @ViewBuilder
        private func destView() -> some SwiftUI.View {
            IfLetStore(
                store.scope(
                    state: { $0.state(for: /DScene.State.Route.child) },
                    action: DScene.Action.child
                ),
                then: Detail.View.init(store:)
            )
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
