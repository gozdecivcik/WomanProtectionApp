import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var annotations: [MKPointAnnotation]
    var userLocation: CLLocationCoordinate2D
    var feedbacks: [Feedback] = [] // bu satırı property olarak ekle


    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.setRegion(region, animated: false)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
        uiView.removeAnnotations(uiView.annotations)
        uiView.addAnnotations(annotations)
        
        for feedback in feedbacks {
            if let lat = feedback.latitude, let lon = feedback.longitude {
                let annotation = FeedbackAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                annotation.title = feedback.feedbackText
                annotation.subtitle = "feedback"
                annotation.image = feedback.uiImage
                uiView.addAnnotation(annotation)
            }
        }

    }
    

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }

            let identifier = "Pin"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

            if view == nil {
                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view?.canShowCallout = true
            } else {
                view?.annotation = annotation
            }

            if let subtitle = annotation.subtitle ?? "" {
                if subtitle.contains("hospital") || subtitle.contains("hastane") {
                    view?.markerTintColor = .red
                } else if subtitle.contains("police") || subtitle.contains("karakol") {
                    view?.markerTintColor = .blue
                } else if subtitle.contains("feedback") {
                    view?.markerTintColor = .orange
                    view?.glyphImage = UIImage(systemName: "exclamationmark.triangle.fill")

                    // Yorum etiketi
                    let commentLabel = UILabel()
                    commentLabel.text = annotation.title ?? "Geri Bildirim"
                    commentLabel.font = .systemFont(ofSize: 14, weight: .medium)
                    commentLabel.numberOfLines = 0
                    commentLabel.textAlignment = .center

                    // Tarih etiketi (örnek)
                    let dateLabel = UILabel()
                    dateLabel.text = "🕒 \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))"
                    dateLabel.font = .systemFont(ofSize: 10)
                    dateLabel.textColor = .darkGray
                    dateLabel.textAlignment = .center

                    // Yığın görünüm
                    let stack = UIStackView(arrangedSubviews: [commentLabel, dateLabel])
                    stack.axis = .vertical
                    stack.spacing = 6
                    stack.alignment = .center
                    stack.distribution = .fill

                    if let feedbackAnnotation = annotation as? FeedbackAnnotation,
                       let image = feedbackAnnotation.image {
                        let imageView = UIImageView(image: image)
                        imageView.contentMode = .scaleAspectFill
                        imageView.clipsToBounds = true
                        imageView.layer.cornerRadius = 8
                        imageView.layer.borderWidth = 0.5
                        imageView.layer.borderColor = UIColor.lightGray.cgColor
                        imageView.translatesAutoresizingMaskIntoConstraints = false
                        imageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
                        imageView.heightAnchor.constraint(equalToConstant: 90).isActive = true

                        stack.addArrangedSubview(imageView)
                    }

                    // Arka planı temiz ve sade bir kutu yap
                    let container = UIView()
                    container.addSubview(stack)
                    stack.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
                        stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
                        stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
                        stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8)
                    ])

                    container.backgroundColor = UIColor.systemBackground
                    container.layer.cornerRadius = 12
                    container.layer.shadowColor = UIColor.black.cgColor
                    container.layer.shadowOpacity = 0.1
                    container.layer.shadowRadius = 2
                    container.layer.shadowOffset = CGSize(width: 0, height: 1)

                    view?.detailCalloutAccessoryView = container
                }

            }

            return view
        }

    }
}


