//
//  RecordViewController.swift
//  deciBEL
//
//  Created by Stefan Olarescu on 14/03/2020.
//  Copyright © 2020 Stefan Olarescu. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AVFoundation

class RecordViewController: UIViewController {

    // MARK: - OUTLETS
    @IBOutlet weak var mapView: MKMapView?
    @IBOutlet weak var centerContainerView: UIView?
    @IBOutlet weak var zoomInContainerView: UIView?
    @IBOutlet weak var zoomOutContainerView: UIView?
            
    // MARK: - PROPERTIES
    let locationManager = CLLocationManager()
    var lastCenteredLocation = CLLocationCoordinate2D()
    var regionMeters: Double = 1000
    var mapViewIsCentered = false {
        didSet {
            centerContainerView?.animateCenterImageView(duration: 0.3, delay: 0, enabled: mapViewIsCentered)
        }
    }
    
    var timer = Timer()
    
    let audioSession = AVAudioSession.sharedInstance()
    let audioKitManager = AudioKitManager.shared
    
    // MARK: - LIFE CYCLE METHODS
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(checkPermissions),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(stopRecording),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkPermissions()
        
        let mapPanGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(mapDragAction(_:))
        )
        mapPanGesture.delegate = self
        mapView?.addGestureRecognizer(mapPanGesture)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        regionMeters = 1000
        
        stopRecording()
    }
    
    // MARK: - OTHER METHODS
    
    // MARK: Notification Center Methods
    @objc private func checkPermissions() {
        checkLocationServices()
        checkMicrophoneAuthorization()
    }
    
    // MARK: Location Methods
    private func checkLocationServices() {
        if locationServicesAreEnabled {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            present(
                showAlertForLocationServices(
                    title: LocationStrings.LocationServicesDisabled,
                    message: LocationStrings.LocationServicesAlertMessage,
                    style: .alert
                ),
                animated: true
            )
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            mapView?.showsUserLocation = true
            if let currentLocation = locationManager.location?.coordinate {
                centerMapViewOnLocation(currentLocation)
            }
            locationManager.startUpdatingLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
    private func centerMapViewOnLocation(_ location: CLLocationCoordinate2D) {
        lastCenteredLocation = location
        let region = MKCoordinateRegion(
            center: location,
            latitudinalMeters: regionMeters,
            longitudinalMeters: regionMeters
        )
        mapView?.setRegion(region, animated: true)
        mapViewIsCentered = true
    }
    
    // MARK: Map Controls Methods
    @IBAction func centerRegionAction(_ sender: UITapGestureRecognizer) {
        mapViewIsCentered = !mapViewIsCentered
        if mapViewIsCentered {
            regionMeters = 1000
            centerMapViewOnLocation(lastCenteredLocation)
        }
    }
    
    @IBAction func zoomInAction(_ sender: UITapGestureRecognizer) {
        zoomInContainerView?.animateZoomContainerView(duration: 0.6, delay: 0)
        zoomAction(type: .zoomIn)
    }
    
    @IBAction func zoomOutAction(_ sender: UITapGestureRecognizer) {
        zoomOutContainerView?.animateZoomContainerView(duration: 0.6, delay: 0)
        zoomAction(type: .zoomOut)
    }
    
    private func zoomAction(type: Zoom) {
        if mapView != nil {
            var region = mapView!.region
            var span = MKCoordinateSpan()
            span.latitudeDelta = type == .zoomIn ? region.span.latitudeDelta / 2 : region.span.latitudeDelta * 2
            span.longitudeDelta = type == .zoomIn ? region.span.longitudeDelta / 2 : region.span.longitudeDelta * 2
            region.span = span
            mapView?.setRegion(region, animated: true)
            
            regionMeters = type == .zoomIn ? regionMeters / 2 : regionMeters * 2
        }
    }
    
    @IBAction func mapDragAction(_ sender: UISwipeGestureRecognizer) {
        if sender.state == .began {
            mapViewIsCentered = false
        }
    }
    
    // MARK: Microphone Methods
    private func checkMicrophoneAuthorization() {
        switch audioSession.recordPermission {
        case .granted:
            startRecording()
        case .undetermined:
            audioSession.requestRecordPermission { granted in
                if granted {
                    self.startRecording()
                } else {
                    self.stopRecording()
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        default:
            if let unwrappedNavigationController = navigationController {
                present(
                    showAlertForMicrophoneAccess(
                        title: AudioStrings.MicrophoneAccessDisabled,
                        message: AudioStrings.MicrophoneAccessAlertMessage,
                        style: .alert,
                        navigationController: unwrappedNavigationController
                    ),
                    animated: true
                )
            }
        }
    }
    
    private func startRecording() {
        audioKitManager.startAudioKit()
        
        timer = .scheduledTimer(
            timeInterval: 0.25,
            target: self,
            selector: #selector(updateDecibels),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc private func stopRecording() {
        timer.invalidate()
        timer = Timer()
        
        audioKitManager.stopAudioKit()
    }
        
    @objc private func updateDecibels() {
        if let amplitude = audioKitManager.tracker?.amplitude {
            print(round(20 * log10(amplitude) + 94, toNearest: 0.2, decimals: 1))
        }
    }
}

// MARK: - LOCATION MANAGER DELEGATE
extension RecordViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last?.coordinate else {
            return
        }
        
        if mapViewIsCentered {
            centerMapViewOnLocation(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

// MARK: - GESTURE RECOGNIZER DELEGATE
extension RecordViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - AUDIO RECORDER DELEGATE
extension RecordViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        recorder.stop()
        recorder.deleteRecording()
        recorder.prepareToRecord()
    }
}
