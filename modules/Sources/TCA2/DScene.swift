import ComposableArchitecture

public enum DScene {}

// MARK: - State

extension DScene {

    public struct State: Equatable {

        let parentName: String?
        var countA: Int
        var countB: Int
        var countC: Int
        var countD: Int

        public init(
            parentName: String? = nil,
            countA: Int = 0,
            countB: Int = 0,
            countC: Int = 0,
            countD: Int = 0
        ) {
            self.parentName = parentName
            self.countA = countA
            self.countB = countB
            self.countC = countC
            self.countD = countD
        }

        var name: String {
            typeName(Self.self)
        }

        var navBarName: String {
            let n = name
            guard let f = name.first else { return "" }
            let res = n.dropFirst()
            return String(res) + " " + String(f)
        }

    }

}

// MARK: - Action

extension DScene {

    public enum Action: Equatable {

        case viewDidAppear
        case timerTicked

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

    public static let reducer: Reducer<State, Action, Environment> = localReducer

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
                ).map { _ in DScene.Action.timerTicked }

            case .timerTicked:
                state.countD += 1
                return .none

        }
    }

}
