//
//  ExchangeRates.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import Dcrlibwallet

class ExchangeRates {
    struct Bittrex {
        private static let exchangeUrl = URL(string: "https://bittrex.com/api/v1.1/public/getticker?market=USDT-DCR")!
        
        static func fetch(callback: @escaping (NSDecimalNumber?) -> Void) {
            // use wrapper callback function to ensure that initial callback is always triggered in main thread.
            let fetchCompleteHandler = self.makeFetchCompleteHandler() { exchangeRate in
                DispatchQueue.main.async {
                    callback(exchangeRate)
                }
            }
            
            let userAgent = Settings.readStringValue(for: DcrlibwalletUserAgentConfigKey)
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 7
            sessionConfig.httpAdditionalHeaders = ["User-Agent": userAgent]
            
            let task = URLSession(configuration: sessionConfig).dataTask(with: exchangeUrl, completionHandler: fetchCompleteHandler)
            task.resume()
        }
        
        static func makeFetchCompleteHandler(callback: @escaping (NSDecimalNumber?) -> Void) -> ((Data?, URLResponse?, Error?) -> Void) {
            return { data, response, error in
                guard let data = data, error == nil else {
                    let errorDescription = error?.localizedDescription ?? "no data returned"
                    print("Bittrex exchange rate fetch error: \(errorDescription)")
                    callback(nil)
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: Any]
                    let resultNode = json["result"] as! NSDictionary
                    let lastReportedRate = resultNode["Last"] as! Double
                    let exchangeRate = Decimal(lastReportedRate) as NSDecimalNumber
                    callback(exchangeRate)
                } catch let error {
                    print("Error processing bittrex exchange rate response: \(error.localizedDescription)")
                    callback(nil)
                }
            }
        }
    }
}
