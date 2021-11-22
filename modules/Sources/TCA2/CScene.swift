import ComposableArchitecture

public enum CScene {}

// MARK: - State

extension CScene {

    public struct State: Equatable, SceneState {

        let parentName: String?
        var countA: Int
        var countB: Int
        var countC: Int
        var countD: Int
        var route: Route?

        public enum Route: Equatable {
            case child(DScene.State)
        }

        public init(
            parentName: String? = nil,
            countA: Int = 0,
            countB: Int = 0,
            countC: Int = 0,
            countD: Int = 0,
            route: Route? = nil
        ) {
            self.parentName = parentName
            self.countA = countA
            self.countB = countB
            self.countC = countC
            self.countD = countD
            self.route = route
        }

    }

}

// MARK: - Action

extension CScene {

    public enum Action: Equatable {

        case viewDidAppear
        case timerTicked
        case presentChild(Bool)
        case child(DScene.Action)

    }

}

// MARK: - Environment

extension CScene {

    public struct Environment {
        public init() {}
    }

}

// MARK: - Reducers

extension CScene {

    public static let reducer: Reducer<State, Action, Environment> =
        .combine(
            childReducer,
            localReducer
        )

    static let localReducer: Reducer<State, Action, Environment> =
    Reducer { state, action, environment in
        switch action {

            case .viewDidAppear:
                struct TimerId: Hashable {}
                return Effect.timer(
                    id: TimerId(),
                    every: 1,
                    tolerance: .zero,
                    on: DispatchQueue.main
                ).map { _ in CScene.Action.timerTicked }

            case .timerTicked:
                state.countC += 1
                return .none

            case .presentChild(true):
                print("CScene: .presentChild(true)")
                state.route = .child(
                    DScene.State(
                        parentName: state.name,
                        countA: state.countA,
                        countB: state.countB,
                        countC: state.countC,
                        countD: state.countD
                    )
                )
                return .none

            case .presentChild(false):
                print("CScene: .presentChild(false)")
                if let childState = state.routeState(for: /State.Route.child) {
                    state.countD = childState.countD
                }
                state.route = nil
                return .none

            case let .child(childAction):
                // Process actions fired by a child scene that is currently presented.
                print("CScene: .child(\(childAction))")
                return .none

        }
    }

    static let childReducer: Reducer<State, Action, Environment> =
    DScene.reducer
        .pullback(
            unwrapping: \State.route,
            case: /State.Route.child,
            action: /Action.child,
            environment: { _ in .init() }
        )

}
