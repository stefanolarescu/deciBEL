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
    
    @IBOutlet weak var timeLeftLabel: UILabel?
    
    @IBOutlet weak var rulerScrollContainerView: UIView?
    @IBOutlet weak var rulerScrollView: UIScrollView?
    @IBOutlet weak var rulerContentViewWidthConstraint: NSLayoutConstraint?
    @IBOutlet weak var numbersView: NumbersView?
    
    @IBOutlet weak var decibelLabel: UILabel?

    @IBOutlet weak var levelsScrollContainerView: UIView?
    @IBOutlet weak var levelsScrollView: UIScrollView?
    @IBOutlet weak var levelsContentViewHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var iconsView: IconsView?
    @IBOutlet weak var levelsView: LevelsView?
    
    @IBOutlet weak var reloadView: UIView?
    @IBOutlet weak var reloadHighlightView: UIView?
    
    // MARK: - PROPERTIES
    let locationManager = CLLocationManager()
    var lastCenteredLocation = CLLocationCoordinate2D()
    var regionMeters: Double = 1000
    var mapViewIsCentered = false {
        didSet {
            centerContainerView?.animateCenterImageView(duration: 0.3, delay: 0, enabled: mapViewIsCentered)
        }
    }
    
    var isRecording = false
    var startRecordingAutomatically = true
        
    var timeLeft = MEASUREMENT_TIME {
        didSet {
            timeLeftLabel?.text = "\(timeLeft)s"
            if timeLeft <= 3 {
                timeLeftLabel?.textColor = UIColor(named: "Red")
            }
            
            if timeLeft == 0 {
                isRecording = false
                stopRecording()
                
                DispatchQueue.main.async {
                    self.centerMeasuringLabel()
                    UIView.animate(withDuration: 0.4) {
                        self.timeLeftLabel?.alpha = 0
                    }
                }
            }
        }
    }
    
    var countdownTimer = Timer()
    var measureTimer = Timer()
    
    let saveViewControllerIdentifier = "SaveViewController"
    
    let audioSession = AVAudioSession.sharedInstance()
    let audioKitManager = AudioKitManager.shared
    
    var lastDecibelIndex = 0
    var lastLevelIndex = 0
    
    var decibels = [Double]()
        
    // MARK: - LIFE CYCLE METHODS
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(checkState),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(stopRecording),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        if !startRecordingAutomatically {
            checkRecording()
        }
        startRecordingAutomatically = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        title = AudioStrings.Record
        addMeasuringLabel()
        timeLeftLabel?.text = "\(timeLeft)s"
        
        checkState()
        
        addPanGesture()
        
        decibelLabel?.text = AudioStrings.DecibelsA
        
        configureRulerScrollView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureLevelsScrollView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        regionMeters = 1000
        
        stopRecording()
    }
    
    // MARK: - OTHER METHODS
    
    // MARK: Notification Center Methods
    @objc private func checkState() {
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
    
    // MARK: Measuring Methods
    @IBAction func reloadAction(_ sender: UITapGestureRecognizer) {
        reloadHighlightView?.highlight(duration: 0.4, delay: 0)
        reloadView?.rotate360(duration: 0.4, delay: 0) {
            self.resetCountdownTimer()
        }
    }
    
    private func resetCountdownTimer() {
        stopRecording()
        resetMeasuringLabel()
        decibels.removeAll()
    }
    
    
    // MARK: Microphone Methods
    private func checkMicrophoneAuthorization() {
        switch audioSession.recordPermission {
        case .granted:
            checkRecording()
        case .undetermined:
            audioSession.requestRecordPermission { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.resetCountdownTimer()
                    }
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
        
        isRecording = true
        
        measureTimer = Timer(
            timeInterval: 0.5,
            target: self,
            selector: #selector(updateDecibels),
            userInfo: nil,
            repeats: true
        )
        RunLoop.main.add(measureTimer, forMode: .common)
                
        countdownTimer = Timer(
            timeInterval: 1,
            target: self,
            selector: #selector(updateTimeLeft),
            userInfo: nil,
            repeats: true
        )
        RunLoop.main.add(countdownTimer, forMode: .common)
    }
    
    @objc private func stopRecording() {
        measureTimer.invalidate()
        measureTimer = Timer()
        countdownTimer.invalidate()
        countdownTimer = Timer()
                
        audioKitManager.stopAudioKit()
    }
        
    @objc private func updateDecibels() {
        if let amplitude = audioKitManager.amplitude {
            guard amplitude != 0 else {
                return
            }
            
            let doubleAmplitude = Double(amplitude)

            let decibels = roundDecibels(20 * log10(doubleAmplitude) + 74, toNearest: 0.2, decimals: 1)

            if decibels >= 0, decibels <= Double(MAX_DECIBELS) {
                self.decibels.append(decibels)
                if timeLeft != 0 {
                    setOffsets(decibels: decibels)
                }
            }
        }
    }
    
    func setOffsets(decibels: Double, animated: Bool = true) {
        let rulerOffset = calculateRulerOffset(decibels: decibels)
        rulerScrollView?.setContentOffset(CGPoint(x: rulerOffset, y: 0), animated: animated)
        animateRulerChange(decibels: decibels)
        
        let levelsOffset = calculateLevelsOffset(decibels: decibels)
        levelsScrollView?.setContentOffset(CGPoint(x: 0, y: levelsOffset), animated: animated)
        animateLevelChange(decibels: decibels)
    }
    
    @objc private func updateTimeLeft() {
        timeLeft -= 1
    }
    
    private func checkRecording() {
        if isRecording {
            stopRecording()
            present(
                showAlertForContinuingRecording { restart in
                    if restart {
                        self.resetCountdownTimer()
                    } else {
                        self.startRecording()
                    }
                },
                animated: true
            )
        } else if startRecordingAutomatically {
            startRecording()
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
        
        var level = Int(roundDecibels(decibels, toNearest: 10, decimals: 1)) / 10
        if level == 0 {
            level += 1
        } else if level == 13 {
            level -= 1
        }
        
        let offset = CGFloat(noiseLevels.count - level) * (ICON_SIZE + ICONS_SPACING)
        
        return offset - unwrappedLevelsScrollView.bounds.height / 2
    }
    
    private func animateRulerChange(decibels: Double) {
        if let numberLabels = numbersView?.subviews as? [UILabel] {
            let indexOfDecibels = Int(round(decibels))
            
            if self.lastDecibelIndex != indexOfDecibels {
                UIView.animate(
                    withDuration: 0.2,
                    animations: {
                        numberLabels[self.lastDecibelIndex].transform = CGAffineTransform(
                            scaleX: 0.6,
                            y: 0.6
                        )
                        if self.lastDecibelIndex - 1 >= 0 {
                            numberLabels[self.lastDecibelIndex - 1].transform = CGAffineTransform(
                                scaleX: 0.6,
                                y: 0.6
                            )
                        }
                        if self.lastDecibelIndex + 1 <= MAX_DECIBELS + 1 {
                            numberLabels[self.lastDecibelIndex + 1].transform = CGAffineTransform(
                                scaleX: 0.6,
                                y: 0.6
                            )
                        }
                    }
                ) { completed in
                    if completed {
                        UIView.animate(
                            withDuration: 0.2,
                            animations: {
                                numberLabels[indexOfDecibels].transform = CGAffineTransform(
                                    scaleX: 1,
                                    y: 1
                                )
                                if indexOfDecibels - 1 >= 0 {
                                    numberLabels[indexOfDecibels - 1].transform = CGAffineTransform(
                                        scaleX: 0.8,
                                        y: 0.8
                                    )
                                }
                                if indexOfDecibels + 1 <= MAX_DECIBELS + 1 {
                                    numberLabels[indexOfDecibels + 1].transform = CGAffineTransform(
                                        scaleX: 0.8,
                                        y: 0.8
                                    )
                                }
                            }
                        )
                    }
                }
                
                lastDecibelIndex = indexOfDecibels
            }
        }
    }
    
    private func getIndexOfCurrentLevel(decibels: Double) -> Int {
        var level = Int(roundDecibels(decibels, toNearest: 10, decimals: 1)) / 10
        if level == 0 {
            level += 1
        } else if level == 13 {
            level -= 1
        }
        return noiseLevels.count - level
    }
    
    private func animateLevelChange(decibels: Double) {
        if let levelLabels = levelsView?.subviews as? [UILabel],
            let iconViews = iconsView?.subviews as? [UIImageView] {
            
            let currentLevelIndex = getIndexOfCurrentLevel(decibels: decibels)
            
            if lastLevelIndex != currentLevelIndex {
                UIView.transition(
                    with: levelLabels[self.lastLevelIndex],
                    duration: 0.2,
                    options: .transitionCrossDissolve,
                    animations: {
                        levelLabels[self.lastLevelIndex].textColor = .black
                        iconViews[self.lastLevelIndex].tintColor = .black
                    }
                ) { completed in
                    if completed {
                        UIView.transition(
                            with: levelLabels[currentLevelIndex],
                            duration: 0.2,
                            options: .transitionCrossDissolve,
                            animations: {
                                levelLabels[currentLevelIndex].textColor = UIColor(named: "Red")
                                iconViews[currentLevelIndex].tintColor = UIColor(named: "Red")
                            }
                        )
                    }
                }
                
                lastLevelIndex = currentLevelIndex
            }
        }
    }
    
    private func configureRulerScrollView() {
        if let unwrappedRulerScrollContainerView = rulerScrollContainerView {
            
            let rulerGradientMask = CAGradientLayer()
            rulerGradientMask.frame = unwrappedRulerScrollContainerView.bounds
            rulerGradientMask.colors = [
                UIColor.clear.cgColor,
                UIColor.black.cgColor,
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
        var decibelsAverage = 30
        if decibels.count > 0 {
            decibelsAverage = Int(round(decibels.reduce(0.0, +) / Double(decibels.count)))
        }
        let offset = calculateLevelsOffset(decibels: Double(decibelsAverage))
        rulerScrollView?.setContentOffset(
            CGPoint(x: offset, y: 0),
            animated: false
        )
    }
    
    private func configureLevelsScrollView() {
        if let unwrappedLevelsScrollContainerView = levelsScrollContainerView {
            
            let levelsGradientMask = CAGradientLayer()
            levelsGradientMask.frame = unwrappedLevelsScrollContainerView.bounds
            levelsGradientMask.colors = [
                UIColor.clear.cgColor,
                UIColor.black.cgColor,
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
            var decibelsAverage = 30
            if decibels.count > 0 {
                decibelsAverage = Int(round(decibels.reduce(0.0, +) / Double(decibels.count)))
            }
            let offset = calculateLevelsOffset(decibels: Double(decibelsAverage))
            levelsScrollView?.setContentOffset(
                CGPoint(x: 0, y: offset),
                animated: false
            )
        }
    }
    
    // MARK: Other UI Methods
    private func addMeasuringLabel() {
        if let unwrappedTimeLeftLabel = timeLeftLabel,
            let goldBar = unwrappedTimeLeftLabel.superview {
                
            let measuringLabel = UILabel(frame: goldBar.bounds)
            measuringLabel.text = TimeStrings.Measuring
            measuringLabel.sizeToFit()
            measuringLabel.textColor = .black
            measuringLabel.font = .systemFont(ofSize: 14)
            measuringLabel.frame.origin.x = 8
            measuringLabel.center.y = goldBar.bounds.midY
            goldBar.addSubview(measuringLabel)
        }
    }
    
    private func centerMeasuringLabel() {
        if let goldBar = self.timeLeftLabel?.superview,
            goldBar.subviews.count == 2 {
            
            if let measuringLabel = goldBar.subviews[1] as? UILabel {
            
                UIView.transition(
                    with: measuringLabel,
                    duration: 0.4,
                    options: .transitionCrossDissolve,
                    animations: {
                        measuringLabel.text = String.localizedStringWithFormat(TimeStrings.MeasurementDone, "↺")
                        measuringLabel.sizeToFit()
                        measuringLabel.center.y = goldBar.bounds.midY
                    }
                ) { completed in
                    if completed {
                        UIView.animate(
                            withDuration: 0.4,
                            animations: {
                                measuringLabel.center.x = goldBar.center.x
                            }
                        ) { finished in
                            if finished {
                                self.presentResultViewController()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func resetMeasuringLabel() {
        if let goldBar = self.timeLeftLabel?.superview,
            goldBar.subviews.count == 2 {
            
            if let measuringLabel = timeLeftLabel?.superview?.subviews[1] as? UILabel {
            
                self.timeLeft = MEASUREMENT_TIME
                self.timeLeftLabel?.textColor = .black
                
                UIView.animate(
                    withDuration: 0.4,
                    animations: {
                        measuringLabel.frame.origin.x = 8
                        measuringLabel.center.y = goldBar.bounds.midY
                        self.timeLeftLabel?.alpha = 1
                    }
                ) { completed in
                    if completed {
                        UIView.transition(
                            with: measuringLabel,
                            duration: 0.4,
                            options: .transitionCrossDissolve,
                            animations: {
                                measuringLabel.text = TimeStrings.Measuring
                                measuringLabel.sizeToFit()
                                measuringLabel.center.y = goldBar.bounds.midY
                            }
                        ) { finished in
                            if finished {
                                self.startRecording()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func presentResultViewController() {
        let saveViewController = storyboard?.instantiateViewController(identifier: saveViewControllerIdentifier) as! SaveViewController
        saveViewController.modalPresentationStyle = .overCurrentContext
        saveViewController.delegate = self
        
        let count = decibels.count
        let decibelsAverage = Int(round(decibels.reduce(0.0, +) / Double(count)))
        saveViewController.averageDecibels = decibelsAverage
        saveViewController.date = Date()
        saveViewController.latitude = lastCenteredLocation.latitude
        saveViewController.longitude = lastCenteredLocation.longitude
        
        self.definesPresentationContext = true
        
        present(saveViewController, animated: true)
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

extension RecordViewController: SaveViewControllerDelegate {
    func setOffsetsDelegate(decibels: Double) {
        setOffsets(decibels: decibels, animated: false)
    }
    
    func segueToHistory() {
        tabBarController?.selectedIndex = 1
    }
}
