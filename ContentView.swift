//
//  ContentView.swift
//  CurrencyConverter
//
//  Created by Chukwuka Okwusiuno on 2024-05-31.
//

import SwiftUI

struct ContentView: View {
    @State private var showingConverter = false
    
    var body: some View {
        if showingConverter {
            CurrencyConverterView()
        } else {
            WelcomeView(showingConverter: $showingConverter)
        }
    }
}

struct WelcomeView: View {
    @Binding var showingConverter: Bool
    let currencies = ["$", "€", "£", "₦", "C$", "¥", "₹"]
    
    var body: some View {
        mainContent
    }
    
    private var mainContent: some View {
        VStack(spacing: 30) {
            Spacer() // Add top spacer for vertical centering
            
            headerView
            currencySymbolsView
            startButton
            
            Spacer() // Add bottom spacer for vertical centering
        }
        .background(Color.gray.opacity(0.05))
        .edgesIgnoringSafeArea(.all)
    }
    
    private var headerView: some View {
        Text("Currency Converter")
            .font(.system(size: 32, weight: .bold))
            .foregroundColor(.blue)
    }
    
    private var currencySymbolsView: some View {
        ZStack {
            ForEach(currencies.indices, id: \.self) { index in
                currencySymbol(at: index)
            }
        }
        .frame(height: 250) // Slightly reduced height
        .padding(.vertical)
    }
    
    private func currencySymbol(at index: Int) -> some View {
        Text(currencies[index])
            .font(.system(size: 28))
            .foregroundColor(.blue)
            .padding(15)
            .background(
                Circle()
                    .fill(Color.white)
                    .shadow(color: .gray.opacity(0.2), radius: 8)
            )
            .offset(
                x: CGFloat(cos(Double(index) * 2 * .pi / Double(currencies.count)) * 70), // Slightly reduced radius
                y: CGFloat(sin(Double(index) * 2 * .pi / Double(currencies.count)) * 70)
            )
    }
    
    private var startButton: some View {
        Button(action: {
            showingConverter = true
        }) {
            HStack {
                Text("Start Converting")
                    .font(.headline)
                Image(systemName: "arrow.right")
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(15)
            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal, 40)
    }
}

struct CurrencyConverterView: View {
    @State private var itemSelected = 0
    @State private var itemSelected2 = 1
    @State private var amount: String = ""
    @State private var exchangeRates: [String: Double] = [:]
    @State private var isLoading = true
    @State private var errorMessage: String?
    private let currencies = ["USD", "EUR", "GBP", "NGN", "CAD", "CNY", "INR"]
    
    private let apiKey = "9ee36a6f116ab8beef5d9db2"
    
    var body: some View {
        NavigationView {
            mainContent
        }
    }
    
    private var mainContent: some View {
        ZStack {
            FormContent
            
            if isLoading {
                loadingOverlay
            }
        }
        .navigationTitle("Currency Converter")
        .onAppear {
            if exchangeRates.isEmpty {
                fetchExchangeRates()
            }
        }
    }
    
    private var loadingOverlay: some View {
        Color.black.opacity(0.1)
            .edgesIgnoringSafeArea(.all)
            .overlay(ProgressView())
    }
    
    private var FormContent: some View {
        Form {
            currencyInputSection
            conversionResultSection
        }
    }
    
    private var currencyInputSection: some View {
        Section(header: Text("Convert a currency")) {
            TextField("Enter an amount", text: $amount)
                .keyboardType(.decimalPad)
            
            currencyFromPicker
            currencyToPicker
        }
    }
    
    private var currencyFromPicker: some View {
        Picker(selection: $itemSelected, label: Text("From")) {
            ForEach(0 ..< currencies.count) { index in
                Text(self.currencies[index]).tag(index)
            }
        }
    }
    
    private var currencyToPicker: some View {
        Picker(selection: $itemSelected2, label: Text("To")) {
            ForEach(0 ..< currencies.count) { index in
                Text(self.currencies[index]).tag(index)
            }
        }
    }
    
    private var conversionResultSection: some View {
        Section(header: Text("Conversion")) {
            if isLoading {
                HStack {
                    Spacer()
                    ProgressView("Loading rates...")
                    Spacer()
                }
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else {
                Text("\(convert(amount)) \(currencies[itemSelected2])")
            }
        }
    }
    
    func fetchExchangeRates() {
        guard let url = URL(string: "https://v6.exchangerate-api.com/v6/\(apiKey)/latest/USD") else {
            errorMessage = "Invalid URL"
            return
        }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    errorMessage = "No data received"
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(ExchangeRates.self, from: data)
                    exchangeRates = result.rates
                } catch {
                    errorMessage = "Failed to decode data: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func convert(_ convert: String) -> String {
        guard let amountValue = Double(convert),
              let fromRate = exchangeRates[currencies[itemSelected]],
              let toRate = exchangeRates[currencies[itemSelected2]] else {
            return "0.00"
        }
        
        let inUSD = amountValue / fromRate
        let converted = inUSD * toRate
        return String(format: "%.2f", converted)
    }
}

struct ExchangeRates: Codable {
    let result: String
    let rates: [String: Double]
    
    enum CodingKeys: String, CodingKey {
        case result = "result"
        case rates = "conversion_rates"
    }
}

#Preview {
    ContentView()
}

