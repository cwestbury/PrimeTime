//
//  ViewController.swift
//  PrimeTime
//
//  Created by Cameron Westbury on 3/31/16.
//  Copyright © 2016 Cameron Westbury. All rights reserved.
//

import UIKit
import PKHUD


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIPopoverPresentationControllerDelegate, UITextFieldDelegate {
    
    //MARK: - Outlets and Vars
    
    @IBOutlet var howManyNumbersTextField: UITextField!
    @IBOutlet var primeCollectionView: UICollectionView!
    
    var collectionArray = [Bool]()
    
    var appDelegate = AppDelegate.sharedInstance
    var Sieve = UtilityMethods.sharedInstance
    
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        howManyNumbersTextField.keyboardType = .NumberPad
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.closeKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Collection View Methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionArray.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! PrimeCollectionViewCell
        
        let currentNumberBool = collectionArray[indexPath.row] //boolean value
        let currentNumberValue = indexPath.row //number value
        
        cell.numberLabel!.text = String(currentNumberValue)
        cell.numberLabel.font = UIFont.systemFontOfSize(formatFontSize())
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 6
        
        if currentNumberBool == true {
            cell.backgroundColor = UIColor.cyanColor()
        } else {
            cell.backgroundColor = UIColor.lightGrayColor()
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return formatCellSize()
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //format cell size based on the size of the array
    func formatCellSize() -> (CGSize) {
        switch collectionArray.count {
        case 1...100:
            return CGSizeMake(110, 120)
        case 101...1000:
            return CGSizeMake(50, 50)
        default:
            return CGSizeMake(30, 30)
        }
    }
    
    //format font size based on the size of the array
    func formatFontSize() -> (CGFloat) {
        switch collectionArray.count {
        case 0...9:
            return 100
        case 10...99:
            return 30
        case 100...999:
            return 24
        case 1000...9999:
            return 10
        default:
            return 7
        }
    }
    
    //MARK: - AlertView
    
    func genericAlertView(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: - Keyboard / Textview
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        let keyboardDoneButtonShow = UIToolbar(frame: CGRectMake(0, 0,  self.view.frame.size.width, self.view.frame.size.height/17))
        
        keyboardDoneButtonShow.barStyle = UIBarStyle .Default
        
        let doneButton = UIBarButtonItem(title: "Search", style: UIBarButtonItemStyle.Done, target: self, action: #selector(UITextFieldDelegate.textFieldShouldReturn(_:)))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        doneButton.tintColor = UIColor .blueColor()
        
        let toolbarButton = [flexSpace,doneButton]
        
        keyboardDoneButtonShow.setItems(toolbarButton, animated: false)
        
        howManyNumbersTextField.inputAccessoryView = keyboardDoneButtonShow
        
        return true
        //I didn't write this code but I found it online and I think it adds to the app. I wanted the keypad to have a search button as well.
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        closeKeyboard()
        findPrimes()
        return false
    }
    
    
    func  closeKeyboard() {
        howManyNumbersTextField.resignFirstResponder()
    }
    
    //MARK: - Popover Methods
    @IBAction func popOver() {
        self.performSegueWithIdentifier("popover", sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "popover"
        {
            let arrayToSend = collectionArray
            let popoverVC = segue.destinationViewController as! popOverView
            popoverVC.primeBoolArray = arrayToSend
            popoverVC.preferredContentSize = CGSizeMake(200, 150)
            
            let controller = popoverVC.popoverPresentationController
            
            if controller != nil
            {
                controller?.delegate = self
            }
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return .None
    }
    
    //MARK: - Prime Methods
    
    @IBAction func findPrimes(){
        if let number =  howManyNumbersTextField.text {
            if let primesToThisNumber = NSNumberFormatter().numberFromString(number)?.integerValue {
                if Sieve.numberIsValild(primesToThisNumber, viewController: self) == false {
                    return
                }
                
                closeKeyboard()
                
                HUD.show(.Progress) // This has worked in consitently in the past, it is best to test with a number near 1,000,000. A search in this range will display the spinner for a couple seconds. I believe the orignal issue was caused by using this with in a background thread but it seems fine now.
                findPrimesInBackground(primesToThisNumber)
                
                
            } else {
                appDelegate.genericAlertView("Error", message: "Please enter a postive integer", currentViewController: self)
            }
            
        }
        
        
    }
    
    
    func findPrimesInBackground(primesToFind:Int) {
        
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            self.collectionArray = self.Sieve.isPrime(primesToFind)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.primeCollectionView.reloadData()
                HUD.hide() // it seems like with large numbers 10M + the collection view is not finished reloading data when the spinner ends.
            })
        })
        
    }
    
    
    
}

