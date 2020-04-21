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
    
    @IBOutlet weak var decibelLabel: UILabel?
    
    @IBOutlet weak var rulerScrollContainerView: UIView?
    @IBOutlet weak var rulerScrollView: UIScrollView?
    @IBOutlet weak var rulerContentViewWidthConstraint: NSLayoutConstraint?

    @IBOutlet weak var levelsScrollContainerView: UIView?
    @IBOutlet weak var levelsScrollView: UIScrollView?
    @IBOutlet weak var levelsContentViewHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var levelsRedBackground: UIView?
    
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
        
        addPanGesture()
        
        decibelLabel?.text = AudioStrings.DecibelsA
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        configureRulerScrollView()
        configureLevelsScrollView()
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
    
    private func addPanGesture() {
        let mapPanGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(mapDragAction(_:))
        )
        mapPanGesture.delegate = self
        mapView?.addGestureRecognizer(mapPanGesture)
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
        
        timer = Timer(
            timeInterval: 1,
            target: self,
            selector: #selector(updateDecibels),
            userInfo: nil,
            repeats: true
        )
        RunLoop.main.add(timer, forMode: .common)
    }
    
    @objc private func stopRecording() {
        timer.invalidate()
        timer = Timer()
        
        audioKitManager.stopAudioKit()
    }
        
    @objc private func updateDecibels() {
        if let amplitude = audioKitManager.tracker?.amplitude {
            let decibels = round(20 * log10(amplitude) + 94, toNearest: 0.2, decimals: 1)
            
            if decibels >= 0, decibels <= Double(MAX_DECIBELS) {
                let rulerOffset = calculateRulerOffset(decibels: decibels)
                rulerScrollView?.setContentOffset(CGPoint(x: rulerOffset, y: 0), animated: true)
                
                let levelsOffset = calculateLevelsOffset(decibels: decibels)
                levelsScrollView?.setContentOffset(CGPoint(x: 0, y: levelsOffset), animated: true)
            }
        }
    }
    
    // MARK: Scroll View Methods
    private func calculateRulerOffset(decibels: Double) -> CGFloat {
        let leftOffset = CGFloat(5 * Int(decibels)) * RULER_SPACING
        let rightOffset = CGFloat(Int(decibels * 10) % 10) / 2 * RULER_SPACING
        return leftOffset + rightOffset - view.bounds.width / 2
    }
    
    private func calculateLevelsOffset(decibels: Double) -> CGFloat {
        guard let unwrappedLevelsScrollView = levelsScrollView else {
            return 0
        }
        
        var level = Int(round(decibels, toNearest: 10, decimals: 1)) / 10
        if level == 0 {
            level += 1
        }
        
        let offset = CGFloat(noiseLevels.count - level) * (ICON_SIZE + ICONS_SPACING)
        
        return offset - unwrappedLevelsScrollView.bounds.height / 2
    }
    
    private func configureRulerScrollView() {
        if let unwrappedRulerScrollContainerView = rulerScrollContainerView {
            
            let rulerGradientMask = CAGradientLayer()
            rulerGradientMask.frame = unwrappedRulerScrollContainerView.bounds
            rulerGradientMask.colors = [
                UIColor.clear.cgColor,
                UIColor.black.cgColor,
                UIColor.clear.cgColor
            ]
            rulerGradientMask.startPoint = CGPoint(x: 0.0, y: 0.5)
            rulerGradientMask.endPoint = CGPoint(x: 1.0, y: 0.5)
            unwrappedRulerScrollContainerView.layer.mask = rulerGradientMask
        }
        
        let horizontalInset = view.bounds.width / 2
        rulerScrollView?.contentInset = UIEdgeInsets(
            top: 0,
            left: horizontalInset,
            bottom: 0,
            right: horizontalInset
        )
        rulerContentViewWidthConstraint?.constant = CGFloat(MAX_DECIBELS * 5) * RULER_SPACING - view.bounds.width
        let offset = calculateRulerOffset(decibels: 30)
        rulerScrollView?.setContentOffset(
            CGPoint(x: offset, y: 0),
            animated: false
        )
    }
    
    private func configureLevelsScrollView() {
        if let unwrappedLevelsRedBackground = levelsRedBackground,
            let levelsViewContainer = unwrappedLevelsRedBackground.superview {
            
            levelsViewContainer.addSubview(LevelsView(frame: levelsViewContainer.bounds))
        }
        
        if let unwrappedLevelsScrollContainerView = levelsScrollContainerView,
            let unwrappedLevelsScrollView = levelsScrollView {
            
            let levelsGradientMask = CAGradientLayer()
            levelsGradientMask.frame = unwrappedLevelsScrollView.bounds
            levelsGradientMask.colors = [
                UIColor.clear.cgColor,
                UIColor.black.cgColor,
                UIColor.clear.cgColor
            ]
            unwrappedLevelsScrollContainerView.layer.mask = levelsGradientMask
        }
        
        if let unwrappedLevelsScrollView = levelsScrollView {
            let verticalInset = unwrappedLevelsScrollView.frame.height / 2
            levelsScrollView?.contentInset = UIEdgeInsets(
                top: verticalInset,
                left: 0,
                bottom: verticalInset,
                right: 0
            )
            levelsContentViewHeightConstraint?.constant = CGFloat(noiseLevels.count - 1) * (ICON_SIZE + ICONS_SPACING) - unwrappedLevelsScrollView.bounds.height
            let offset = calculateLevelsOffset(decibels: 30)
            levelsScrollView?.setContentOffset(
                CGPoint(x: 0, y: offset),
                animated: false
            )
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
