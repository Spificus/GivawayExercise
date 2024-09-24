import SwiftUI

struct ContentView: View {
    @ObservedObject var contactService = ContactService()
    
    // Filter state variables
    @State private var filterFirstName = ""
    @State private var filterLastName = ""
    @State private var filterEmail = ""
    @State private var filterPhoneNumber = ""
    @State private var filterInstagramHandle = ""
    
    // State variable to hold the selected contact's Instagram handle
    @State private var selectedInstagramHandle: String? = nil
    
    // In-App Purchase: Premium status
   @State private var isPremiumUnlocked = false
   @State private var showPaywall = false
       
    
    // Filtered contacts based on different criteria
    var filteredContacts: [Contact] {
        contactService.contacts.filter { contact in
            // Checking filters
            let firstNameMatches = filterFirstName.isEmpty || contact.userData?.firstName.lowercased().contains(filterFirstName.lowercased()) ?? false
            let lastNameMatches = filterLastName.isEmpty || contact.userData?.lastName.lowercased().contains(filterLastName.lowercased()) ?? false
            let emailMatches = filterEmail.isEmpty || contact.email.lowercased().contains(filterEmail.lowercased())
            let phoneMatches = filterPhoneNumber.isEmpty || contact.userData?.phone.contains(filterPhoneNumber) ?? false
            let instagramMatches = filterInstagramHandle.isEmpty || contact.userData?.name.lowercased().contains(filterInstagramHandle.lowercased()) ?? false
            
            // Return true if all filters match
            return firstNameMatches && lastNameMatches && emailMatches && phoneMatches && instagramMatches
        }
    }

    var body: some View {
        VStack {
            // Filters section
            VStack(alignment: .leading, spacing: 15) {
                Text("Filter Contacts")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)
                
                // Input fields for filtering
                VStack(spacing: 10) {
                    TextField("Filter by First Name", text: $filterFirstName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Filter by Last Name", text: $filterLastName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Filter by Email", text: $filterEmail)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    // Phone Number and Instagram Handle behind paywall
                    if isPremiumUnlocked {
                        TextField("Filter by Phone Number", text: $filterPhoneNumber)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Filter by Instagram Handle", text: $filterInstagramHandle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Button(action: {
                            showPaywall = true
                        }) {
                            HStack {
                                Image(systemName: "lock.fill")
                                Text("Unlock Phone & Instagram Filters")
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding(.top)
                    }
                }
                .padding([.leading, .trailing])
            }
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding([.leading, .trailing, .top], 20)
            
            Divider().padding(.vertical)

            // Display total and filtered contacts
            VStack(spacing: 5) {
                Text("Total Contacts: \(contactService.contacts.count)")
                    .font(.headline)
                    .padding(.bottom, 2)
                
                Text("Filtered Contacts: \(filteredContacts.count)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            
            Divider().padding(.vertical)

            // Button to pick a random contact
            Button(action: {
                if let randomContact = contactService.contacts.randomElement() {
                    selectedInstagramHandle = randomContact.userData?.name ?? "N/A"
                }
            }) {
                Text("Pick a Random Winner")
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding([.leading, .trailing], 20)
            }
            
            // Display the selected contact's Instagram handle
            if let instagramHandle = selectedInstagramHandle {
                Text("Winner is: \(instagramHandle)")
                    .font(.headline)
                    .padding(.top, 10)
            } else {
                Text("No Winner Selected Yet")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.top, 10)
            }
            
            Divider().padding(.vertical)

//            // Display the filtered contacts in a list
//            List(filteredContacts) { contact in
//                VStack(alignment: .leading, spacing: 5) {
//                    Text("Email: \(contact.email)")
//                        .font(.subheadline)
//                        .fontWeight(.semibold)
//                    
//                    Text("Country: \(contact.country)")
//                        .font(.footnote)
//                        .foregroundColor(.gray)
//                    
//                    Text("Instagram Handle: \(contact.userData?.name ?? "N/A")")
//                        .font(.footnote)
//                        .foregroundColor(.blue)
//                }
//                .padding(.vertical, 5)
//            }
        }
        .onAppear {
            contactService.fetchContacts()  // Fetch contacts when the view appears
        }
        .sheet(isPresented: $showPaywall) {
           PaywallView(isPremiumUnlocked: $isPremiumUnlocked, showPaywall: $showPaywall)
       }
    }
}
