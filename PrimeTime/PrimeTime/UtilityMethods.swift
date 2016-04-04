//
//  UtilityMethods.swift
//  PrimeTime
//
//  Created by Cameron Westbury on 3/31/16.
//  Copyright © 2016 Cameron Westbury. All rights reserved.
//

import Foundation
import PKHUD


class UtilityMethods: NSObject {
    
    static let sharedInstance = UtilityMethods()
    var appDelegate = AppDelegate()
    
    
    //Cool Sieve Stuff
    
    func isPrime( number: Int) -> [Bool]{
        
        var boolArray = [Bool](count: number + 1, repeatedValue: true)
        
        boolArray[0] = false
        if boolArray.count > 1 {
            boolArray[1] = false // set 1 and 0 to false
        }
        
        if number == 0 || number == 1
        {
            return boolArray
        }
        
        for i in 2 ..< boolArray.count
        {
            if boolArray[i]
            {
                for var j = i*i; j < (boolArray.count)^(1/2); j += i
                {
                    boolArray[j] = false
                }
            }
        }
        
        
        return boolArray
        
    }
    
    func numberIsValild(number:Int, viewController:UIViewController) -> Bool {
        if number < 0  {
            appDelegate.genericAlertView("Error", message: "Please enter a postive integer less than \(Int.max) but preferably less than 10 million", currentViewController: viewController) // below int max, above will crash the bool array
            return false
        }
        
        if (number == 69 || number == 80085) {
            appDelegate.genericAlertView("Nice", message: "😉", currentViewController: viewController)
            return true // secret function
        }
            
        else {
            
            return true
        }
        
    }
    
    
    
    
}
