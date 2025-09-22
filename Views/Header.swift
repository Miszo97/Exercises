//
//  Header.swift
//  Exercises
//
//  Created by Artur Spek on 21/06/2025.
//

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
