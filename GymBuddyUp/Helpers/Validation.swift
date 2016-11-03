//
//  Validation.swift
//  GymBuddyUp
//
//  Created by you wu on 6/3/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class Validation: NSObject {
    enum pwStatus {
        case succeed
        case countError
        case numcharError
    }
    //password must be 5-20 characters, contains both num and character
    class func isValidPassword(password: String) -> pwStatus {
        if password.characters.count > 20 || password.characters.count < 6 {
            return .countError
        }
        var hasNum = false
        var hasChar = false
        
        let letters = NSCharacterSet.letterCharacterSet()
        let digits = NSCharacterSet.decimalDigitCharacterSet()
        
        for uni in password.unicodeScalars {
            if letters.longCharacterIsMember(uni.value) {
                hasChar = true
            } else if digits.longCharacterIsMember(uni.value) {
                hasNum = true
            }
            if hasChar && hasNum {
                return .succeed
            }
        }
        return .numcharError
    }
    
    class func isPasswordSame(password: String , confirmPassword : String) -> Bool {
        if password == confirmPassword{
            return true
        }
        else{
            return false
        }
    }
    
    class func isValidEmail(testStr:String) -> Bool {
        print("validate emailId: \(testStr)")
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluateWithObject(testStr)
        return result
    }

}
