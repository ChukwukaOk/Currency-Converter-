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
                VStack(spacing: 20) {
                    headerView
                        .padding(.top, 40)
                    
                    currencyListView
                        .padding(.horizontal)
                    
                    startButton
                        .padding(.bottom, 40)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
        .background(Color.gray.opacity(0.05))
        .edgesIgnoringSafeArea(.all)
    }
    
    private var headerView: some View {
        Text("Currency Converter")
            .font(.system(size: 32, weight: .bold))
            .foregroundColor(.blue)
            .padding(.bottom, 20)
    }
    
    private var currencyListView: some View {
        VStack(spacing: 12) {
            ForEach(currencyData.indices, id: \.self) { index in
                currencyRow(info: currencyData[index])
            }
        }
    }
    
    private func currencyRow(info: CurrencyInfo) -> some View {
        HStack(spacing: 12) {
            Text(info.countryFlag)
                .font(.system(size: 30))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(info.code) (\(info.symbol))")
                    .font(.system(size: 16, weight: .semibold))
                
                Text(info.name)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var startButton: some View {
        Button(action: {
            showingConverter = true
        }) {
            Text("Start Converting")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
                .padding(.horizontal, 20)
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

