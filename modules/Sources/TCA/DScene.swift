import ComposableArchitecture

public enum DScene {}

// MARK: - State

extension DScene {

    public struct State: Equatable, SceneState {

        let parentName: String?
        var presentWithSheets: Bool
        var route: Route?

        public enum Route: Equatable {
            case child(Detail.State)
        }

        public init(
            parentName: String? = nil,
            presentWithSheets: Bool = false,
            route: Route? = nil
        ) {
            self.parentName = parentName
            self.presentWithSheets = presentWithSheets
            self.route = route
        }

    }

}

// MARK: - Action

extension DScene {

    public enum Action: Equatable {

        case sceneDismissed // should be handled by the parent scene to dismiss this scene

        case presentWithSheets(Bool)

        case presentChild(Bool)
        case child(Detail.Action)

    }

}

// MARK: - Environment

extension DScene {

    public struct Environment {
        public init() {}
    }

}

// MARK: - Reducers

extension DScene {

    public static let reducer: Reducer<State, Action, Environment> =
        .combine(
            childReducer,
            localReducer
        ).debug()

    static let localReducer: Reducer<State, Action, Environment> =
    Reducer { state, action, environment in
        switch action {

            case .sceneDismissed:
                // No need to do anything here. The parent scene should handle
                // this action and use it to dismiss this scene.
                return .none

            case let .presentWithSheets(useSheets):
                state.presentWithSheets = useSheets
                return .none

            case .presentChild(true):
                state.route = .child(
                    Detail.State(
                        parentName: state.name
                    )
                )
                return .none

            case .presentChild(false):
                state.route = nil
                return .none

            case .child(.sceneDismissed):
                // When this scene's child scene dismisses itself (for example, the user taps
                // a custom `dismiss`, `save`, `cancel`, etc button), the child scene fires its
                // `.sceneDismissed` action but its reducer ignores it. It's THIS scene's reducer's
                // responsibility to process that action and dismiss the child. We can do this
                // without code duplication by firing this scene's `.dismissChild` action.
                return Effect(value: .presentChild(false))

            case let .child(childAction):
                // Process actions fired by a child scene that is currently presented.
                return .none

        }
    }

    static let childReducer: Reducer<State, Action, Environment> =
    Detail.reducer
        .pullback(
            unwrapping: \State.route,
            case: /State.Route.child,
            action: /Action.child,
            environment: { _ in .init() }
        )

}
