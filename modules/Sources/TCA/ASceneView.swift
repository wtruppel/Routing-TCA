import ComposableArchitecture
import SwiftUI

// MARK: - View

extension AScene {

    public struct View: SwiftUI.View {

        private let store: Store<AScene.State, AScene.Action>

        public init(store: Store<AScene.State, AScene.Action>) {
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

                    HStack {
                        Text("Use sheets").padding()
                        Toggle("", isOn: viewStore.binding(
                            get: { $0.presentWithSheets },
                            send: { .presentWithSheets($0) }
                        ))
                    }
                    .padding()

                    Spacer()
                }
                .padding()
                //.navigationBarHidden(true)
                .navigationTitle(Text(viewStore.navBarName))
                .ignoresSafeArea()
            }
        }

        private func boolBinding(_ viewStore: ViewStore<AScene.State, AScene.Action>) -> Binding<Bool> {
            viewStore.binding(
                get: { $0.isRoutingTo(/AScene.State.Route.child) },
                send: AScene.Action.presentChild
            )
        }

        @ViewBuilder
        private func destView() -> some SwiftUI.View {
            IfLetStore(
                store.scope(
                    state: { $0.state(for: /AScene.State.Route.child) },
                    action: AScene.Action.child
                ),
                then: BScene.View.init(store:)
            )
        }

    }

}

// MARK: - Previews

struct AScene_Previews: PreviewProvider {

    static var previews: some View {
        NavigationView {
            AScene.View(
                store: .init(
                    initialState: AScene.State(),
                    reducer: AScene.reducer,
                    environment: .init()
                )
            )
        }
    }

}
