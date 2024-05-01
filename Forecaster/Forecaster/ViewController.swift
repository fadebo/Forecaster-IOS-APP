//
//  ViewController.swift
//  Forecaster
//
//  Created by Lab8student on 2024-04-06.
//
import Foundation
import UIKit

// Weather model to store the parsed weather data
//struct WeatherData {
//    var cityName: String = ""
//    var currentTemperature: String = ""
//    var minTemperature: String = ""
//    var maxTemperature: String = ""
//    var humidity: String = ""
//    var windSpeed: String = ""
//    var windDirection: String = ""
//    var precipitation: String = ""
//    var weatherIconId: String = ""
//}

struct WeatherData {
    var cityName: String?
    var currentTemperature: String?
    var maxTemperature: String?
    var minTemperature: String?
    var humidity: String?
    var windSpeed: String?
    var windDirection: String?
    var precipitation: String?
    var weatherIconId: String?
}

class ViewController: UIViewController {
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    @IBOutlet weak var minTemperatureLabel: UILabel!
    @IBOutlet weak var maxTemperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var precipitationLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    
    var weatherData = WeatherData()
    var currentParsingElement = ""
    var foundCharacters = ""
    
    var currentElement = ""
    var currentAttributes: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadWeatherData()
    }
    func loadWeatherData() {
            let city = UserDefaults.standard.string(forKey: "cityName") ?? "Sault Ste. Marie"
        
                fetchWeatherData(city)
        }
    func fetchWeatherData(_ city: String) {
            let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city),ca&appid=5dc1d31216585332c40c29eca6c261cb&mode=xml&units=metric"
            guard let url = URL(string: urlString) else { return }
            
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return }
                if let error = error {
                    // Handle the error
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else { return }
                print(String(data: data, encoding: .ascii)!)
                // Parse the XML data
                self.parseXMLData(data)
            }
            
            task.resume()
        }
    
    func parseXMLData(_ data: Data) {
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }
    
    
    // Function to present SettingsViewController modally
    @IBAction func presentSettings(_ sender: Any) {
        let settingsViewController = self.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        settingsViewController.modalPresentationStyle = .fullScreen
        settingsViewController.delegate = self
        self.present(settingsViewController, animated: true, completion: nil)
    }
    // Function to refresh the weather data
    @IBAction func refreshWeatherData(_ sender: Any) {
        if let cityName = UserDefaults.standard.string(forKey: "cityName") {
            fetchWeatherData(cityName)
        }
    }
    
}


extension ViewController: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        currentAttributes = attributeDict
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
            let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedString.isEmpty else { return }
            
            switch currentElement {
            case "city":
                weatherData.cityName = currentAttributes["name"]
            case "temperature":
                weatherData.currentTemperature = currentAttributes["value"]
                weatherData.maxTemperature = currentAttributes["max"]
                weatherData.minTemperature = currentAttributes["min"]
            case "humidity":
                weatherData.humidity = currentAttributes["value"]
            case "precipitation":
                weatherData.precipitation = currentAttributes["mode"]
            case "speed":
                weatherData.windSpeed = currentAttributes["value"]
            case "direction":
                weatherData.windDirection = currentAttributes["value"]
            case "weather":
                weatherData.weatherIconId = currentAttributes["icon"]
            default:
                break
            }
        }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
//        if elementName == "temperature" {
//                   weatherData.maxTemperature = currentAttributes["max"]
//                   weatherData.minTemperature = currentAttributes["min"]
//               }
//               // Handle other elements and reset currentAttributes if necessary
//               currentAttributes.removeAll()
        switch elementName {
        case "city":
            weatherData.cityName = UserDefaults.standard.string(forKey: "cityName")
        case "temperature":
            weatherData.currentTemperature = currentAttributes["value"]
            weatherData.maxTemperature = currentAttributes["max"]
            weatherData.minTemperature = currentAttributes["min"]
        case "humidity":
            weatherData.humidity = currentAttributes["value"]
        case "precipitation":
            weatherData.precipitation = currentAttributes["mode"]
        case "speed":
            weatherData.windSpeed = currentAttributes["value"]
        case "direction":
            weatherData.windDirection = currentAttributes["value"]
        case "weather":
            weatherData.weatherIconId = currentAttributes["icon"]
        default:
            break
        }
        currentAttributes.removeAll() // Reset currentAttributes for the next element
    }

//    func parserDidEndDocument(_ parser: XMLParser) {
//        // Parsing completed, use weatherData as needed
//        print(weatherData)
//    }
    func parserDidEndDocument(_ parser: XMLParser) {
        // Update the UI with the parsed data
        print(weatherData)
        DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                // Update the UI with the parsed data
                self.cityNameLabel.text = self.weatherData.cityName
//                self.currentTemperatureLabel.text = self.weatherData.currentTemperature

//            print(self.cityNameLabel.text!)
            
//            print(self.currentTemperatureLabel.text!)
            self.currentTemperatureLabel.text = "\(self.weatherData.currentTemperature ?? "")°C"
            self.minTemperatureLabel.text = "\(self.weatherData.minTemperature ?? "")°C"
            self.maxTemperatureLabel.text = "\(self.weatherData.maxTemperature ?? "")°C"
            self.humidityLabel.text = "\(self.weatherData.humidity ?? "")°C"
            self.windSpeedLabel.text = "\(self.weatherData.windSpeed ?? "")m/s at \(self.weatherData.windDirection ?? "")°"
            if self.weatherData.precipitation == "no"{
                self.precipitationLabel.text = "None"
            }else{
                let pVal = Double(self.weatherData.precipitation!)
                self.weatherData.precipitation = "\(pVal! * 100)"
                self.precipitationLabel.text = "\(self.weatherData.precipitation ?? "")%"
                
            }
            
//                 Fetch and display the weather icon
            self.fetchWeatherIcon(withId: self.weatherData.weatherIconId!)

            }
    }
}

// Extension to handle the image fetching and display
extension ViewController {
    func fetchWeatherIcon(withId id: String) {
        let urlString = "https://openweathermap.org/img/w/\(id).png"
        // Fetch the image data and update the weatherImageView
        guard let url = URL(string: urlString) else { return }
                
                let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                    guard let self = self else { return }
                    if let error = error {
                        // Handle the error appropriately
                        print("Error: \(error.localizedDescription)")
                        return
                    }
                    guard let data = data, let image = UIImage(data: data) else { return }
                    DispatchQueue.main.async {
                        self.weatherImageView.image = image
                    }
                }
                task.resume()
    }
}

extension ViewController: SettingsViewControllerDelegate {
    func didUpdateCityName(_ cityName: String) {
        fetchWeatherData(cityName)
    }
}
