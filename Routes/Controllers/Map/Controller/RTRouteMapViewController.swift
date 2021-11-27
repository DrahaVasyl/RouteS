//
//  RTRouteMapViewController.swift
//  Routes
//
//  Created by Mac on 15.09.2021.
//

import Foundation
import UIKit
import GoogleMaps
import RxSwift
import CoreLocation
import MapKit
import Polyline

class RTRouteMapViewController: UIViewController {
    
    enum ActionButtonState {
        case start
        case arrived
        case finish
    }
    
    // MARK: - Properties
    
    private let viewModel: RTRouteMapViewModel
    private let disposeBag = DisposeBag()
    private let locationManager = CLLocationManager()
    private let router = RTRouteMapRouter()
    private let mapView = GMSMapView.map(withFrame: .zero, camera: .init(latitude: 0, longitude: 0, zoom: Design.defaultZoomLevel))
    private var markers = [RTMarker]()
    private var routes = [GMSPolyline]()
    private var actionButtonState: ActionButtonState = .start
    // MARK: UI
    private let topSafeAreaView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    private let topNavigationView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon-back-arrow"), for: .normal)
        button.contentEdgeInsets = .init(top: 10, left: 20, bottom: 10, right: 20)
        return button
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Available routes"
        label.textAlignment = .center
        label.font = UIFont.main(weight: .bold, size: 17)
        return label
    }()
    private let actionButtonView: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        view.backgroundColor = .clear
        view.shadowColor = UIColor.RGBA(33, 33, 33, 0.1)
        view.shadowOffset = .init(width: 0, height: 2)
        view.shadowRadius = 8
        view.shadowOpacity = 1
        view.isUserInteractionEnabled = true
        return view
    }()
    private let actionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.clipsToBounds = true
        button.cornerRadius = 27.5
        button.borderWidth = 1
        button.borderAlpha = 1
        button.borderColor = UIColor.RGBA(33, 33, 33, 0.1)
        return button
    }()
    
    // MARK: - Initialization
    
    init?(id: String) {
        if let viewModel = RTRouteMapViewModel(id: id) {
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        } else {
            return nil
        }
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        defaultConfigurations()
        subscribe()
    }
    
    // MARK: - Configurations
    
    private func configureLayout() {
        // Top Safe Area View
        view.addSubview(topSafeAreaView)
        topSafeAreaView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        // Top Navigation View
        view.addSubview(topNavigationView)
        topNavigationView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        // Back Button
        topNavigationView.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(64)
        }
        // Title Label
        topNavigationView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(backButton.snp.right)
            make.center.equalToSuperview()
            make.top.equalToSuperview()
        }
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(topNavigationView.snp.bottom)
        }
        // Start Button
        view.addSubview(actionButtonView)
        actionButtonView.snp.makeConstraints { make in
            make.right.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
        actionButtonView.addSubview(actionButton)
        actionButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(55)
            make.width.equalTo(70)
        }
    }
    
    private func defaultConfigurations() {
        backButton.addTapGestureRecognizer { [weak self] in
            self?.closeCurrentViewController()
        }
        titleLabel.text = viewModel.routeName
        mapView.isMyLocationEnabled = true
        mapView.setMinZoom(0, maxZoom: 15)
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        actionButtonView.addTapGestureRecognizer { [weak self] in
            self?.onActionButton()
        }
        updateActionButton(to: .start)
    }
    
    private func onActionButton() {
        switch actionButtonState {
        case .start:
            var to: CLLocationCoordinate2D?
            var from: CLLocationCoordinate2D?
            
            if let firstActiveMarker = markers.first(where: {$0.type.isActive}) {
                if let lastInactiveMarker = self.markers.last(where: {!$0.type.isActive}) {
                    to = firstActiveMarker.position
                    from = lastInactiveMarker.position
                } else {
                    to = firstActiveMarker.position
                    from = self.mapView.myLocation?.coordinate
                }
                
                if let firstCoordinate = from,
                   let secondCoordinate = to {
                    
                    self.routes.forEach({$0.map = nil})
                    self.routes.removeAll()
                    
                    self.handleNavigation(to: firstCoordinate, from: secondCoordinate)
                }
            }
        case .arrived:
            routes.forEach({$0.map = nil})
            routes.removeAll()
            if let marker = markers.first(where: {$0.type.isActive}) {
                marker.type = .inactive
                showBoundBox([marker.position])
            }
            if markers.contains(where: {$0.type.isActive}) {
                updateActionButton(to: .start)
            } else {
                updateActionButton(to: .finish)
            }
        case .finish:
            router.perform(.rate(id: viewModel.id), from: self, completion: nil)
        }
    }
    
    // MARK: - Helpers
    
    private func handleNavigation(to: CLLocationCoordinate2D, from: CLLocationCoordinate2D) {
        
        let completion: ((Result<Void, Error>) -> Void) = { [weak self] result in
            guard let self = self else { return }
            UIWindow.hideAnimation()
            switch result {
            case .failure(let error):
                self.router.perform(
                    .alert(
                        title: "Something went wrong",
                        message: error.localizedDescription),
                    from: self
                )
                
            case .success:
                self.showBoundBox([to, from])
            }
        }
        
        let operation = BlockOperation(block: {
            UIWindow.showAnimation(named: "building_route_loading_animation")
        })
        operation.queuePriority = .veryHigh
        OperationQueue.main.addOperation(operation)
        
        self.drawRoutes(from: from, to: to, completion: completion)
    }
    
    private func updateActionButton(to state: ActionButtonState) {
        func setTitle(to text: String) {
            actionButton.setAttributedTitle(
                NSAttributedString(
                    string: text,
                    attributes: [
                        .font: UIFont.main(size: 15),
                        .foregroundColor: UIColor.RGBA(33, 33, 33, 1)
                    ]),
                for: .normal)
        }
        
        actionButtonState = state
        switch state {
        case .arrived:
            setTitle(to: "Arrived")
        case .start:
            setTitle(to: "Navigate")
        case .finish:
            setTitle(to: "Complete")
        }
    }
}

// MARK: - Map -

extension RTRouteMapViewController {
    private func addMarkers(_ markers: [RTRouteMapViewModel.Data.Marker]) {
        var coordinates = markers.map({CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lon)})
        let mapMarkers = markers.map(createMarker)
        
        var old: [RTMarker] = []
        var notExisting: [RTMarker] = []
        let new = mapMarkers.filter { marker in
            return !self.markers.contains(where: { existingMarker in
                return existingMarker.sameTitle(with: marker) && existingMarker.samePosition(with: marker)
            })
        }
        self.markers.forEach { existingMarker in
            if mapMarkers.contains(where: { marker in
                return existingMarker.sameTitle(with: marker) && existingMarker.samePosition(with: marker)
            }) {
                old.append(existingMarker)
            } else {
                notExisting.append(existingMarker)
            }
        }
        notExisting.forEach({$0.map = nil})
        new.forEach({$0.map = mapView})
        old.forEach { marker in
            if let same = mapMarkers.first(where: {$0.samePosition(with: marker) && $0.sameTitle(with: marker)}) {
                marker.type = same.type
            }
        }
        
        self.markers = mapMarkers
        if let myLocation = locationManager.location?.coordinate {
            coordinates.append(myLocation)
        }
        showBoundBox(coordinates)
    }
    
    private func showBoundBox(_ list: [CLLocationCoordinate2D]) {
        var bounds = GMSCoordinateBounds()
        for location in list {
            bounds = bounds.includingCoordinate(location)
        }
            
        let update = GMSCameraUpdate.fit(bounds, withPadding: 100)
        mapView.animate(with: update)
    }
    
    private func createMarker(fromData data: RTRouteMapViewModel.Data.Marker) -> RTMarker {
        let marker = RTMarker(id: data.id, labelText: data.title)
        marker.type = {
            switch data.type {
            case .active:
                return .active
            case .inactive:
                return .inactive
            }
        }()
        marker.position = .init(latitude: data.lat, longitude: data.lon)
        return marker
    }
    
    private func createRequest(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> MKDirections.Request? {
        let origin = MKPlacemark(coordinate: from)
        let destination = MKPlacemark(coordinate: to)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: origin)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
            
        return request
    }
    
    private func drawRoutes(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, completion: ((Result<Void, Error>) -> Void)?) {
        let operation = BlockOperation(block: {
            guard let request = self.createRequest(from: from, to: to) else { return }
            
            let directions = MKDirections(request: request)
            directions.calculate { [weak self] (response, error) in
                guard let self = self else {
                    completion?(.failure(AppError.alreadyRelease))
                    return
                }
                guard let response = response else {
                    if let err = error {
                        completion?(.failure(err))
                    } else {
                        completion?(.failure(AppError.unexpectedOutput))
                    }
                    return
                }
                let polylines = self.googlePolylines(from: response)
                self.show(polylines: polylines)
                self.updateActionButton(to: .arrived)
                completion?(.success)
            }
        })

        operation.queuePriority = .veryLow

        OperationQueue.main.addOperation(operation)
    }
    
    private func googlePolylines(from response: MKDirections.Response) -> [GMSPolyline] {
        let polylines: [GMSPolyline] = response.routes.map({ route in
            let coordinates = route.polyline.coordinates
            let polyline = Polyline(coordinates: coordinates)
            let encodedPolyline: String = polyline.encodedPolyline
            let path = GMSPath(fromEncodedPath: encodedPolyline)
            return GMSPolyline(path: path)
        })
        return polylines
    }
    
    private func show(polylines: [GMSPolyline]) {
        routes = polylines
        polylines.forEach { polyline in
            polyline.strokeWidth = 2
            polyline.map = mapView
        }
    }
}

// MARK: - Delegate -

extension RTRouteMapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let value = marker as? RTMarker {
            router.perform(.placeInfo(id: value.id, shouldShowActions: markers.contains(where: {$0.type.isActive})), from: self, completion: nil)
        }
        return true
    }
}

extension RTRouteMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            locationManager.stopUpdatingLocation()
        }
    }
}

extension RTRouteMapViewController: RTPlaceInfoViewControllerDelegate {
    func onSkipButton(id: String, controller: RTPlaceInfoViewController) {
        controller.closeCurrentViewController()
        if let index = markers.firstIndex(where: {$0.id == id}) {
            for i in 0...index {
                markers[i].type = .inactive
            }
        }
        if !markers.contains(where: {$0.type.isActive}) {
            updateActionButton(to: .finish)
        }
    }
    
    func onNavigateButton(id: String, controller: RTPlaceInfoViewController) {
        controller.closeCurrentViewController()
        if let index = markers.firstIndex(where: {$0.id == id}) {
            for i in 0..<index {
                markers[i].type = .inactive
            }
            if let myLocation = self.mapView.myLocation?.coordinate {
                handleNavigation(to: markers[index].position, from: myLocation)
            }
        }
    }
}

extension RTRouteMapViewController: RTRateRouteViewControllerDelegate {
    func onCloseButtonClick(controller: RTRateRouteViewController) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func onApplyButtonClick(controller: RTRateRouteViewController) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - RX -

extension RTRouteMapViewController {
    private func subscribe() {
        subscribeViewModel()
    }
    
    private func subscribeViewModel() {
        viewModel.data.subscribe(onNext: { [weak self] data in
            guard let self = self,
                  let data = data else {
                return
            }
            self.addMarkers(data.markers)
            
        }).disposed(by: disposeBag)
    }
}

// MARK: - Constants -

extension RTRouteMapViewController {
    private struct Design {
        static let defaultZoomLevel: Float = 7
    }
}

extension MKMultiPoint {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid,
                                              count: pointCount)

        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))

        return coords
    }
}
