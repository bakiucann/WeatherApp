//
//  WeatherForecastViewController.swift
//  WeatherApp
//
//  Created by Baki Uçan on 2.05.2023.
//

import UIKit
import CoreLocation

// WeatherForecastViewController displays a list of weather forecasts for a location
class WeatherForecastViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!

    let weatherService = WeatherService()
    var location: CLLocation?
    var forecasts: [Forecast] = []

    // Setting up the view when it loads
    override func viewDidLoad() {
        super.viewDidLoad()

        // Assigning data source and delegate for the table view
        tableView.dataSource = self
        tableView.delegate = self

        // Registering the WeatherForecastCell for reuse
        tableView.register(UINib(nibName: "WeatherForecastCell", bundle: nil), forCellReuseIdentifier: "WeatherForecastCell")

        // Fetching weather forecast data for the given location
        if let location = location {
            weatherService.fetchWeatherForecast(location: location) { forecasts in
                DispatchQueue.main.async {
                    self.forecasts = forecasts
                    self.tableView.reloadData()
                }
            }
        }
    }

    // Returning the number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecasts.count
    }

    // Configuring the table view cells with the forecast data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherForecastCell", for: indexPath) as! WeatherForecastCell

        let forecast = forecasts[indexPath.row]
        cell.configure(with: forecast)

        return cell
    }
}
