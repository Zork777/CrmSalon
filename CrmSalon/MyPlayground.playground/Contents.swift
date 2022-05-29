import UIKit
import CoreData
import Foundation
let hour = 9
var firstZero = ""
hour < 10 ?  (firstZero = "1") : print (2)
let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "dd"
Int(dateFormatter.string(from: Date()))
Date()
Date()
let s = ["1","2","3","4"]

let aaaa = s.compactMap {Int($0)}
print (aaaa)

let dic = [1:"one", 2:"two"]
dic[3]
