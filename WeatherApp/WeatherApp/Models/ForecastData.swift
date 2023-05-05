//
//  ForecastData.swift
//  WeatherApp
//
//  Created by Baki Uçan on 2.05.2023.
//

import Foundation

// ForecastData struct represents the decoded JSON data for weather forecast information
struct ForecastData: Codable {
    let list: [ForecastElement]
}

// ForecastElement struct represents the individual forecast information in the ForecastData
struct ForecastElement: Codable {
    let dt_txt: String
    let weather: [WeatherElement]
    let main: Main
}
