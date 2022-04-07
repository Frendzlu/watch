//
//  ClockSlide.swift
//  stoper
//
//  Created by Mateusz Francik on 5/04/2022.
//

import UIKit
import Foundation

class ClockSlide: UIView {
    @IBOutlet weak var clockTicks: UIImageView!
    @IBOutlet weak var clockTicksTimerLabel: UILabel!
    
    override func draw(_ rect: CGRect) {
        self.drawDefaultTicks()
    }
    
    func drawDefaultTicks() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 400))
        let img = renderer.image { ctx in
            ctx.cgContext.move(to: CGPoint(x: 200.0, y: 240.0))
            ctx.cgContext.addLine(to: CGPoint(x: 200.0, y: 0.0))
            ctx.cgContext.move(to: CGPoint(x: 200.0, y: 72.0))
            ctx.cgContext.addLine(to: CGPoint(x: 200.0, y: 127.0))

            ctx.cgContext.setLineWidth(3)
            ctx.cgContext.setStrokeColor(UIColor.orange.cgColor)
            ctx.cgContext.strokePath()
            
            self.drawMiddleCircles(ctx: ctx)
        }
        
        clockTicks.image = img
    }
    
    func drawTicks(dateTotal: Date, dateCurr: Date, rounds: Int) {
        let minutes = (Double(dateTotal.timeIntervalSince1970) / 60.0)
        let seconds = Double(dateTotal.timeIntervalSince1970).truncatingRemainder(dividingBy: 60.0)
        let secondsRound = Double(dateCurr.timeIntervalSince1970).truncatingRemainder(dividingBy: 60.0)
        
        let radius = Double(clockTicks.frame.width / 2.0)
        let degRounds = ((secondsRound / 60.0) * 360)
        let degSec = ((seconds / 60.0) * 360)
        
        let radRounds = degRounds * (Double.pi / 180)
        let xRounds = (sin(radRounds) * radius) + radius
        let yRounds = radius - (cos(radRounds) * radius)
        
        let radSec = degSec * (Double.pi / 180)
        let xSec = (sin(radSec) * radius) + radius
        let ySec = radius - (cos(radSec) * radius)
        
        let degMin = (Double(minutes) / 30.0) * 360
        let radiusMin = 55.0
        let radMin = degMin * (Double.pi / 180)
        let xMin = (sin(radMin) * radiusMin) + radiusMin + (200.0 - radiusMin)
        let yMin = radiusMin - (cos(radMin) * radiusMin) + (127.0 - radiusMin)

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 400))
        let img = renderer.image { ctx in
            if rounds > 1 {
                let startingCoords = self.calculateStartingPoint(x: xRounds, y: yRounds)
                ctx.cgContext.move(to: CGPoint(x: startingCoords["x"]!, y: startingCoords["y"]!))
                ctx.cgContext.addLine(to: CGPoint(x: xRounds, y: yRounds))
                ctx.cgContext.setStrokeColor(UIColor.blue.cgColor)
                ctx.cgContext.setLineWidth(3)
                ctx.cgContext.strokePath()
            }
            
            let startingCoordsSec = self.calculateStartingPoint(x: xSec, y: ySec)
            
            ctx.cgContext.move(to: CGPoint(x: startingCoordsSec["x"]!, y: startingCoordsSec["y"]!))
            ctx.cgContext.addLine(to: CGPoint(x: xSec, y: ySec))
            
            ctx.cgContext.move(to: CGPoint(x: 200.0, y: 127.0))
            ctx.cgContext.addLine(to: CGPoint(x: xMin, y: yMin))
            

            ctx.cgContext.setLineWidth(3)
            ctx.cgContext.setStrokeColor(UIColor.orange.cgColor)
            ctx.cgContext.strokePath()
            
            self.drawMiddleCircles(ctx: ctx)
        }
        
        clockTicks.image = img
    }
    
    func drawMiddleCircles(ctx: UIGraphicsImageRendererContext) {
        let rectMid = CGRect(x: 195.0, y: 195.0, width: 10, height: 10)
        ctx.cgContext.setFillColor(UIColor.black.cgColor)
        ctx.cgContext.setStrokeColor(UIColor.orange.cgColor)
        ctx.cgContext.addEllipse(in: rectMid)
        ctx.cgContext.setLineWidth(3)
        ctx.cgContext.drawPath(using: .fillStroke)
        
        let rect = CGRect(x: 195.0, y: 122.0, width: 10, height: 10)
        ctx.cgContext.setFillColor(UIColor.orange.cgColor)
        ctx.cgContext.addEllipse(in: rect)
        ctx.cgContext.drawPath(using: .fill)
    }
    
    func calculateStartingPoint(x: Double, y: Double) -> [String: Double] {
        let vec: [String: Double] = ["x": (200.0 - x) / 5.0, "y": (200.0 - y) / 5.0]
        return ["x": 200.0 + vec["x"]!, "y": 200.0 + vec["y"]!]
    }
}
