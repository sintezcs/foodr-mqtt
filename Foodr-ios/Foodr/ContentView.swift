//
//  ContentView.swift
//  Foodr
//
//  Created by Alexey Minakov on 24.08.2022.
//

import SwiftUI

struct ContentView<Model: ViewModel>: View {
    
    @EnvironmentObject var model: Model
    
    var body: some View {
        VStack {
            Text(model.response).padding()
            Button(action: {model.sendCommand()}) {
                Text("Send PING Command")
                    .foregroundColor(Color.white)
                    .padding()
            }
            .background(RoundedRectangle(cornerRadius: 10   , style: .continuous))
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
