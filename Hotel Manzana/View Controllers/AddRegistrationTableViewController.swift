//
//  AddRegistrationTableViewController.swift
//  Hotel Manzana
//
//  Created by Vitally Ochnev on 09.07.2022.
//


import UIKit

class AddRegistrationTableViewController: UITableViewController {
    // MARK: - Outlets
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    
    @IBOutlet var checkInDateLabel: UILabel!
    @IBOutlet var checkInDatePicker: UIDatePicker!
    
    @IBOutlet var checkOutDateLabel: UILabel!
    @IBOutlet var checkOutDatePicker: UIDatePicker!
    
    @IBOutlet var numberOfAdultsLabel: UILabel!
    @IBOutlet var numberOfAdultsStepper: UIStepper!
    @IBOutlet var numberOfChildrenLabel: UILabel!
    @IBOutlet var numberOfChildrenStepper: UIStepper!
    
    @IBOutlet var wifiSwitch: UISwitch!
    @IBOutlet var roomTypeLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    //MARK: - Properties
    var roomType: RoomType?
    var registration = Registration()
    
    let checkInDateLabelIndexPath = IndexPath(row: 0, section: 1)
    let checkInDatePickerIndexPath = IndexPath(row: 1, section: 1)
    let checkOutDateLabelIndexPath = IndexPath(row: 2, section: 1)
    let checkOutDatePickerIndexPath = IndexPath(row: 3, section: 1)
    
    var isCheckInDatePickerShown: Bool = false {
        didSet {
            checkInDatePicker.isHidden = !isCheckInDatePickerShown
        }
    }
    var isCheckOutDatePickerShown: Bool = false {
        didSet {
            checkOutDatePicker.isHidden = !isCheckOutDatePickerShown
        }
    }
    
    // MARK: - Methods
    func checkCanSave() {
        guard let roomType = roomType else {
            saveButton.isEnabled = false
            return
        }
        
        let emailTemplate = #"^\S+@\S+\.\S+$"#
        
        if firstNameTextField.text!.count == 0 || lastNameTextField.text!.count == 0 || emailTextField.text!.count == 0 || emailTextField.text?.range(of: emailTemplate, options: .regularExpression) == nil || roomType.name.count == 0 {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
    
    func saveRegistration() {
        registration.firstName = firstNameTextField.text ?? ""
        registration.lastName = lastNameTextField.text ?? ""
        registration.emailAdress = emailTextField.text ?? ""
        registration.checkInDate = checkInDatePicker.date
        registration.checkOutDate = checkOutDatePicker.date
        registration.numberOfAdults = Int(numberOfAdultsStepper.value)
        registration.numberOfChildren = Int(numberOfChildrenStepper.value)
        registration.roomType = roomType
        registration.wifi = wifiSwitch.isOn
    }
    // MARK: - UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let midnightToday = Calendar.current.startOfDay(for: Date())
        checkInDatePicker.minimumDate = midnightToday
        checkInDatePicker.date = midnightToday
        
        updateUI()
        updateDateViews()
        updateNumberOfGuests()
        updateRoomType()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "SelectRoomType":
            let destination = segue.destination as! SelectRoomTypeTableViewController
            destination.delegate = self
            destination.roomType = roomType
        case "SaveGuest":
            saveRegistration()
        case .none:
            return
        case .some(_):
            return
        }
    }
    
    // MARK: - UI Methods
    func updateDateViews() {
        checkOutDatePicker.minimumDate = checkInDatePicker.date.addingTimeInterval(60 * 60 * 24)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "en_US")
        
        checkInDateLabel.text = dateFormatter.string(from: checkInDatePicker.date)
        checkOutDateLabel.text = dateFormatter.string(from: checkOutDatePicker.date)
    }
    
    func updateNumberOfGuests() {
        let numberOfAdults = Int(numberOfAdultsStepper.value)
        let numberOfChildren = Int(numberOfChildrenStepper.value)
        
        numberOfAdultsLabel.text = "\(numberOfAdults)"
        numberOfChildrenLabel.text = "\(numberOfChildren)"
    }
    
    func updateRoomType() {
        if let roomType = roomType {
            roomTypeLabel.text = roomType.name
        } else {
            roomTypeLabel.text = "Not Set"
        }
        checkCanSave()
    }
    
    func updateUI() {
        firstNameTextField.text = registration.firstName
        lastNameTextField.text = registration.lastName
        emailTextField.text = registration.emailAdress
        
        checkInDatePicker.minimumDate = registration.checkInDate
        checkInDatePicker.date = registration.checkInDate
        checkOutDatePicker.date = registration.checkOutDate
        
        numberOfAdultsStepper.value = Double(registration.numberOfAdults)
        numberOfChildrenStepper.value = Double(registration.numberOfChildren)
        
        wifiSwitch.isOn = registration.wifi
        roomType = registration.roomType
    }
    
    // MARK: - Actions
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        updateDateViews()
    }
    
    
    @IBAction func editingChanged(_ sender: UITextField) {
        checkCanSave()
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        updateNumberOfGuests()
    }
}

// MARK: - UITableViewDataSource
extension AddRegistrationTableViewController /*: UITableViewDataSource */ {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case checkInDatePickerIndexPath:
            return isCheckInDatePickerShown ? UITableView.automaticDimension : 0
        case checkOutDatePickerIndexPath:
            return isCheckOutDatePickerShown ? UITableView.automaticDimension : 0
        default:
            return UITableView.automaticDimension
        }
    }
}

// MARK: - UITableViewDelegate
extension AddRegistrationTableViewController /*: UITableViewDelegate */ {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case checkInDateLabelIndexPath:
            isCheckInDatePickerShown.toggle()
            isCheckOutDatePickerShown = false
        case checkOutDateLabelIndexPath:
            isCheckOutDatePickerShown.toggle()
            isCheckInDatePickerShown = false
        default:
            return
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

// MARK: - SelectRoomTypeTableViewControllerProtocol
extension AddRegistrationTableViewController: SelectRoomTypeTableViewControllerProtocol {
    func didSelect(roomType: RoomType) {
        self.roomType = roomType
        updateRoomType()
    }
}

