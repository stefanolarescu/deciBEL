//
//  HistoryViewController.swift
//  deciBEL
//
//  Created by Stefan Olarescu on 08/03/2020.
//  Copyright © 2020 Stefan Olarescu. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {

    // MARK: - OUTLETS
    @IBOutlet weak var tableView: UITableView?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    
    // MARK: - PROPERTIES
    var groupedRecordings = [String: [Recording]]()
    
    let recordingsHeaderCellIdentifier = "RecordingsHeaderCell"
    let recordingCellIdentifier = "RecordingCell"
    
    let coreDataModel = CoreDataModel.shared
    
    // MARK: - INIT METHOD
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        tabBarItem = UITabBarItem(
            title: GeneralStrings.History,
            image: UIImage(systemName: "clock.fill"),
            selectedImage: UIImage(systemName: "clock.fill")
        )
    }
    
    // MARK: - LIFE CYCLE METHODS
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        tableView?.isHidden = true
        activityIndicator?.isHidden = false
        activityIndicator?.startAnimating()
        
        coreDataModel.getRecordings { recordings in
            if let unwrappedRecordings = recordings {
                groupRecordings(unwrappedRecordings)
                
                DispatchQueue.main.async {
                    self.activityIndicator?.isHidden = true
                    self.activityIndicator?.stopAnimating()
                    self.tableView?.isHidden = false
                    
                    self.tableView?.reloadData()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = GeneralStrings.History
        
        tableView?.delegate = self
        tableView?.dataSource = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        activityIndicator?.stopAnimating()
    }
}

// MARK: - TABLE VIEW DELEGATE
extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedRecordings.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let index = groupedRecordings.index(groupedRecordings.startIndex, offsetBy: section)
        if let recordings = groupedRecordings[groupedRecordings.keys[index]] {
            return recordings.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let months = Array(groupedRecordings.keys)
        
        let header = tableView.dequeueReusableCell(withIdentifier: recordingsHeaderCellIdentifier)!
        
        let monthLabel = header.viewWithTag(1) as! UILabel
        monthLabel.text = months[section]
        
        return header.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: recordingCellIdentifier, for: indexPath) as! RecordingTableViewCell
        
        let index = groupedRecordings.index(groupedRecordings.startIndex, offsetBy: indexPath.section)
        if let recording = groupedRecordings[groupedRecordings.keys[index]]?[indexPath.row] {
            cell.configure(
                date: recording.date,
                decibels: Int(recording.decibels),
                latitude: recording.latitude,
                longitude: recording.longitude
            )
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 118
    }
    
    private func groupRecordings(_ recordings: [Recording]) {
        groupedRecordings.removeAll()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        dateFormatter.locale = Locale.current
        
        for recording in recordings {
            let month = dateFormatter.string(from: recording.date)
            if let insertedRecordings = groupedRecordings[month] {
                var updatedRecordings = insertedRecordings
                updatedRecordings.append(recording)
                groupedRecordings.updateValue(updatedRecordings, forKey: month)
            } else {
                groupedRecordings[month] = [recording]
            }
        }
    }
}
