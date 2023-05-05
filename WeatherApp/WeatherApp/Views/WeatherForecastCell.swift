//
//  WeatherForecastCell.swift
//  WeatherApp
//
//  Created by Baki Uçan on 3.05.2023.
//

import UIKit

// WeatherForecastCell represents a table view cell for displaying weather forecast information
class WeatherForecastCell: UITableViewCell {
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!

    let weatherService = WeatherService()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // Configures the cell with the provided Forecast data
    func configure(with forecast: Forecast) {
        dateTimeLabel.text = forecast.dateTime
        setImage(url: weatherService.iconURL(icon: forecast.icon), for: weatherIconImageView)
        temperatureLabel.text = "\(forecast.temperature)°C"
        weatherDescriptionLabel.text = forecast.description.capitalized
    }

    // Sets the image for the UIImageView from a URL
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
