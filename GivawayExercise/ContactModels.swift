// Contact model for each contact in the response
struct Contact: Codable, Identifiable {
    let id: String
    let locationId: String
    let email: String
    let timezone: String
    let country: String
    let source: String?  // Optional because it may not be present
    let dateAdded: String
    let tags: [String]
    let businessId: String?  // Optional because it may not be present
    let followers: String
    var userData: User?  // This will be populated with user details later
}

// User model for each user in the response
struct User: Codable, Identifiable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let name: String
}
