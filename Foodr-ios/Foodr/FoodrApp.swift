//
//  FoodrApp.swift
//  Foodr
//
//  Created by Alexey Minakov on 24.08.2022.
//

import SwiftUI


@main
struct FoodrApp: App {
    let viewModel: ViewModel = ViewModel()
    
    init() {
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(viewModel)
        }
    }
}
