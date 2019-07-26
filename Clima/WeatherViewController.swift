//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "38583eb5fc55fbe5a390cbc322cb30e8"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    
    
    //TODO: Declare instance variables here
    let weatherDataModel = WeatherDataModel()
    let locationManager = CLLocationManager()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //http request
    func getWeatherData(url: String, parameters: [String : String]){
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON{
            response in
            if response.result.isSuccess {
                let weatherJSON : JSON = JSON(response.result.value!)
                print("successful response")
                print(weatherJSON)
                self.updateWeatherData(data: weatherJSON )
                
            } else {
                print("Error \(response.result.error!)")
                self.cityLabel.text = "Connection Issue"
            }
        }
        
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(data: JSON){

        let temperature = data["main"]["temp"].double
        
        // if temperature exists
        if var f = temperature {
            // convert temp from k to f
            f = f * 9/5 - 459.67
        
            let city = data["name"].stringValue
            let cond = data["weather"]["id"].intValue
            let icon = weatherDataModel.updateWeatherIcon(condition: cond)
            
            
            weatherDataModel.temperature = Int(f)
            weatherDataModel.city = city
            weatherDataModel.condition = cond
            weatherDataModel.weatherIconName = icon
            
            updateWeatherUI()

        } else {
            cityLabel.text = "Cannot retreive weather data"
        }
        
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateWeatherUI(){
        
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = String(weatherDataModel.temperature)
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let bestLocation = locations[locations.count - 1]
        if bestLocation.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            let lat = String(bestLocation.coordinate.latitude)
            let long = String(bestLocation.coordinate.longitude)
            
            let params: [String : String] = ["lat": lat, "lon": long, "appid": APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
            
        }
    }

    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName (city: String){
        print(city)
    }

    
    //Write the PrepareForSegue Method here
    //--setting ourself as delegate
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let newVC = segue.destination as! ChangeCityViewController
            newVC.delegate = self
        }
    }
    
    
    
    
}
