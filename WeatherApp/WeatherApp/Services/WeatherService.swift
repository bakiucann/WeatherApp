//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Baki Uçan on 2.05.2023.
//

import Foundation
import CoreLocation

// WeatherService class provides methods to fetch weather data from the OpenWeatherMap API
class WeatherService {
  private let apiKey = "566e3106487c5702a6252c91595bda03"

  // Returns the URL for the weather icon image
  func iconURL(icon: String) -> URL? {
    return URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")
  }

  // Fetches the current weather data for the given location
  func fetchCurrentWeather(location: CLLocation, completion: @escaping (Weather) -> Void) {
    let url = "https://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&units=metric&appid=\(apiKey)"

    URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
      if let error = error {
        print("Error fetching weather data: \(error)")
        return
      }

      if let data = data {
        let decoder = JSONDecoder()
        if let weatherData = try? decoder.decode(WeatherData.self, from: data) {
          let weather = Weather(
            city: weatherData.name,
            icon: weatherData.weather[0].icon,
            temperature: weatherData.main.temp,
            minTemperature: weatherData.main.temp_min,
            maxTemperature: weatherData.main.temp_max,
            feelsLikeTemperature: weatherData.main.feels_like,
            description: weatherData.weather[0].description
          )
          completion(weather)
        }
      }
    }.resume()
  }

  // Retrieves the coordinates of a given city
  func getLocationCoordinates(city: String, completion: @escaping (CLLocation) -> Void) {
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(city) { (placemarks, error) in
      if let error = error {
        print("Error fetching location coordinates: \(error)")
        return
      }
      if let location = placemarks?.first?.location {
        completion(location)
      }
    }
  }

  // Fetches the weather forecast data for the given location
  func fetchWeatherForecast(location: CLLocation, completion: @escaping ([Forecast]) -> Void) {
    let url = "https://api.openweathermap.org/data/2.5/forecast?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&units=metric&appid=\(apiKey)"

    URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
      if let error = error {
        print("Error fetching weather forecast data: \(error)")
        return
      }

      if let data = data {
        let decoder = JSONDecoder()
        if let forecastData = try? decoder.decode(ForecastData.self, from: data) {
          let forecasts = forecastData.list.map { forecastElement -> Forecast in
            return Forecast(
              dateTime: forecastElement.dt_txt,
              icon: forecastElement.weather[0].icon,
              temperature: forecastElement.main.temp,
              description: forecastElement.weather[0].description
            )
          }
          completion(forecasts)
        }
      }
    }.resume()
  }
}
