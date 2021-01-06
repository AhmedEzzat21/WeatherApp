//
//  ViewController.swift
//  WeatherApp
//
//  Created by Ahmed on 05/01/2021.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    func userEnteredANewCityName(city: String) {
        //print(city)
        
        let params : [String : String] = ["q" : city,
                                          "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)

    }
    
    //MARK: - Variables
    var locationManager: CLLocationManager!
    let weatherDataModel = WeatherDataModel()
    
    //MARK: - Outlets
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var minimumTempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var descrptionLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    
    
    //MARK: - Constants for openweathermap
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "39702fbf6ac94139452854d574861542"
    
    
    //hide home indicator
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //Slide in menu test
        //setupCard()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters //best accuracy for weather apps
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation() //asynchronus method
        }
        
        
        
    }
    
    
    //MARK: - Location Manager protocol methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation
        
        locationManager.stopUpdatingLocation()

        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        let latitude = String(userLocation.coordinate.latitude)
        let longitude = String(userLocation.coordinate.longitude)
        
        //parameters for openweathermap api which can be found in their documentation.
        let params : [String : String] = ["lat" : latitude,
                                          "lon" : longitude,
                                          "appid" : APP_ID]
        
        
        
        getWeatherData(url: WEATHER_URL, parameters: params)
    
  
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
        
        let alert = UIAlertController(title: "Warning", message: "Location can not be retrieved.\nPlease check your internet connection.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    //MARK: - NETWORKING
    func getWeatherData(url: String, parameters: [String : String]){
        
        //import Alamofire and SwiftyJSON before doing this
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            
            response in
            
            if response.result.isSuccess{
                
                //print(response)
                //formating JSON data we got from our api response
                let weatherJSON : JSON = JSON(response.result.value!)
                
                self.updateWeatherData(json: weatherJSON)
                
            }
            else {
                
                print("Error: \(response.result.error)")
                self.cityLabel.text = "Connection issue."
                
            }
            
            
        }
        
    }
    
    
    
    //MARK: - JSON PARSING
    func updateWeatherData(json: JSON) {
        
        let tempResult = json["main"]["temp"].double
        let minimumTempResult = json["main"]["temp_min"].double
        let humidityResult = json["main"]["humidity"].int
        let weatherIconResult = json["weather"][0]["id"].int
        let descriptionResult = json["weather"][0]["description"].string
        let cityResult = json["name"].string
        let countryResult : String? = json["sys"]["country"].stringValue
        
        if cityResult == nil {
            
            print("city name value is nil.")
            
        }
            
       print(countryResult)
        
        
        weatherDataModel.temperature = Int(tempResult! - 273.15) //K - 273.15 = C
        weatherDataModel.minimumTemperature = Int(minimumTempResult! - 273.15)
        weatherDataModel.humidity = humidityResult!
        weatherDataModel.description = descriptionResult!
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherIconResult!)
        weatherDataModel.city = cityResult!
        weatherDataModel.country = countryResult!
        
        
        
        //update UI with WeatherDataModel values
        updateUIWithWeatherData()
            
        
        
    }
    
    //UI
    func updateUIWithWeatherData() {
        
        self.temperatureLabel.text = "\(weatherDataModel.temperature)°"
        self.minimumTempLabel.text = "\(weatherDataModel.minimumTemperature)°"
        self.humidityLabel.text = "\(weatherDataModel.humidity)"
        self.descrptionLabel.text = "\(weatherDataModel.description)"
        self.weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        self.cityLabel.text = "\(weatherDataModel.city)"
        self.countryLabel.text = "\(weatherDataModel.country)"
        
    }
    
    //Segue delegate
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityIdentifier" {
            
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
            
        }
    }
}

