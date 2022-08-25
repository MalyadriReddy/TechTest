//
//  SearchTrainInteractorTests.swift
//  MyTravelHelperTests
//
//  Created by Mmalyadri on 25/08/22.
//  Copyright © 2022 Sample. All rights reserved.
//

import XCTest
import Foundation
import UIKit
@testable import MyTravelHelper

class SearchTrainInteractorTests: XCTestCase {

    var view: ViewToPresenterProtocol?
        var Interactor: PresenterToInteractorProtocol?
        var presenter = MockPresenter()
        var network = MockNetwork()
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

   

}

class MockPresenter: InteractorToPresenterProtocol {
    
    var expectation: XCTestExpectation?
    func stationListFetched(list: [Station]) {
        let staticList =  Responses.AllStation().stationsList
                XCTAssertEqual(staticList.count, list.count)
    }
    
    func fetchedTrainsList(trainsList: [StationTrain]?) {
        
        XCTAssertEqual(trainsList!.count, 1)
                expectation?.fulfill()
    }
    
    func showNoTrainAvailbilityFromSource() {
        XCTAssertEqual("No trains found", "No trains found")
    }
    
    func showNoInterNetAvailabilityMessage() {
        XCTAssertEqual("No Internet", "No Internet")
    }
}

enum NetworkError: Error {
    case badURL
}
class MockNetwork {
   // var currentError: ErrorMessages?
    func fetchallStations(resultHandler: @escaping (Result<Stations, NetworkError>) -> Void) {
        if NetworkError.self != nil {
            resultHandler(.failure(.badURL))
        } else {
            resultHandler(.success(Responses.AllStation()))
        }
    }
    
    func fetchTrainsFromSource(_ sourceRequest: URLRequest, resultHandler: @escaping (Result<[StationTrain], NetworkError>) -> Void) {
        if NetworkError.badURL != nil {
            resultHandler(.failure(.badURL))
        } else {
            resultHandler(.success(Responses.TrainList()))
        }
    }
    func proceesTrainListforDestinationCheck(_ sourceRequest: URLRequest,
                                             resultHandler: @escaping (Result<TrainMovementsData, NetworkError>) -> Void) {
        if NetworkError.badURL != nil {
            resultHandler(.failure(.badURL))
        } else {
            resultHandler(.success(Responses.TrainMovements()))
        }
    }
}

struct Responses {
    //MARK: TrainMovements
    static let trainMovements = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<ArrayOfObjTrainMovements xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"http://api.irishrail.ie/realtime/\">\r\n  <objTrainMovements>\r\n    <TrainCode>A867 </TrainCode>\r\n    <TrainDate>10 Jan 2021</TrainDate>\r\n    <LocationCode>BALNA</LocationCode>\r\n    <LocationFullName>Ballina</LocationFullName>\r\n    <LocationOrder>1</LocationOrder>\r\n    <LocationType>O</LocationType>\r\n    <TrainOrigin>Ballina</TrainOrigin>\r\n    <TrainDestination>Manulla Junction</TrainDestination>\r\n    <ScheduledArrival>00:00:00</ScheduledArrival>\r\n    <ScheduledDeparture>15:35:00</ScheduledDeparture>\r\n    <ExpectedArrival>00:00:00</ExpectedArrival>\r\n    <ExpectedDeparture>15:35:00</ExpectedDeparture>\r\n    <Arrival />\r\n    <Departure />\r\n    <AutoArrival />\r\n    <AutoDepart />\r\n    <StopType>C</StopType>\r\n  </objTrainMovements>\r\n  <objTrainMovements>\r\n    <TrainCode>A867 </TrainCode>\r\n    <TrainDate>10 Jan 2021</TrainDate>\r\n    <LocationCode>FXFRD</LocationCode>\r\n    <LocationFullName>Foxford</LocationFullName>\r\n    <LocationOrder>2</LocationOrder>\r\n    <LocationType>S</LocationType>\r\n    <TrainOrigin>Ballina</TrainOrigin>\r\n    <TrainDestination>Manulla Junction</TrainDestination>\r\n    <ScheduledArrival>15:46:30</ScheduledArrival>\r\n    <ScheduledDeparture>15:47:00</ScheduledDeparture>\r\n    <ExpectedArrival>15:46:30</ExpectedArrival>\r\n    <ExpectedDeparture>15:47:00</ExpectedDeparture>\r\n    <Arrival />\r\n    <Departure />\r\n    <AutoArrival />\r\n    <AutoDepart />\r\n    <StopType>N</StopType>\r\n  </objTrainMovements>\r\n  <objTrainMovements>\r\n    <TrainCode>A867 </TrainCode>\r\n    <TrainDate>10 Jan 2021</TrainDate>\r\n    <LocationCode>MNLAJ</LocationCode>\r\n    <LocationFullName>Manulla Junction</LocationFullName>\r\n    <LocationOrder>3</LocationOrder>\r\n    <LocationType>D</LocationType>\r\n    <TrainOrigin>Ballina</TrainOrigin>\r\n    <TrainDestination>Manulla Junction</TrainDestination>\r\n    <ScheduledArrival>16:03:00</ScheduledArrival>\r\n    <ScheduledDeparture>00:00:00</ScheduledDeparture>\r\n    <ExpectedArrival>16:03:00</ExpectedArrival>\r\n    <ExpectedDeparture>00:00:00</ExpectedDeparture>\r\n    <Arrival />\r\n    <Departure />\r\n    <AutoArrival />\r\n    <AutoDepart />\r\n    <StopType>-</StopType>\r\n  </objTrainMovements>\r\n</ArrayOfObjTrainMovements>"
    static func TrainMovements() -> TrainMovementsData {
        guard let object = try? XMLDecoder().decode(TrainMovementsData.self, from: Data(Responses.trainMovements.utf8))
            else {
            fatalError("Unable to decode static responses")
        }

        return object
    }

    //MARK: TrainList
    static let trainList = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<ArrayOfObjStationData xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"http://api.irishrail.ie/realtime/\">\r\n  <objStationData>\r\n    <Servertime>2021-01-10T14:07:28.81</Servertime>\r\n    <Traincode>A864 </Traincode>\r\n    <Stationfullname>Ballina</Stationfullname>\r\n    <Stationcode>BALNA</Stationcode>\r\n    <Querytime>14:07:28</Querytime>\r\n    <Traindate>10 Jan 2021</Traindate>\r\n    <Origin>Manulla Junction</Origin>\r\n    <Destination>Ballina</Destination>\r\n    <Origintime>13:43</Origintime>\r\n    <Destinationtime>14:11</Destinationtime>\r\n    <Status>No Information</Status>\r\n    <Lastlocation />\r\n    <Duein>4</Duein>\r\n    <Late>0</Late>\r\n    <Exparrival>14:11</Exparrival>\r\n    <Expdepart>00:00</Expdepart>\r\n    <Scharrival>14:11</Scharrival>\r\n    <Schdepart>00:00</Schdepart>\r\n    <Direction>To Ballina</Direction>\r\n    <Traintype>DMU</Traintype>\r\n    <Locationtype>D</Locationtype>\r\n  </objStationData>\r\n  <objStationData>\r\n    <Servertime>2021-01-10T14:07:28.81</Servertime>\r\n    <Traincode>A867 </Traincode>\r\n    <Stationfullname>Ballina</Stationfullname>\r\n    <Stationcode>BALNA</Stationcode>\r\n    <Querytime>14:07:28</Querytime>\r\n    <Traindate>10 Jan 2021</Traindate>\r\n    <Origin>Ballina</Origin>\r\n    <Destination>Manulla Junction</Destination>\r\n    <Origintime>15:35</Origintime>\r\n    <Destinationtime>16:03</Destinationtime>\r\n    <Status>No Information</Status>\r\n    <Lastlocation />\r\n    <Duein>88</Duein>\r\n    <Late>0</Late>\r\n    <Exparrival>00:00</Exparrival>\r\n    <Expdepart>15:35</Expdepart>\r\n    <Scharrival>00:00</Scharrival>\r\n    <Schdepart>15:35</Schdepart>\r\n    <Direction>To Manulla Junction</Direction>\r\n    <Traintype>DMU</Traintype>\r\n    <Locationtype>O</Locationtype>\r\n  </objStationData>\r\n</ArrayOfObjStationData>"
    
    static func TrainList() -> [StationTrain] {
        guard var object = try? XMLDecoder().decode(StationData.self, from: Data(Responses.trainList.utf8))
            else {
            fatalError("Unable to decode static responses")
        }
        object.trainsList[0].destinationDetails = self.TrainMovements().trainMovements[0]
        return object.trainsList
    }
    
//MARK: ALL Station
    static let allStation =
    "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<ArrayOfObjStation xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"http://api.irishrail.ie/realtime/\">\r\n  <objStation>\r\n    <StationDesc>Belfast</StationDesc>\r\n    <StationAlias />\r\n    <StationLatitude>54.6123</StationLatitude>\r\n    <StationLongitude>-5.91744</StationLongitude>\r\n    <StationCode>BFSTC</StationCode>\r\n    <StationId>228</StationId>  </objStation>\r\n</ArrayOfObjStation>"
    
    static func AllStation() -> Stations {
        guard let object = try? XMLDecoder().decode(Stations.self, from: Data(Responses.allStation.utf8))
            else {
            fatalError("Unable to decode static responses")
        }
        return object
    }
}
