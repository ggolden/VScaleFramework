//
//  Platform.swift
//  VScaleFramework
//
//  Copyright © 2017 Glenn R. Golden. All rights reserved.
//

import Foundation
import SceneKit

// a simple layout item, a train platform
public class Platform : LayoutItem
{
	private let PLATFORM_WIDTH: Float = 20
	private let BASE_HEIGHT: Float = 3
	private let BASE_DEPTH: Float = 6
	
	private let ROOF_HEIGHT: Float = 0.125
	private let ROOF_DEPTH: Float = 6
	
	private let PILLAR_RADIUS: Float = 0.25
	private let PILLAR_HEIGHT: Float = 10
	
	override func construct()
	{
		let base = SCNNode(geometry: SCNBox(width: CGFloat(PLATFORM_WIDTH), height: CGFloat(BASE_HEIGHT), length: CGFloat(BASE_DEPTH), chamferRadius: 0))
		base.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
		base.position = SCNVector3(x: 0, y: BASE_HEIGHT/2, z: 0)
		node.addChildNode(base)
		
		let roof = SCNNode(geometry: SCNBox(width: CGFloat(PLATFORM_WIDTH), height: CGFloat(ROOF_HEIGHT), length: CGFloat(ROOF_DEPTH), chamferRadius: 0))
		roof.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
		roof.position = SCNVector3(x: 0, y: BASE_HEIGHT + PILLAR_HEIGHT + (ROOF_HEIGHT/2), z: 0)
		node.addChildNode(roof)
		
		let pillarL =  SCNNode(geometry: SCNCone(topRadius: CGFloat(PILLAR_RADIUS), bottomRadius: CGFloat(PILLAR_RADIUS), height: CGFloat(PILLAR_HEIGHT)))
		pillarL.geometry?.firstMaterial?.diffuse.contents = UIColor.darkGray
		pillarL.position = SCNVector3(x: -PLATFORM_WIDTH/3, y: BASE_HEIGHT + (PILLAR_HEIGHT/2), z: 0)
		node.addChildNode(pillarL)
		
		let pillarR =  SCNNode(geometry: SCNCone(topRadius: CGFloat(PILLAR_RADIUS), bottomRadius: CGFloat(PILLAR_RADIUS), height: CGFloat(PILLAR_HEIGHT)))
		pillarR.geometry?.firstMaterial?.diffuse.contents = UIColor.darkGray
		pillarR.position = SCNVector3(x: PLATFORM_WIDTH/3, y: BASE_HEIGHT + (PILLAR_HEIGHT/2), z: 0)
		node.addChildNode(pillarR)
	}
}

