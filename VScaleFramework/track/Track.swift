//
//  Track.swift
//  VScaleFramework
//
//  Copyright © 2017 Glenn R. Golden. All rights reserved.
//

import Foundation
import SceneKit

// model track with reasonable correct cross-section, straight path
public class Track
{
	private let TIE_LENGTH : Float = 2.9745 // based on 102" prototype, HO 1:87.1 scale, scenekit unit = 1cm
	private let TIE_WIDTH : Float = 0.2333 // based on 8" prototype width
	private let TIE_HEIGHT : Float = 0.175 // TODO: based on 6" prototype height (?)
	private let TIE_CC : Float = 0.6124 // based on 21"prototype center-center
	
	// http://www.htmlcsscolor.com/hex/553C2A
	private let TIE_COLOR = UIColor(red: 85.0 / 255.0, green: 60.0 / 255.0, blue: 42.0 / 255.0, alpha: 1.0)
	
	// http://www.nmra.org/sites/default/files/standards/sandrp/pdf/rp-15.1.pdf  code 100, given in inches, converted to cm
	private let RAIL_A : Float = 0.254 // 0.1"
	private let RAIL_B : Float = 0.2286 // 0.090"
	private let RAIL_C : Float = 0.1143 // 0.045"
	private let RAIL_D : Float = 0.0457 // 0.018"
	private let RAIL_F : Float = 0.0762 //0.030"
	private let RAIL_H : Float = 0.0584 // 0.023"
	private let D_15_R : Float = 0.261799 // 15 degrees in radians
	
	private let RAIL_CC : Float = 1.5924 // rail center to center, a.k.a guage, based on prototype 4'7" Note: this shold be 1.5924, but HO scale is called 16.5mm guage ???
	
	// http://encycolorpedia.com/323839, 255 Darker version
	private let RAIL_COLOR = UIColor(red: 50.0 / 255.0, green: 56.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
	
	public let node : SCNNode
	public private(set) var height : Float = 0
	
	public init(length : Float)
	{
		node = SCNNode()
		
		let tieHeight = constructTies(length: length)
		height = tieHeight
		
		let railsHeight = constructRails(length: length)
		height = railsHeight
	}
	
	private func constructTies(length : Float) -> Float
	{
		// ties lay length along z, width along x, height along y:  CC is along X: they sit at y=0
		let geometry = SCNBox(width: CGFloat(TIE_WIDTH), height: CGFloat(TIE_HEIGHT), length: CGFloat(TIE_LENGTH), chamferRadius: 0.0)
		
		// start with the first tie at the start
		var x : Float = TIE_WIDTH / 2
		
		// sit at h
		let y : Float = height + (TIE_HEIGHT / 2)
		
		// repeat until we would be beyond the length
		while (x < length)
		{
			let tie = SCNNode(geometry: geometry)
			tie.position = SCNVector3(x: x, y: y, z: 0)
			tie.geometry?.firstMaterial?.diffuse.contents = TIE_COLOR
			node.addChildNode(tie)
			
			// continue adding every TIE_CC until we exceed length
			x += TIE_CC
		}
		
		// return the height
		return TIE_HEIGHT
	}
	
	private func constructRails(length : Float) -> Float
	{
		// rails extend along x, with height along y, and cross-section in the yz plane
		// the path starts x centered at the origin, y sitting at 0, extruded along z
		let railPath = crossSectionRail()
		let railGeometry = SCNShape(path: railPath, extrusionDepth: CGFloat(length))
		railGeometry.firstMaterial?.diffuse.contents = RAIL_COLOR
		
		// z+ rail
		let railNodeZp = SCNNode(geometry: railGeometry)
		railNodeZp.rotation = SCNVector4(x: 0, y: 1, z: 0, w: Float.pi/2)
		railNodeZp.position = SCNVector3(x: length / 2, y: height, z: (RAIL_CC / 2))
		node.addChildNode(railNodeZp)
		
		// z- rail
		let railNodeZm = SCNNode(geometry: railGeometry)
		railNodeZm.rotation = SCNVector4(x: 0, y: 1, z: 0, w: Float.pi/2)
		railNodeZm.position = SCNVector3(x: length / 2, y: height, z: (-RAIL_CC / 2))
		node.addChildNode(railNodeZm)
		
		return height + RAIL_A
	}
	
	private func crossSectionRail() -> UIBezierPath
	{
		let path = UIBezierPath()
		
		let X : Float = RAIL_F * sin(D_15_R)
		let W : Float = RAIL_D // the width of the riser - not given in the spec
		
		// starting lower left, going up and clockwise
		path.move(to: CGPoint(x: CGFloat(-1 * (RAIL_B / 2)), y: 0))
		path.addLine(to: CGPoint(x: CGFloat(-1 * (RAIL_B / 2)), y: CGFloat(RAIL_D)))
		path.addLine(to: CGPoint(x: CGFloat(-1 * (W / 2)), y: CGFloat(RAIL_D + X)))
		path.addLine(to: CGPoint(x: CGFloat(-1 * (W / 2)), y: CGFloat(RAIL_A - RAIL_H)))
		
		path.addLine(to: CGPoint(x: CGFloat(-1 * (RAIL_C / 2)), y: CGFloat(RAIL_A - RAIL_H)))
		path.addLine(to: CGPoint(x: CGFloat(-1 * (RAIL_C / 2)), y: CGFloat(RAIL_A)))
		path.addLine(to: CGPoint(x: CGFloat(RAIL_C / 2), y: CGFloat(RAIL_A)))
		path.addLine(to: CGPoint(x: CGFloat(RAIL_C / 2), y: CGFloat(RAIL_A - RAIL_H)))
		
		path.addLine(to: CGPoint(x: CGFloat(W / 2), y: CGFloat(RAIL_A - RAIL_H)))
		path.addLine(to: CGPoint(x: CGFloat(W / 2), y: CGFloat(RAIL_D + X)))
		path.addLine(to: CGPoint(x: CGFloat(RAIL_B / 2), y: CGFloat(RAIL_D)))
		path.addLine(to: CGPoint(x: CGFloat(RAIL_B / 2), y: 0))
		
		path.close()
		
		return path
	}
}
