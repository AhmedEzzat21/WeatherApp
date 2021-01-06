//
//  ChangeCityViewController.swift
//  WeatherApp
//
//  Created by Ahmed on 05/01/2021.
//


import UIKit
import CoreLocation



//protocol here
protocol ChangeCityDelegate {
    func userEnteredANewCityName(city : String)
}

class ChangeCityViewController: UIViewController, UITextFieldDelegate {
    
    var delegate : ChangeCityDelegate?
    let weatherDataModel = WeatherDataModel()

    var cities = ["Abc", "Bgd", "Cfggg", "Deutschland", "Estonia"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getWeatherButton.backgroundColor = .clear
        getWeatherButton.layer.cornerRadius = 11
        getWeatherButton.layer.borderWidth = 1
        getWeatherButton.layer.borderColor = UIColor.black.cgColor
        
        //search bar delegate
        
        changeCityTextField.delegate? = self

        
    }
    
    @IBOutlet weak var getWeatherButton: UIButton!
    @IBOutlet weak var changeCityTextField: UITextField!
    
    
    @IBAction func getWeatherPressed(_ sender: Any) {
        
        let cityName = changeCityTextField.text!
        
        delegate?.userEnteredANewCityName(city: cityName)
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    

}
