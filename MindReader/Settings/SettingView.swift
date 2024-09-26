//
//  SettingView.swift
//  MindReader
//
//  Created by J oyce on 2024/9/26.
//

import Foundation
import SwiftUI

struct UserSettingsView: View {
    var body: some View {
        VStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .padding()
                .foregroundColor(.gray)

            Form {
                Section(header: Text("Account")) {
                    HStack {
                        Text("Username")
                        Spacer()
                        Text("John Doe")
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Email")
                        Spacer()
                        Text("johndoe@example.com")
                            .foregroundColor(.gray)
                    }
                }

                Section(header: Text("Settings")) {
                    Toggle(isOn: .constant(true)) {
                        Text("Enable Notifications")
                    }

                    Toggle(isOn: .constant(false)) {
                        Text("Dark Mode")
                    }
                }

                Section {
                    Button(action: {
                    }) {
                        Text("Log Out")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle("User Settings")
    }
}
