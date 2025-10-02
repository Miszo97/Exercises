import SwiftUI

struct HeaderView: View {
    var content: String
    var body: some View {
        Text(content).font(.largeTitle)
    }
}

#Preview {
    HeaderView(content: "Hello this is my app")
}
