//
//  ContentView.swift
//  PicoController
//
//  Created by Stan Wancerski on 10/05/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var picoResponse: String = ""
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    @State private var numberA: String = ""
    @State private var numberB: String = ""

    // Replace with your Pico's actual IP address or hostname
    private let picoBaseURL = "http://192.168.4.1/"

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Pico HTTP Client")
                .font(.headline)
            HStack {
                TextField("Number A", text: $numberA)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Number B", text: $numberB)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            if isLoading {
                ProgressView("Contacting Pico...")
            }
            if let error = errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            }
            if !picoResponse.isEmpty {
                Text(picoResponse)
                    .font(.title)
                    .padding()
            }
            Button("Send Request") {
                sendRequest()
            }
            .disabled(isLoading || numberA.isEmpty || numberB.isEmpty)
        }
        .padding()
    }

    private func sendRequest() {
        picoResponse = ""
        errorMessage = nil
        isLoading = true

        guard let a = Int(numberA), let b = Int(numberB) else {
            errorMessage = "Please enter valid numbers"
            isLoading = false
            return
        }

        // Build URL with query parameters as expected by Pico's main.cpp
        guard let url = URL(string: "\(picoBaseURL)?input1=\(a)&input2=\(b)") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    errorMessage = "Invalid response"
                    return
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    errorMessage = "HTTP Error: \(httpResponse.statusCode)"
                    return
                }
                guard let data = data, let body = String(data: data, encoding: .utf8) else {
                    errorMessage = "No data or invalid encoding"
                    return
                }
                picoResponse = "Result: \(body)"
            }
        }
        task.resume()
    }

}

#Preview {
    ContentView()
}
