import ComposableArchitecture

public enum Detail {}

// MARK: - State

extension Detail {

    public struct State: Equatable {

        let parentName: String?

        public init(parentName: String? = nil) {
            self.parentName = parentName
        }

        var name: String {
            typeName(Self.self)
        }

    }

}

// MARK: - Action

extension Detail {

    public enum Action: Equatable {

        case sceneDismissed // should be handled by the parent scene to dismiss this scene

    }

}

// MARK: - Environment

extension Detail {

    public struct Environment {
        public init() {}
    }

}

// MARK: - Reducers

extension Detail {

    public static let reducer: Reducer<State, Action, Environment> = localReducer.debug()

    static let localReducer: Reducer<State, Action, Environment> =
    Reducer { state, action, environment in
        switch action {

            case .sceneDismissed:
                // No need to do anything here. The parent scene should handle
                // this action and use it to dismiss this scene.
                return .none

        }
    }

}
