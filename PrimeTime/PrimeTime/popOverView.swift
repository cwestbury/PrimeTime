//
//  popOverView.swift
//  PrimeTime
//
//  Created by Cameron Westbury on 4/3/16.
//  Copyright © 2016 Cameron Westbury. All rights reserved.
//

import UIKit
import PKHUD

class popOverView: UIViewController {
    
    //MARK: - Outlets and Vars
    
    @IBOutlet var findPrimeTextField: UITextField!
    @IBOutlet var countPrimesLabel: UILabel!
    @IBOutlet var searchedNumberLabel: UILabel!
    @IBOutlet var isPrimeLabel: UILabel!
    
    var numberOfPrimes = Int()
    var primeBoolArray = [Bool]()
    
    var Sieve = UtilityMethods.sharedInstance
    var appDelegate = AppDelegate.sharedInstance
    
    
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        setupMethods()
        countPrimes()
    }
    
    //MARK: - Setup
    func setupMethods()  {
        countPrimesLabel.text = ""
        searchedNumberLabel.text = ""
        findPrimeTextField.keyboardType = .NumberPad
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.closeKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    //MARK: - Count Primes
    
    func countPrimes() {
        if primeBoolArray.count != 0 {
            searchedNumberLabel.text = "\(primeBoolArray.count - 1)"
            for bool in primeBoolArray {
                if bool == true {
                    numberOfPrimes = numberOfPrimes + 1
                }
            }
            countPrimesLabel.text = "\(numberOfPrimes)"
        }
    }
    
    //MARK: - Check Primes
    @IBAction func checkPrimes(){
        if let numberToCheck = Int(findPrimeTextField.text!) {
            if Sieve.numberIsValild(numberToCheck, viewController: self) == false {
                return
            }
            
            if numberToCheck <= primeBoolArray.count {
                checkPrimesInCurrentArray(numberToCheck) // use current search if within range
            } else {
                checkPrimesWithNewSieve(numberToCheck)  // else do a new search
            }
        } else{
            appDelegate.genericAlertView("Error", message: "Please enter a postive integer", currentViewController: self)
        }
    }
    
    func checkPrimesWithNewSieve(checkedNum: Int) {
        HUD.show(.Progress)
        dispatch_async(dispatch_get_main_queue()){
            
            self.primeBoolArray = self.Sieve.isPrime(checkedNum)
            HUD.hide()
            self.checkPrimes()
        }
        
    }
    
    
    
    func checkPrimesInCurrentArray(checkedNum:Int) {
        if primeBoolArray[checkedNum] == true {
            isPrimeLabel.text = "\(checkedNum) is Prime"
            isPrimeLabel.textColor = UIColor.greenColor()
        } else {
            isPrimeLabel.text = "\(checkedNum) is not Prime"
            isPrimeLabel.textColor = UIColor.redColor()
        }
        
    }
    
   
    
    //MARK: - Keyboard
    
    func  closeKeyboard() {
        findPrimeTextField.resignFirstResponder()
    }
}
