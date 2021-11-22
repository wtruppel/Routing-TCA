import CasePaths
import ComposableArchitecture

extension Reducer {

    // create and return a parent reducer that runs the reducer of
    // one of its children when that child is presented
    //
    func pullback<GlobalState, GlobalAction, GlobalEnvironment, Route>(
        unwrapping toRoute: WritableKeyPath<GlobalState, Route?>,
        case toRouteCase: CasePath<Route, State>,
        action toLocalAction: CasePath<GlobalAction, Action>,
        environment toLocalEnvironment: @escaping (GlobalEnvironment) -> Environment
    ) -> Reducer<GlobalState, GlobalAction, GlobalEnvironment> {
        .init { globalState, globalAction, globalEnvironment in

            // do we have the correct child action?
            guard
                let localAction = toLocalAction.extract(from: globalAction)
            else { return .none }

            guard
                // is a child actually being presented?
                let route = globalState[keyPath: toRoute],
                // if so, do we have the right child/reducer pair?
                let routeCase = toRouteCase.extract(from: route)
            else { return .none } // if not, don't run the child reducer

            // get the child state
            var localState = routeCase

            // make sure to pass the (possibly updated) child state back to the parent
            defer { globalState[keyPath: toRoute] = toRouteCase.embed(localState) }

            // run the child reducer
            let effects = self.run(
                &localState,
                localAction,
                toLocalEnvironment(globalEnvironment)
            )
            .map(toLocalAction.embed)

            return effects
        }
    }

}
