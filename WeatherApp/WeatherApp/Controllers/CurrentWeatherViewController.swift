//  CurrentWeatherViewController.swift
//  WeatherApp
//
//  Displays current weather information for a location
//  Allows user to change location and view weather forecast

import UIKit
import CoreLocation
import UserNotifications

class CurrentWeatherViewController: UIViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate  {

  // UI Outlets
  @IBOutlet weak var cityNameLabel: UILabel!
  @IBOutlet weak var weatherIconImageView: UIImageView!
  @IBOutlet weak var currentTemperatureLabel: UILabel!
  @IBOutlet weak var weatherDescriptionLabel: UILabel!
  @IBOutlet weak var showWeatherForecastButton: UIButton!
  @IBOutlet weak var minTemperatureLabel: UILabel!
  @IBOutlet weak var maxTemperatureLabel: UILabel!
  @IBOutlet weak var feelsLikeTemperatureLabel: UILabel!
  @IBOutlet weak var changeLocationButton: UIButton! // Connect this outlet to your "Change Location" button in the storyboard

  // Location and weather services
  let locationManager = CLLocationManager()
  let weatherService = WeatherService()

  // Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()

    // Setup location manager
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()

    // Request notification permission and set notification delegate
    requestNotificationPermission()
    UNUserNotificationCenter.current().delegate = self
  }

  // Location Manager Delegate
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last {
      locationManager.stopUpdatingLocation()
      // Fetch current weather for location
      weatherService.fetchCurrentWeather(location: location) { weather in
        DispatchQueue.main.async {
          self.updateUI(with: weather)
        }
      }
    }
  }

  // Request permission to display notifications
  func requestNotificationPermission() {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound]) { granted, error in
      if let error = error {
        print("Error requesting notification authorization: \(error)")
      }
    }
  }

  // Schedule a local notification with the current weather information
  func scheduleLocalNotification(weather: Weather) {
    let content = UNMutableNotificationContent()
    content.title = "Weather Update"
    content.body = "Current temperature in \(weather.city) is \(weather.temperature)°C."
    content.sound = .default

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

    let request = UNNotificationRequest(identifier: "weatherNotification", content: content, trigger: trigger)

    let center = UNUserNotificationCenter.current()
    center.add(request) { error in
      if let error = error {
        print("Error scheduling local notification: \(error)")
      }
    }
  }

  // Notification Center Delegate
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.banner, .sound])
  }

  // Update UI with weather information
  func updateUI(with weather: Weather) {
    cityNameLabel.text = weather.city
    setImage(url: weatherService.iconURL(icon: weather.icon), for: weatherIconImageView)
    currentTemperatureLabel.text = "\(weather.temperature)°C"
    minTemperatureLabel.text = "Min: \(weather.minTemperature)°C"
    maxTemperatureLabel.text = "Max: \(weather.maxTemperature)°C"
    feelsLikeTemperatureLabel.text = "Feels like: \(weather.feelsLikeTemperature)°C"
    weatherDescriptionLabel.text = weather.description.capitalized

    scheduleLocalNotification(weather: weather)
  }

  // Function to asynchronously set the image for a UIImageView using a URL
  func setImage(url: URL?, for imageView: UIImageView) {
    guard let url = url else { return }
    DispatchQueue.global().async {
      if let data = try? Data(contentsOf: url) {
        DispatchQueue.main.async {
          imageView.image = UIImage(data: data)
        }
      }
    }
  }

  // Action to show weather forecast when "Show Weather Forecast" button is tapped
  @IBAction func showWeatherForecast(_ sender: UIButton) {
  }

  // Action to change location when "Change Location" button is tapped
  @IBAction func changeLocation(_ sender: UIButton) {
    let alertController = UIAlertController(title: "Enter City", message: nil, preferredStyle: .alert)

    alertController.addTextField { textField in
      textField.placeholder = "City Name"
    }

    // Submit action to fetch weather data for the entered city
    let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak alertController] _ in
      if let cityName = alertController?.textFields?[0].text {
        self?.fetchWeatherDataForCity(cityName)
      }
    }

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

    alertController.addAction(submitAction)
    alertController.addAction(cancelAction)

    present(alertController, animated: true, completion: nil)
  }

  // Function to fetch weather data for a given city
  func fetchWeatherDataForCity(_ cityName: String) {
    weatherService.getLocationCoordinates(city: cityName) { location in
      self.weatherService.fetchCurrentWeather(location: location) { weather in
        DispatchQueue.main.async {
          self.updateUI(with: weather)
        }
      }
    }
  }

  // Function to prepare for segue to WeatherForecastViewController
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showWeatherForecast" {
      let destinationVC = segue.destination as! WeatherForecastViewController
      destinationVC.location = locationManager.location
    }
  }
}
