//
//  ContentView.swift
//  Finansor
//
//  Created by Atakan İçel on 26.03.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
                .font(Font.system(size: 30))
                .foregroundStyle(.blue)
                .padding(.top)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
