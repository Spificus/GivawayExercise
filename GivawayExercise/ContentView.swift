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
                HStack {
                    Text("Contacts")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                }
                .padding()
                
                VStack(spacing: 15) {
                    TextField("First Name", text: $filterFirstName)
                        .textFieldStyle(InstagramTextFieldStyle())
                    
                    TextField("Last Name", text: $filterLastName)
                        .textFieldStyle(InstagramTextFieldStyle())
                    
                    TextField("Email", text: $filterEmail)
                        .textFieldStyle(InstagramTextFieldStyle())
                    
                    // Phone Number and Instagram Handle behind paywall
                    if isPremiumUnlocked {
                        TextField("Phone Number", text: $filterPhoneNumber)
                            .textFieldStyle(InstagramTextFieldStyle())
                        
                        TextField("Instagram Handle", text: $filterInstagramHandle)
                            .textFieldStyle(InstagramTextFieldStyle())
                            .padding(.bottom)
                    } else {
                        Button(action: {
                            showPaywall = true
                        }) {
                            HStack {
                                Image(systemName: "lock.fill")
                                Text("Unlock Phone & IG Handle Filters")
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding(.top)
                        .padding(.bottom)
                    }
                }
                .padding([.leading, .trailing])
            }
            .padding([.leading, .trailing], 20)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 5)
            .padding([.leading, .trailing, .top])
            
            Spacer()
            
            Divider().padding(.vertical)

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
            
            Spacer()
        }
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
        .onAppear {
            contactService.fetchContacts()
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(isPremiumUnlocked: $isPremiumUnlocked, showPaywall: $showPaywall)
        }
    }
}

// Custom TextField style to mimic Instagram's clean input fields
struct InstagramTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
            .padding(.bottom, 5)
    }
}
