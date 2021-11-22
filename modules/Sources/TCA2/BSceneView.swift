import ComposableArchitecture
import SwiftUI

// MARK: - View

extension BScene {

    public struct View: SwiftUI.View {

        @SwiftUI.Environment(\.dismiss) private var dismiss

        private let store: Store<State, Action>
        @ObservedObject private var viewStore: ViewStore<State, Action>

        private var destination: IfLetStore<CScene.State, CScene.Action, CScene.View?>
        private var isActive: Binding<Bool>

        public init(store: Store<State, Action>) {
            self.store = store
            let viewStore = ViewStore(store)
            self.viewStore = viewStore
            let childStore = store.scope(
                state: { $0.routeState(for: /State.Route.child) },
                action: Action.child
            )
            self.destination = IfLetStore(childStore, then: CScene.View.init(store:))
            self.isActive = viewStore.binding(
                get: { $0.isRoutingTo(/State.Route.child) },
                send: Action.presentChild
            )
        }

        public var body: some SwiftUI.View {
            VStack {
                Spacer()

                Text(viewStore.name)
                if let parentName = viewStore.parentName {
                    Text("Presented by \(parentName)")
                    Button(action: { dismiss() }) { Text("Dismiss") }.padding()
                }

                Button(action: { viewStore.send(.presentChild(true)) }) { Text("Push") }
                NavigationLink("", destination: destination, isActive: isActive)

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
