//
//  ContentView.swift
//  CurrencyConverter
//
//  Created by Chukwuka Okwusiuno on 2024-05-31.
//

import SwiftUI

struct ContentView: View {
    @State private var itemSelected = 0
    @State private var itemSelected2 = 1
    @State private var amount : String = ""
    private let currencies = ["USD", "EUR", "GBP", "NGN", "CAD"]
    
    func convert(_ convert: String) -> String {
        var conversion: Double = 1.0
        let amount = Double(convert.doubleValue)
        let selectedCurrency = currencies[itemSelected]
        let to = currencies[itemSelected2]
        
        let euroRates = ["USD": 1.09, "EUR": 1.0, "GDP": 0.85, "NGN": 1450, "CAD": 1.48]
        let usdRates = ["USD": 1.0, "EUR": 0.92, "GDP": 0.79, "NGN": 1340, "CAD": 1.37]
        let gbpRates = ["USD": 1.27, "EUR": 1.17, "GDP": 1.0, "NGN": 1702, "CAD": 1.74]
        let cadRates = ["USD": 0.73, "EUR": 0.68, "GDP": 0.58, "NGN": 978.90, "CAD": 1.0]
        
        switch(selectedCurrency) {
        case "USD" :
            conversion = amount * (usdRates[to] ?? 0.0)
        case "EUR" :
            conversion = amount * (euroRates[to] ?? 0.0)
        case "GBP" :
            conversion = amount * (gbpRates[to] ?? 0.0)
        case "CAD" :
            conversion = amount * (cadRates[to] ?? 0.0)
        default:
            print("Something went wrong! please come back and try again later")
        }
        
        return String(format: "%.2f", conversion) 
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Convert a currency")) {
                    TextField("Enter an amount", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    Picker(selection: $itemSelected, label: Text("From")) {
                        ForEach(0 ..< currencies.count) {index in
                            Text(self.currencies[index]).tag(index)
                        }
                    }
                    
                    Picker(selection: $itemSelected2, label: Text("To")) {
                        ForEach(0 ..< currencies.count) {index in
                            Text(self.currencies[index]).tag(index)
                        }
                    }
                }
                Section(header: Text("Conversion")) {
                    Text("\(convert(amount)) \(currencies[itemSelected2])")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
