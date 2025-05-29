//
//  SearchCompleter.swift
//  WomanProtection
//
//  Created by Zeynep on 29.05.2025.
//

import Foundation
import MapKit

class SearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    private let completer: MKLocalSearchCompleter

    @Published var results: [MKLocalSearchCompletion] = []
    var queryFragment: String {
        didSet {
            completer.queryFragment = queryFragment
        }
    }

    override init() {
        completer = MKLocalSearchCompleter()
        queryFragment = ""
        super.init()
        completer.delegate = self
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.results = completer.results
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Arama tamamlayıcı hatası: \(error.localizedDescription)")
    }
}

