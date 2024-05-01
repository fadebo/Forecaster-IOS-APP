//
//  SettingsViewController.swift
//  Forecaster
//
//  Created by Lab8student on 2024-04-06.
//

import UIKit

protocol SettingsViewControllerDelegate: AnyObject {
    func didUpdateCityName(_ cityName: String)
}

class SettingsViewController: UIViewController {
    weak var delegate: SettingsViewControllerDelegate?
    // Outlet for the text field
    @IBOutlet weak var cityTextField: UITextField!
    
    override func viewDidLoad() {
            super.viewDidLoad()
            cityTextField.text = UserDefaults.standard.string(forKey: "cityName") ?? "Sault Ste. Marie"
        }
    @IBAction func saveCityName(_ sender: UIButton) {
        guard let cityName = cityTextField.text, !cityName.isEmpty else {
            presentAlert(title: "Error", message: "City name cannot be blank.")
            return
        }
        UserDefaults.standard.set(cityName, forKey: "cityName")
            delegate?.didUpdateCityName(cityName)
        presentAlert(title: "Success", message: "City name saved successfully.") {
            self.dismiss(animated: true)
        }
    }
    @IBAction func cancel(_ sender: UIButton) {
            presentAlert(title: "Warning", message: "Changes will not be saved.") {
                self.dismiss(animated: true)
            }
        }

    func presentAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completion?()
        })
        present(alert, animated: true)
    }
    
}
