//
//  CreateOrderViewController.swift
//  CleanStore
//
//  Created by Andrew Napier on 29/11/18.
//  Copyright (c) 2018 Andrew Napier. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol CreateOrderDisplayLogic: class
{
    func displayExpirationDate(viewModel : CreateOrder.FormatExpirationDate.ViewModel)
    func displaySomething(viewModel: CreateOrder.Something.ViewModel)
}

class CreateOrderViewController: UITableViewController,
    CreateOrderDisplayLogic
{
    func displayExpirationDate(viewModel: CreateOrder.FormatExpirationDate.ViewModel) {
        let date = viewModel.date
        expirationDateTextField.text = date
    }
    
    @IBOutlet var textFields: [UITextField]!
    
    // MARK: Shipping Method
    @IBOutlet weak var shippingMethodTextField: UITextField!
    @IBOutlet var shippingMethodPicker: UIPickerView!
    
    // MARK: Expiration Date
    @IBOutlet weak var expirationDateTextField: UITextField!
    @IBOutlet var expirationDatePicker: UIDatePicker!
    
    var interactor: CreateOrderBusinessLogic?
    var router: (NSObjectProtocol & CreateOrderRoutingLogic & CreateOrderDataPassing)?
    
    @IBAction func expirationDatePickerValueChanged(_ sender: Any) {
        let date = expirationDatePicker.date
        let request = CreateOrder.FormatExpirationDate.Request(date: date)
        interactor?.formatExpirationDate(request: request)
    }
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup()
    {
        let viewController = self
        let interactor = CreateOrderInteractor()
        let presenter = CreateOrderPresenter()
        let router = CreateOrderRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        configurePickers()
    }
    
    func configurePickers() {
        shippingMethodTextField.inputView = shippingMethodPicker
        expirationDateTextField.inputView = expirationDatePicker
    }
    
    // MARK: Do something
    
    //@IBOutlet weak var nameTextField: UITextField!
    
    func doSomething()
    {
        let request = CreateOrder.Something.Request()
        interactor?.doSomething(request: request)
    }
    
    func displaySomething(viewModel: CreateOrder.Something.ViewModel)
    {
        //nameTextField.text = viewModel.name
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            for textField in self.textFields {
                if textField.isDescendant(of: cell) {
                    textField.becomeFirstResponder()
                }
            }
        }
    }
}

//MARK: - UITextFieldDelegate

extension CreateOrderViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let index = self.textFields.index(of: textField) {
            if index < self.textFields.count-1 {
                let nextTextField = self.textFields[index+1]
                nextTextField.becomeFirstResponder()
            }
        }
        return true
    }
}

//MARK: - UIPickerViewDelegate, UIPickerViewDataSource

extension CreateOrderViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.interactor?.shippingMethods.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return interactor?.shippingMethods[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        shippingMethodTextField.text = interactor?.shippingMethods[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}

