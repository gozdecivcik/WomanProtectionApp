import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var feedbackVM = FeedbackViewModel()
    @State private var region = MKCoordinateRegion()
    @State private var nearbyPins: [MKPointAnnotation] = []
    @State private var searchQuery = ""
    @FocusState private var isSearchFocused: Bool
    @State private var searchCompleter = SearchCompleter()
    @State private var selectedCompletion: MKLocalSearchCompletion?

    var body: some View {
        ZStack(alignment: .top) {
            if let userLocation = locationManager.userLocation {
                MapViewRepresentable(
                    region: $region,
                    annotations: nearbyPins,
                    userLocation: userLocation,
                    feedbacks: feedbackVM.feedbacks
                )
                .onAppear {
                    if region.center.latitude == 0 {
                        region = MKCoordinateRegion(
                            center: userLocation,
                            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                        )
                        fetchNearbyPlaces(location: userLocation)
                        feedbackVM.fetchFeedbacks()

                    }
                }
            } else {
                ProgressView("Konum alınıyor...")
            }

            VStack(spacing: 8) {
                // 🔍 Arama çubuğu
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)

                    TextField("Yer ara...", text: $searchQuery)
                        .focused($isSearchFocused)
                        .onChange(of: searchQuery) { query in
                            searchCompleter.queryFragment = query
                        }
                        .onSubmit {
                            searchManually()
                        }

                    if isSearchFocused {
                        Button(action: {
                            searchQuery = ""
                            searchCompleter.results = []
                            isSearchFocused = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }

                }
                .padding(12)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .shadow(radius: 4)

                // 🔍 Otomatik tamamlama listesi
                if isSearchFocused && !searchCompleter.results.isEmpty {
                    List {
                        ForEach(searchCompleter.results, id: \.self) { completion in
                            VStack(alignment: .leading) {
                                Text(completion.title)
                                    .font(.body)
                                if !completion.subtitle.isEmpty {
                                    Text(completion.subtitle)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .onTapGesture {
                                searchQuery = completion.title
                                isSearchFocused = false
                                searchFromCompletion(completion)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .frame(maxHeight: 200)
                    .padding(.horizontal, 8)
                }

                Spacer()
            }
            .padding(.top, 32)

            // 📍 Konuma dön butonu
            Button(action: {
                if let loc = locationManager.userLocation {
                    region = MKCoordinateRegion(
                        center: loc,
                        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                    )
                    fetchNearbyPlaces(location: loc)
                }
            }) {
                Image(systemName: "location.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .padding(16)
            }
            .background(Color.white)
            .clipShape(Circle())
            .shadow(radius: 4)
            .padding(.bottom, 32)
            .padding(.trailing, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
        .edgesIgnoringSafeArea(.all)
    }

    func searchFromCompletion(_ completion: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request(completion: completion)
        MKLocalSearch(request: request).start { response, _ in
            guard let coordinate = response?.mapItems.first?.placemark.coordinate else { return }
            region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        }
    }

    func searchManually() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery
        MKLocalSearch(request: request).start { response, _ in
            guard let coordinate = response?.mapItems.first?.placemark.coordinate else { return }
            region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        }
    }

    func fetchNearbyPlaces(location: CLLocationCoordinate2D) {
        let types = ["hospital", "hastane", "police", "karakol"]
        var newPins: [MKPointAnnotation] = []
        let group = DispatchGroup()

        for type in types {
            group.enter()
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = type
            request.region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))

            MKLocalSearch(request: request).start { response, _ in
                if let items = response?.mapItems {
                    for item in items {
                        let distance = CLLocation(latitude: location.latitude, longitude: location.longitude)
                            .distance(from: CLLocation(latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude))
                        if distance <= 5000 {
                            let annotation = MKPointAnnotation()
                            annotation.title = item.name
                            annotation.subtitle = type
                            annotation.coordinate = item.placemark.coordinate
                            newPins.append(annotation)
                        }
                    }
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.nearbyPins = newPins
        }
    }
}

