//
//  ContentView.swift
//  CurrencyConverter
//
//  Created by Chukwuka Okwusiuno on 2024-05-31.
//

import SwiftUI

struct CurrencyInfo {
    let code: String
    let symbol: String
    let countryFlag: String
    let name: String
}

let currencyData: [CurrencyInfo] = [
    CurrencyInfo(code: "USD", symbol: "$", countryFlag: "🇺🇸", name: "US Dollar"),
    CurrencyInfo(code: "EUR", symbol: "€", countryFlag: "🇪🇺", name: "Euro"),
    CurrencyInfo(code: "GBP", symbol: "£", countryFlag: "🇬🇧", name: "British Pound"),
    CurrencyInfo(code: "NGN", symbol: "₦", countryFlag: "🇳🇬", name: "Nigerian Naira"),
    CurrencyInfo(code: "CAD", symbol: "C$", countryFlag: "🇨🇦", name: "Canadian Dollar"),
    CurrencyInfo(code: "JPY", symbol: "¥", countryFlag: "🇯🇵", name: "Japanese Yen"),
    CurrencyInfo(code: "INR", symbol: "₹", countryFlag: "🇮🇳", name: "Indian Rupee")
    
    
]

struct CurrencyConverterView: View {
    @State private var amount = ""
    @State private var itemSelected = 0
    @State private var itemSelected2 = 1
    @State private var exchangeRates: [String: Double] = [:]
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let apiKey = "9ee36a6f116ab8beef5d9db2"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView("Loading rates...")
                }
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                HStack {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text(currencyData[itemSelected].symbol)
                }
                .padding()
                
                HStack {
                    Picker("From", selection: $itemSelected) {
                        ForEach(currencyData.indices, id: \.self) { index in
                            HStack {
                                Text(currencyData[index].countryFlag)
                                Text(currencyData[index].code)
                            }.tag(index)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Text("to")
                    
                    Picker("To", selection: $itemSelected2) {
                        ForEach(currencyData.indices, id: \.self) { index in
                            HStack {
                                Text(currencyData[index].countryFlag)
                                Text(currencyData[index].code)
                            }.tag(index)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Text("Converted Amount: \(convert(amount))")
                    .font(.headline)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Currency Converter")
            .onAppear(perform: fetchRates)
        }
    }
    
    func fetchRates() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "https://v6.exchangerate-api.com/v6/\(apiKey)/latest/USD") else {
            errorMessage = "Invalid URL"
            return
        }
        
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
    
    func convert(_ amount: String) -> String {
        guard let amountValue = Double(amount),
              let fromRate = exchangeRates[currencyData[itemSelected].code],
              let toRate = exchangeRates[currencyData[itemSelected2].code] else {
            return "0.00"
        }
        
        let inUSD = amountValue / fromRate
        let converted = inUSD * toRate
        return String(format: "%.2f", converted)
    }
}

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
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 12) { // Further reduced spacing
                    headerView
                        .padding(.top, 20) // Further reduced top padding
                    
                    currencyListView
                        .padding(.horizontal)
                    
                    startButton
                        .padding(.bottom, 20) // Further reduced bottom padding
                }
                .frame(minHeight: geometry.size.height)
            }
        }
        .background(Color.gray.opacity(0.05))
        .edgesIgnoringSafeArea(.all)
    }
    
    private var headerView: some View {
        Text("Currency Converter")
            .font(.system(size: 24, weight: .bold)) // Further reduced font size
            .foregroundColor(.blue)
            .padding(.bottom, 12) // Further reduced bottom padding
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var currencyListView: some View {
        VStack(spacing: 6) { // Further reduced spacing
            ForEach(currencyData.indices, id: \.self) { index in
                currencyRow(info: currencyData[index])
            }
        }
    }
    
    private func currencyRow(info: CurrencyInfo) -> some View {
        VStack(spacing: 4) { // Further reduced spacing
            Text(info.countryFlag)
                .font(.system(size: 20)) // Further reduced flag size
            
            VStack(alignment: .center, spacing: 1) { // Further reduced spacing
                Text("\(info.code) (\(info.symbol))")
                    .font(.system(size: 12, weight: .semibold)) // Further reduced font size
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text(info.name)
                    .font(.system(size: 10)) // Further reduced font size
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(.vertical, 6) // Further reduced padding
        .padding(.horizontal, 8) // Further reduced padding
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(8) // Further reduced corner radius
        .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1) // Further reduced shadow
    }
    
    private var startButton: some View {
        Button(action: {
            showingConverter = true
        }) {
            Text("Start Converting")
                .font(.system(size: 14, weight: .semibold)) // Further reduced font size
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10) // Further reduced padding
                .background(Color.blue)
                .cornerRadius(8) // Further reduced corner radius
                .padding(.horizontal, 12) // Further reduced horizontal padding
        }
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




