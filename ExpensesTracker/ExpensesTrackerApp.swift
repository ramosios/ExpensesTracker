//
//  ExpensesTrackerApp.swift
//  ExpensesTracker
//
//  Created by Jorge Ramos on 25/07/25.
//

import SwiftUI

@main
struct ExpensesTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                PhotoView()
                    .tabItem {
                        Label("Photo", systemImage: "photo.on.rectangle.angled")
                    }
                TrackerView()
                    .tabItem {
                        Label("Tracker", systemImage: "list.bullet")
                    }
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
            }
        }
    }
}
