import Foundation
import CasePaths

func typeName(_ typeInstance: Any.Type) -> String {
    String(reflecting: typeInstance.self)
        .components(separatedBy: ".")
        .dropFirst()
        .dropLast()
        .joined(separator: ".")
}

protocol SceneState {
    associatedtype Route
    var route: Route? { get set }
}

extension SceneState {

    var name: String {
        typeName(Self.self)
    }

    var navBarName: String {
        let n = name
        guard let f = name.first else { return "" }
        let res = n.dropFirst()
        return String(res) + " " + String(f)
    }

    func state <DestState> (for cp: CasePath<Route?, DestState>) -> DestState? {
        cp.extract(from: route)
    }

    func isRoutingTo <DestState> (_ cp: CasePath<Route?, DestState>) -> Bool {
        state(for: cp) != nil
    }

}
