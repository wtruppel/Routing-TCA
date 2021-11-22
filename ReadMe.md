### The problem

I'm attempting to use the routing ideas currently being discussed in the video series within TCA but I ran into a very unusual situation. In the example project, you can either present a series of nested scenes using a sheet presentation style or a stack navigation style.

The navigation works perfectly with sheet presentation but fails with stack navigation. It works fine when scene A pushes scene B but when scene B then pushes scene C, scene C appears for a brief moment then gets dismissed back to scene B, which is then left in an inconsistent state.

![navigation.mp4](navigation.mp4)

The code that calls them is identical and the data passed to them is identical, except for the fact that a sheet takes a closure that produces its destination view while a `NavigationLink` takes the actual view, ie, the `NavigationLink` API is "eager". Using a lazy wrapper view to build the view only when it's actually presented does not solve the issue so, in effect, both the sheet and the `NavigationLink` take the exact same data.

```swift
public var body: some SwiftUI.View {
    WithViewStore(store) { viewStore in
        VStack {
            // ...
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
            // ...
        }
        // ...
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
```

I thought that maybe it's the logic in the reducer that is at fault but, if that was the case, why would the sheet presentation work flawlessly? Besides, the reducer logic is pretty simple and all the debug actions and state changes, in both sheets and nav links, are correct. In fact, the state after A pushes B and B pushes C is exactly what you'd expect but that is not what is rendered.

I then thought that since everything is effectively the same for both sheets and nav links, then the fact that the former work but the latter don't suggests that there's a bug in the implementation of `NavigationLink` itself, ie, a bug in SwiftUI itself.

So, I built an identical project using vanilla SwiftUI and the navigation links work perfectly fine.

The next alternative is that TCA itself has a bug but, then, its code is agnostic with respect to the rendering framework so if it works with sheets, it should also work with nav links.

The only alternative left is that I don't correctly understand how to model this problem but, then, this is a really simple project: just identical scenes that present one another in sequence, in a nested way (A presents B, then B presents C, then C presents D, then D presents some leaf scene).

I did find a solution, however. When creating the destination view, do not scope the presenting store down to the presented store but, rather, create a brand new store with the presented state. In code, it means to use

```swift
BScene.View(store: .init(
    initialState: BScene.State(),
    reducer: BScene.reducer,
    environment: BScene.Environment()
))
```

rather than

```swift
IfLetStore(
    store.scope(
        state: { $0.state(for: /AScene.State.Route.child) },
        action: AScene.Action.child
    ),
    then: BScene.View.init(store:)
)
```

This solution smells wrong in at least three ways:

- it requires an environment and the presenting view does not have access to the current one
- the presenting reducer does not get a chance to process actions fired by the presented view
- how do any changes in the presented view's state get incorporated back into the presenter's state if the presented state is "detached"?

I'm at a loss in what should be a really simple problem. At work, it's become a blocker, which is why I created a toy project and also why I'm here at the forum asking for help.

Any help is much appreciated!

### Addendum

I did find a solution where the state of the presented view is scoped from the state of the presenting view but it seems to work only if/when the state of the child is scoped at the time the child view is initialised, as follows:

```swift
public struct View: SwiftUI.View {

    @SwiftUI.Environment(\.dismiss) private var dismiss

    private let store: Store<State, Action>
    @ObservedObject private var viewStore: ViewStore<State, Action>

    private var destination: IfLetStore<BScene.State, BScene.Action, BScene.View?>
    private var isActive: Binding<Bool>

    public init(store: Store<State, Action>) {
        self.store = store
        let viewStore = ViewStore(store)
        self.viewStore = viewStore
        let childStore = store.scope(
            state: { $0.routeState(for: /State.Route.child) },
            action: Action.child
        )
        self.destination = IfLetStore(childStore, then: BScene.View.init(store:))
        self.isActive = viewStore.binding(
            get: { $0.isRoutingTo(/State.Route.child) },
            send: Action.presentChild
        )
    }

    public var body: some SwiftUI.View {
        VStack {
            // ...

            Button(action: { viewStore.send(.presentChild(true)) }) { Text("Push") }
            NavigationLink("", destination: destination, isActive: isActive)

            // ...
        }
        // ...
    }

}
```

It's not clear to me that this solution is free from problems but it appears to work.
