import Foundation

extension Float {
    func rounded(toPlaces places: Int) -> Float {
        let multiplier = pow(10, Float(places))
        return (self * multiplier).rounded() / multiplier
    }
}
