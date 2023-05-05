//
//  WeatherData.swift
//  WeatherApp
//
//  Created by Baki Uçan on 2.05.2023.
//

import Foundation

// WeatherData struct represents the decoded JSON data for current weather information
struct WeatherData: Codable {
    let name: String
    let weather: [WeatherElement]
    let main: Main
}

// WeatherElement struct represents the weather condition information in the WeatherData
struct WeatherElement: Codable {
    let icon: String
    let description: String
}

// Main struct represents the temperature information in the WeatherData
struct Main: Codable {
    let temp: Double
    let temp_min: Double
    let temp_max: Double
    let feels_like: Double
}
