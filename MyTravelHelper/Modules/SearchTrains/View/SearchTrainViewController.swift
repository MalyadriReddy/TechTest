//
//  SearchTrainViewController.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import UIKit
import SwiftSpinner
import DropDown

class SearchTrainViewController: UIViewController {
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var sourceTxtField: UITextField!
    @IBOutlet weak var trainsListTable: UITableView!

    var stationsList:[Station] = [Station]()
    var trains:[StationTrain] = [StationTrain]()
    
    var favTrains:[StationTrain] = [StationTrain]()
    var presenter:ViewToPresenterProtocol?
    var dropDown = DropDown()
    var transitPoints:(source:String,destination:String) = ("","")

    override func viewDidLoad() {
        super.viewDidLoad()
        trainsListTable.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        if stationsList.count == 0 {
            SwiftSpinner.useContainerView(view)
            SwiftSpinner.show("Please wait loading station list ....")
            presenter?.fetchallStations()
        }
    }

    @IBAction func searchTrainsTapped(_ sender: Any) {
        view.endEditing(true)
        
        if sourceTxtField.text != "" && destinationTextField.text != "" {
            showProgressIndicator(view: self.view)
            presenter?.searchTapped(source: transitPoints.source, destination: transitPoints.destination)
        }
        else {
            //show alert popup if source or destnation is empty
        }
        
    }
}

extension SearchTrainViewController:PresenterToViewProtocol {
    func showNoInterNetAvailabilityMessage() {
        trainsListTable.isHidden = true
        hideProgressIndicator(view: self.view)
        showAlert(title: "No Internet", message: "Please Check you internet connection and try again", actionTitle: "Okay")
    }

    func showNoTrainAvailbilityFromSource() {
        trainsListTable.isHidden = true
        hideProgressIndicator(view: self.view)
        showAlert(title: "No Trains", message: "Sorry No trains arriving source station in another 90 mins", actionTitle: "Okay")
    }

    func updateLatestTrainList(trainsList: [StationTrain]) {
        hideProgressIndicator(view: self.view)
        trains = trainsList
        trainsListTable.isHidden = false
        trainsListTable.reloadData()
    }

    func showNoTrainsFoundAlert() {
        trainsListTable.isHidden = true
        hideProgressIndicator(view: self.view)
        trainsListTable.isHidden = true
        showAlert(title: "No Trains", message: "Sorry No trains Found from source to destination in another 90 mins", actionTitle: "Okay")
    }

    func showAlert(title:String,message:String,actionTitle:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func showInvalidSourceOrDestinationAlert() {
        trainsListTable.isHidden = true
        hideProgressIndicator(view: self.view)
        showAlert(title: "Invalid Source/Destination", message: "Invalid Source or Destination Station names Please Check", actionTitle: "Okay")
    }

    func saveFetchedStations(stations: [Station]?) {
        if let _stations = stations {
          self.stationsList = _stations
        }
        SwiftSpinner.hide()
    }
}

extension SearchTrainViewController:UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        dropDown = DropDown()
        dropDown.anchorView = textField
        dropDown.direction = .bottom
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.dataSource = stationsList.map {$0.stationDesc}
        dropDown.selectionAction = { (index: Int, item: String) in
            if textField == self.sourceTxtField {
                self.transitPoints.source = item
            }else {
                self.transitPoints.destination = item
            }
            textField.text = item
        }
        dropDown.show()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dropDown.hide()
        return textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let inputedText = textField.text {
            var desiredSearchText = inputedText
            if string != "\n" && !string.isEmpty{
                desiredSearchText = desiredSearchText + string
            }else {
                desiredSearchText = String(desiredSearchText.dropLast())
            }

            dropDown.dataSource = stationsList.map {$0.stationDesc}
            dropDown.show()
            dropDown.reloadAllComponents()
        }
        return true
    }
}

extension SearchTrainViewController:UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trains.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "train", for: indexPath) as! TrainInfoCell
        let train = trains[indexPath.row]
        cell.trainCode.text = train.trainCode
        cell.souceInfoLabel.text = train.stationFullName
        cell.sourceTimeLabel.text = train.expDeparture
        if let _destinationDetails = train.destinationDetails {
            cell.destinationInfoLabel.text = _destinationDetails.locationFullName
            cell.destinationTimeLabel.text = _destinationDetails.expDeparture
        }
        let result = favTrains.first{ $0.trainCode == train.trainCode}
        if result == nil {
            cell.favImg.image = UIImage(named: "unFavIcon")
        }
        else {
            cell.favImg.image = UIImage(named: "favIcon")
        }
        cell.favButton.setTitle("", for: .normal)
        cell.favImg.tag = indexPath.row
        cell.favButton.addTarget(self, action: #selector(favButtonSelected), for: .touchUpInside)
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    @objc func favButtonSelected(_ sender: UIButton)
    {
        let selectedTrain = trains[sender.tag]
        
        let favTrain = StationTrain(trainCode: selectedTrain.trainCode, fullName: selectedTrain.stationFullName, stationCode: selectedTrain.stationCode, trainDate: selectedTrain.trainDate, dueIn: selectedTrain.dueIn, lateBy: selectedTrain.lateBy, expArrival: selectedTrain.expArrival, expDeparture: selectedTrain.expDeparture)
        
        let result = favTrains.first{ $0.trainCode == favTrain.trainCode}
        if result == nil {
            favTrains.append(favTrain)
        }
        trainsListTable.reloadData()
        print(favTrains)
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        let selectedTrain = trains[indexPath.row]
//
//        let favTrain = StationTrain(trainCode: selectedTrain.trainCode, fullName: selectedTrain.stationFullName, stationCode: selectedTrain.stationCode, trainDate: selectedTrain.trainDate, dueIn: selectedTrain.dueIn, lateBy: selectedTrain.lateBy, expArrival: selectedTrain.expArrival, expDeparture: selectedTrain.expDeparture)
//
//        let result = favTrains.first{ $0.trainCode == favTrain.trainCode}
//        if result == nil {
//            favTrains.append(favTrain)
//        }
//        trainsListTable.reloadData()
//        print(favTrains)
//
//    }
    
    
}
