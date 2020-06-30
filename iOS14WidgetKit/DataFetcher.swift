//
//  CoronaDataFetcher.swift
//  iOS14WidgetKit
//
//  Created by Anupam Chugh on 30/06/20.
//

import Foundation
import Combine


public class DataFetcher : ObservableObject{
    
    
    @Published var coronaOutbreak = (totalCases: "...", totalRecovered: "...", totalDeaths: "...")

   var urlBase = "https://services1.arcgis.com/0MSEUqKaxRlEPj5g/arcgis/rest/services/ncov_cases/FeatureServer/1/query"
    
    var cancellable : Set<AnyCancellable> = Set()
    
    static let shared = DataFetcher()

    func fetchData(completion: @escaping ((Int, Int, Int)) -> Void)
    {
        var urlComponents = URLComponents(string: urlBase)!
        urlComponents.queryItems = [
            URLQueryItem(name: "f", value: "json"),
            URLQueryItem(name: "where", value: "Confirmed > 0"),
            URLQueryItem(name: "geometryType", value: "esriGeometryEnvelope"),
            URLQueryItem(name: "spatialRef", value: "esriSpatialRelIntersects"),
            URLQueryItem(name: "outFields", value: "*"),
            URLQueryItem(name: "orderByFields", value: "Confirmed desc"),
            URLQueryItem(name: "resultOffset", value: "0"),
            URLQueryItem(name: "cacheHint", value: "true")
        ]

        URLSession.shared.dataTaskPublisher(for: urlComponents.url!)
            
            .map{$0.data}
            .decode(type: CoronaResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
 
        }) { response in
            
            completion(self.casesByProvince(response: response))
        }
        .store(in: &cancellable)
    }
    
    func getJokes(completion: @escaping ([ChuckValue]?) -> Void){
        
        let urlComponents = URLComponents(string: "http://api.icndb.com/jokes/random/10/")!
        
        URLSession.shared.dataTaskPublisher(for: urlComponents.url!)
            .map{$0.data}
            .decode(type: ChuckJokes.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
 
        }) { response in
                self.coronaOutbreak.totalCases = "\(response.value)"
            completion(response.value)
        }
        .store(in: &cancellable)
    }
    
    func fetchCoronaCases()
    {
        
        var urlComponents = URLComponents(string: urlBase)!
        urlComponents.queryItems = [
            URLQueryItem(name: "f", value: "json"),
            URLQueryItem(name: "where", value: "Confirmed > 0"),
            URLQueryItem(name: "geometryType", value: "esriGeometryEnvelope"),
            URLQueryItem(name: "spatialRef", value: "esriSpatialRelIntersects"),
            URLQueryItem(name: "outFields", value: "*"),
            URLQueryItem(name: "orderByFields", value: "Confirmed desc"),
            URLQueryItem(name: "resultOffset", value: "0"),
            URLQueryItem(name: "cacheHint", value: "true")
        ]

        URLSession.shared.dataTaskPublisher(for: urlComponents.url!)
            .map{$0.data}
            .decode(type: CoronaResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
 
        }) { response in
            
            self.casesByProvince(response: response)
        }
        .store(in: &cancellable)
    }
    
    func casesByProvince(response: CoronaResponse) -> (Int, Int, Int)
    {

        var totalCases = 0
        var totalDeaths = 0
        var totalRecovered = 0

        for cases in response.features{
            
            let confirmed = cases.attributes.confirmed ?? 0

            totalCases += confirmed
            totalDeaths += cases.attributes.deaths ?? 0
            totalRecovered += cases.attributes.recovered ?? 0
        }

        self.coronaOutbreak.totalCases = "\(totalCases)"
        self.coronaOutbreak.totalDeaths = "\(totalDeaths)"
        self.coronaOutbreak.totalRecovered = "\(totalRecovered)"
        
        return (totalCases, totalRecovered, totalDeaths)
        
    }
}

struct CoronaResponse : Codable{

    public var features: [CoronaCases]
        
    private enum CodingKeys: String, CodingKey {
        case features
    }
}

struct CoronaCases : Codable{
        
    public var attributes: CaseAttributes

    private enum CodingKeys: String, CodingKey {
        case attributes
    }
}

struct CaseAttributes : Codable {

        let confirmed : Int?
        let countryRegion : String?
        let deaths : Int?
        let lat : Double?
        let longField : Double?
        let provinceState : String?
        let recovered : Int?

        enum CodingKeys: String, CodingKey {
                case confirmed = "Confirmed"
                case countryRegion = "Country_Region"
                case deaths = "Deaths"
                case lat = "Lat"
                case longField = "Long_"
                case provinceState = "Province_State"
                case recovered = "Recovered"
        }
}


struct ChuckJokes : Decodable {

        let type : String?
        let value : [ChuckValue]?

        enum CodingKeys: String, CodingKey {
                case type = "type"
                case value = "value"
        }
    
        init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                type = try values.decodeIfPresent(String.self, forKey: .type)
                value = try values.decodeIfPresent([ChuckValue].self, forKey: .value)
        }

}

struct ChuckValue : Decodable {

        
        let id : Int?
        let joke : String?

        enum CodingKeys: String, CodingKey {
                case id = "id"
                case joke = "joke"
        }
    
        init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                id = try values.decodeIfPresent(Int.self, forKey: .id)
                joke = try values.decodeIfPresent(String.self, forKey: .joke)
        }

}
