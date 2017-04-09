//
//  CabooseBlocky.swift
//  VScaleFramework
//
//  Copyright © 2017 Glenn R. Golden. All rights reserved.
//

import Foundation
import SceneKit

// A train car representing (loosely) a caboose, in our placeholder "blocky" style
public class CabooseBlocky : TrainCar
{
	private let CABIN_HEIGHT: Float = 4
	private let CABIN_WIDTH: Float = 7
	
	override func construct()
	{
		let CHASSIS_WIDTH = GAP + CABIN_WIDTH + GAP
		
		let height = constructChassis(width: CHASSIS_WIDTH)
		
		// cabin
		let cabinGeometry = SCNBox(width: CGFloat(CABIN_WIDTH), height: CGFloat(CABIN_HEIGHT), length: CGFloat(CHASSIS_DEPTH - GAP), chamferRadius: 0)
		cabinGeometry.materials.first?.diffuse.contents = UIColor.blue
		let cabinNode = SCNNode(geometry: cabinGeometry)
		cabinNode.position = SCNVector3(x: 0, y: height + (CABIN_HEIGHT/2), z: 0)
		nodes.first!.addChildNode(cabinNode)
	}
}
