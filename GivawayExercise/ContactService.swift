import Foundation

// ContactResponse model to match the API response
struct ContactResponse: Codable {
    let contacts: [Contact]
    let count: Int
}




class ContactService: ObservableObject {
    @Published var contacts = [Contact]()

    let contactsURL = "https://stoplight.io/mocks/highlevel/integrations/39582863/contacts/?locationId=ve9EPM428h8vShlRW1KT"
    let userUrl = "https://stoplight.io/mocks/highlevel/integrations/39582858/users/" // Base URL for fetching users

    func fetchContacts() {
        guard let url = URL(string: contactsURL) else {
            print("Invalid URL")
            return
        }

        var requestContacts = URLRequest(url: url)
        requestContacts.httpMethod = "GET"
        requestContacts.setValue("Bearer 123", forHTTPHeaderField: "Authorization")
        requestContacts.setValue("application/json", forHTTPHeaderField: "Content-Type")
        requestContacts.setValue("2021-07-28", forHTTPHeaderField: "Version")

        let task = URLSession.shared.dataTask(with: requestContacts) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let responseObject = try decoder.decode(ContactResponse.self, from: data)

                    DispatchQueue.main.async {
                        self.contacts = responseObject.contacts
                        self.fetchUserDataForContacts()
                    }
                } catch {
                    print("Error decoding contacts: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }

    // Fetch user data for each contact
    func fetchUserDataForContacts() {
        let dispatchGroup = DispatchGroup()

        for i in 0..<contacts.count {
            let contactId = contacts[i].id
            let userURLString = "\(userUrl)\(contactId)"  // API URL to get user by contact ID

            guard let url = URL(string: userURLString) else {
                print("Invalid URL for user \(contactId)")
                continue
            }

            var requestUser = URLRequest(url: url)
            requestUser.httpMethod = "GET"
            requestUser.setValue("Bearer 123", forHTTPHeaderField: "Authorization")
            requestUser.setValue("application/json", forHTTPHeaderField: "Content-Type")
            requestUser.setValue("2021-07-28", forHTTPHeaderField: "Version")

            // Enter the dispatch group before starting each request
            dispatchGroup.enter()

            let task = URLSession.shared.dataTask(with: requestUser) { data, response, error in
                if let error = error {
                    print("Error fetching user data for contact \(contactId): \(error.localizedDescription)")
                    dispatchGroup.leave()
                    return
                }

                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let user = try decoder.decode(User.self, from: data)

                        // Update the contact with the fetched user data
                        DispatchQueue.main.async {
                            self.contacts[i].userData = user
                        }

                    } catch {
                        print("Error decoding user data for contact \(contactId): \(error.localizedDescription)")
                    }
                }
                dispatchGroup.leave() // Leave the group after the request completes
            }
            task.resume()
        }

        // Notify when all user data fetching is complete
        dispatchGroup.notify(queue: .main) {
            print("All user data has been fetched!")
        }
    }
}
