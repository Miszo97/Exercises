import SwiftUI

struct Header: View {
    var content: String
    var body: some View {
        Text(content).font(.largeTitle)
    }
}

#Preview {
    Header(content: "Hello this is my app")
}
