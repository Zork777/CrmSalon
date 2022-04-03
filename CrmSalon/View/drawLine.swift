//
//  drawLine.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 31.03.2022.
//

import Foundation
import UIKit

struct DrawLineCoordinate {
    let start = CGPoint(x: 8, y: 120)
    let end = CGPoint(x: UIWindow().bounds.width-8 , y: 120)
}

func drawLine(start: CGPoint, end: CGPoint, color: UIColor, weight: CGFloat) -> CALayer{
    let path = UIBezierPath()
    path.move(to: start) //StartPoint
    path.addLine(to: end) //EndPoint of First Line and StartPoint for Second Line
    //Shape part
    let shape = CAShapeLayer()
    shape.path = path.cgPath
    shape.lineWidth = weight
    shape.fillColor = color.cgColor
    shape.strokeColor = color.cgColor
    return shape
}
