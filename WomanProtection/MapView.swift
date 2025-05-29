import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion()
    @State private var nearbyPins: [MKPointAnnotation] = []
    @State private var searchQuery: String = ""
    @FocusState private var isSearchFocused: Bool
    @State private var forceCenter = true

    @StateObject private var searchCompleter = SearchCompleter()
    @State private var selectedCompletion: MKLocalSearchCompletion?

    var body: some View {
        ZStack(alignment: .top) {
            if let location = locationManager.userLocation {
                MapViewRepresentable(
                    region: $region,
                    annotations: nearbyPins,
                    forceCenter: $forceCenter,
                    userLocation: location
                )
                .onAppear {
                    if forceCenter {
                        region = MKCoordinateRegion(
                            center: location,
                            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                        )
                    }
                    fetchNearbyPlaces(query: "hospital OR police", location: location)
                }
            } else {
                ProgressView("Konum alınıyor...")
            }

            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)

                    TextField("Yakındaki yerleri ara...", text: $searchQuery)
                        .focused($isSearchFocused)
                        .onChange(of: searchQuery) { newValue in
                            searchCompleter.queryFragment = newValue
                        }
                        .onSubmit {
                            searchManually()
                        }

                    Button(action: {
                        searchQuery = ""
                        searchCompleter.results = []
                        isSearchFocused = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                .padding(12)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .shadow(radius: 4)

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
                            .contentShape(Rectangle())
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

            Button(action: {
                forceCenter = true
            }) {
                Image(systemName: "location.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .padding(16)
            }
            .background(Color.white)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            .padding(.bottom, 32)
            .padding(.trailing, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
        .edgesIgnoringSafeArea(.all)
    }

    func searchFromCompletion(_ completion: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request(completion: completion)
        MKLocalSearch(request: request).start { response, error in
            guard let coordinate = response?.mapItems.first?.placemark.coordinate else { return }
            DispatchQueue.main.async {
                updateRegion(to: coordinate)
            }
        }
    }

    func searchManually() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery
        MKLocalSearch(request: request).start { response, error in
            guard let coordinate = response?.mapItems.first?.placemark.coordinate else { return }
            DispatchQueue.main.async {
                updateRegion(to: coordinate)
            }
        }
    }

    func updateRegion(to location: CLLocationCoordinate2D) {
        region = MKCoordinateRegion(
            center: location,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    }

    func fetchNearbyPlaces(query: String, location: CLLocationCoordinate2D) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))

        MKLocalSearch(request: request).start { response, error in
            guard let items = response?.mapItems else { return }
            DispatchQueue.main.async {
                nearbyPins = items.map {
                    let annotation = MKPointAnnotation()
                    annotation.title = $0.name
                    annotation.coordinate = $0.placemark.coordinate
                    return annotation
                }
            }
        }
    }
}




