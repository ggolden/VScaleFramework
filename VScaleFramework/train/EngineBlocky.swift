//
//  EngineBlocky.swift
//  VScaleFramework
//
//  Copyright © 2017 Glenn R. Golden. All rights reserved.
//

import Foundation

import Foundation
import SceneKit

// A train car representing (loosely) an engine, in our placeholder "blocky" style
public class EngineBlocky : TrainCar
{
	private let CABIN_HEIGHT: Float = 4.5
	private let CABIN_WIDTH: Float = 3
	
	private let TRUNK_HEIGHT: Float = 2.5
	private let TRUNK_WIDTH: Float = 7
	
	private let STACK_RADIUS: Float = 0.35
	private let STACK_HEIGHT: Float = 0.75
	
	override func construct()
	{
		let CHASSIS_WIDTH = GAP + CABIN_WIDTH + TRUNK_WIDTH + GAP
		
		let height = constructChassis(width: CHASSIS_WIDTH)
		
		// cabin
		let cabinGeometry = SCNBox(width: CGFloat(CABIN_WIDTH), height: CGFloat(CABIN_HEIGHT), length: CGFloat(CHASSIS_DEPTH - GAP), chamferRadius: 0)
		cabinGeometry.materials.first?.diffuse.contents = UIColor.blue
		let cabinNode = SCNNode(geometry: cabinGeometry)
		cabinNode.position = SCNVector3(x: (-CHASSIS_WIDTH/2) + (CABIN_WIDTH/2) + GAP, y: height + (CABIN_HEIGHT/2), z: 0)
		nodes.first!.addChildNode(cabinNode)
		
		// trunk - same height layer
		let trunkGeometry = SCNBox(width: CGFloat(TRUNK_WIDTH), height: CGFloat(TRUNK_HEIGHT), length: CGFloat(CHASSIS_DEPTH - (2*GAP)), chamferRadius: 0)
		trunkGeometry.materials.first?.diffuse.contents = UIColor.blue
		let trunkNode = SCNNode(geometry: trunkGeometry)
		trunkNode.position = SCNVector3(x: (-CHASSIS_WIDTH/2) + CABIN_WIDTH + GAP + (TRUNK_WIDTH/2), y: height + (TRUNK_HEIGHT/2), z: 0)
		nodes.first!.addChildNode(trunkNode)
		
		// stack
		let stackGeometry = SCNCylinder(radius: CGFloat(STACK_RADIUS), height: CGFloat(STACK_HEIGHT))
		stackGeometry.materials.first?.diffuse.contents = UIColor.darkGray
		let stackNode = SCNNode(geometry: stackGeometry)
		stackNode.position = SCNVector3(x: (-CHASSIS_WIDTH/2) + CABIN_WIDTH + GAP + (TRUNK_WIDTH * (3/4)),
		                                y: height + TRUNK_HEIGHT + (STACK_HEIGHT/2),
		                                z: 0)
		nodes.first!.addChildNode(stackNode)
		
		// lights, camera ...
		let cameraNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
		cameraNode.position = SCNVector3(x: 0, y: (CABIN_HEIGHT)/2 - 0.1, z: 0)
		cameraNode.rotation = SCNVector4(x: 0, y: 1, z: 0, w: -Float.pi/2)
		cameraNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
		cameraNode.camera = SCNCamera()
		cameraNode.camera?.zNear = 2
		cameraNode.camera?.zFar = 1000
		camera = cameraNode
		cabinNode.addChildNode(cameraNode)
		
		let lightNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.03))
		lightNode.position = SCNVector3(x: TRUNK_WIDTH/2, y: (TRUNK_HEIGHT / 2) - 0.5, z: 0)
		lightNode.rotation = SCNVector4(x: 0, y: 1, z: 0, w: -Float.pi/2)
		lightNode.geometry?.firstMaterial?.emission.contents = UIColor.white
		lightNode.light = SCNLight()
		lightNode.light?.color = UIColor.white
		lightNode.light?.type = .spot
		lightNode.light?.spotInnerAngle = 0
		lightNode.light?.spotOuterAngle = 60
		lightNode.light?.attenuationStartDistance = 100
		lightNode.light?.attenuationEndDistance = 120
		light = lightNode
		trunkNode.addChildNode(lightNode)
	}
}
