//
//  Avatar.swift
//  VScaleFramework
//
//  Copyright © 2017 Glenn R. Golden. All rights reserved.
//

import Foundation
import SceneKit

// Avatar represents an actor inside the room, with a light and camera
// that can be controlled in height, position, and head rotation, as well as light level
public class Avatar
{
	private let body: SCNNode
	private let head: SCNNode
	private let light: SCNNode
	private let min_height: Float = 4
	
	// the node containing the avatar
	public let node: SCNNode
	
	// the camera node
	public let camera: SCNNode
	
	// set the avatar height
	public func setHeight(_ h: Float)
	{
		let height = max(min_height, h)
		
		let g = body.geometry as! SCNCapsule
		g.height = CGFloat(height)
		
		body.position = SCNVector3(x: 0, y: height / 2, z: 0)
		head.position = SCNVector3(x: 0, y: height, z: -1.5)
	}
	
	// set the avatar X (left to right) position
	public func setPositionX(_ x: Float)
	{
		node.position.x = x
	}
	
	// set the avatar Z (front to back) position
	public func setPositionZ(_ z: Float)
	{
		node.position.z = z
	}
	
	// set the avatar head rotation (PI to -PI)
	public func setRotation(_ r: Float)
	{
		node.rotation = SCNVector4(x: 0, y: 1, z: 0, w: Float(-r))
	}
	
	// set the light level (1000 lumens is default)
	public func setLightLevel(lumens : Float)
	{
		light.light?.intensity = CGFloat(lumens)
		light.geometry?.firstMaterial?.emission.contents =  UIColor(white: CGFloat(min(lumens / 1000.0, 1.0)), alpha: 1.0)
	}
	
	// create with given height: and location:, adding to inNode:
	public init(height: Float, location: SCNVector3, inNode: SCNNode)
	{
		node = SCNNode()
		
		body = SCNNode(geometry: SCNCapsule(capRadius: 0.5, height: CGFloat(height)))
		body.position = SCNVector3(x: 0, y: height/2, z: 0)
		
		head = SCNNode(geometry: SCNCone(topRadius: 2, bottomRadius: 3, height: 4))
		head.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float.pi/2)
		head.position = SCNVector3(x: 0, y: height, z: -1.5)
		
		camera = SCNNode(geometry: SCNSphere(radius: 1))
		camera.position = SCNVector3(x: 0, y: -2, z: 0)
		camera.rotation = SCNVector4(x: 1, y: 0, z: 0, w: -Float.pi/2)
		camera.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
		camera.camera = SCNCamera()
		camera.camera?.zNear = 2
		camera.camera?.zFar = 1000
		
		light = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.3))
		light.position = SCNVector3(x: 0, y: -2, z: -2)
		light.rotation = SCNVector4(x: 1, y: 0, z: 0, w: -Float.pi/2)
		light.geometry?.firstMaterial?.emission.contents = UIColor.white
		light.light = SCNLight()
		light.light?.color = UIColor.white
		light.light?.type = .spot
		light.light?.spotInnerAngle = 0
		light.light?.spotOuterAngle = 60
		
		head.addChildNode(camera)
		head.addChildNode(light)
		
		node.addChildNode(body)
		node.addChildNode(head)
		
		node.position = location
		inNode.addChildNode(node)
	}
}
