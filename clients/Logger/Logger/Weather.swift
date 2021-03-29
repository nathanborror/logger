import Foundation
import CoreLocation

func GetWeather(coords: CLLocationCoordinate2D, completion: @escaping (CurrentLocalWeather) -> Void) {
    let coords = String(format: "lat=%f&lon=%f", coords.latitude, coords.longitude)
    let appID = "e7b2054dc37b1f464d912c00dd309595"
    let units = "Metric"
    let url = URL(string:"https://api.openweathermap.org/data/2.5/weather?\(coords)&appid=\(appID)&units=\(units)")
    
    URLSession.shared.dataTask(with: url!) { (data, response, error) in
        do {
            let forecast = try JSONDecoder().decode(CurrentLocalWeather.self, from: data!)
            completion(forecast)
        } catch {
            print(error)
        }
    }.resume()
}

struct CurrentLocalWeather: Decodable {
    let base: String
    let clouds: Clouds
    let cod: Int
    let coord: Coord
    let dt: Int
    let id: Int
    let main: Main
    let name: String
    let sys: Sys
    let visibility: Int
    let weather: [Weather]
    let wind: Wind
}

struct Clouds: Decodable {
    let all: Int
}

struct Coord: Decodable {
    let lat: Double
    let lon: Double
}

struct Main: Decodable {
    let humidity: Int
    let pressure: Int
    let temp: Double
    let tempMax: Double
    let tempMin: Double
    
    private enum CodingKeys: String, CodingKey {
        case humidity, pressure, temp, tempMax = "temp_max", tempMin = "temp_min"
    }
}

struct Sys: Decodable {
    let country: String?
    let id: Int?
    let message: Double?
    let sunrise: UInt64
    let sunset: UInt64
    let type: Int?
}

struct Weather: Decodable {
    let description: String
    let icon: String
    let id: Int
    let main: String
}

struct Wind: Decodable {
    let deg: Int
    let speed: Double
}
