import Foundation
import SwiftUI
import CoreLocation

struct Expense: Identifiable {
    let id: UUID
    let photo: UIImage?
    let description: String
    let price: Double
    let date: Date
    let location: CLLocationCoordinate2D?
    let category: Category
    init(id: UUID = UUID(), photo: UIImage? = nil, description: String, price: Double, date: Date, location: CLLocationCoordinate2D? = nil, category: Category) {
        self.id = id
        self.photo = photo
        self.description = description
        self.price = price
        self.date = date
        self.location = location
        self.category = category
    }
}

enum Category: String, CaseIterable, Identifiable {
    case food, groceries, shopping, entertainment, utilities, transportation, other
    var id: String { self.rawValue }
}
