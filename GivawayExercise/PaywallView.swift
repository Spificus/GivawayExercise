import SwiftUICore
import SwiftUI
struct PaywallView: View {
    @Binding var isPremiumUnlocked: Bool
    
    @Binding var showPaywall: Bool
    
    var body: some View {
        VStack {
            Text("Unlock Premium Features")
                .font(.largeTitle)
                .padding()

            Text("Get access to the Phone Number and Instagram Handle filters.")
                .multilineTextAlignment(.center)
                .padding()

            Button(action: {
                // Simulate successful purchase for this example
                isPremiumUnlocked = true
                showPaywall = false
            }) {
                Text("Purchase Premium")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }

            Button(action: {
                // Close the paywall without purchasing
                showPaywall = false
            }) {
                Text("Cancel")
                    .fontWeight(.semibold)
                    .padding()
            }
        }
        .padding()
    }
}
