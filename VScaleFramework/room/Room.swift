//
//  Room.swift
//  VScaleFramework
//
//  Copyright © 2017 Glenn R. Golden. All rights reserved.
//

import Foundation
import SceneKit

// models a room, in which we can put our layout
// contains ceiling lights which can be level controller (
public class Room
{
	private let dim: SCNVector3
	private let loc: SCNVector3
	private var lights: [SCNNode] = []
	private var mainLights: [SCNNode] = []
	public private(set) var backdropGeometry: SCNGeometry! = nil
	public private(set) var camera: SCNNode! = nil
	
	// 4 feet hight and deep bench (expressed in cm)
	private let bench_size : Float = 121.92
	
	// the node containing the room
	public let node: SCNNode
	
	// the bench to hold the layout in the room
	public let bench: SCNNode
	
	// set the over-layout lights level (1000 lumens is default)
	public func setLightLevel(lumens : Float)
	{
		for node in lights
		{
			node.light?.intensity = CGFloat(lumens)
			node.geometry?.firstMaterial?.emission.contents =  UIColor(white: CGFloat(min(lumens / 1000.0, 1.0)), alpha: 1.0)
		}
	}
	
	// set the main (ceiling center) light level (1000 lumens is default)
	public func setMainLightLevel(lumens : Float)
	{
		for node in mainLights
		{
			node.light?.intensity = CGFloat(lumens)
			node.geometry?.firstMaterial?.emission.contents =  UIColor(white: CGFloat(min(lumens / 1000.0, 1.0)), alpha: 1.0)
		}
	}
	
	// create: dimensions in x,y,z, location of back left bottom corner, in this node
	public init(dimensions : SCNVector3, location: SCNVector3, inNode: SCNNode)
	{
		node = SCNNode()
		dim = dimensions
		loc = location
		bench = SCNNode()
		
		constructWalls()
		constructBench()
		constructBackdrop()
		
		node.position = location
		inNode.addChildNode(node)
	}
	
	private func constructWalls()
	{
		let floor = SCNNode(geometry: SCNPlane(width: CGFloat(dim.width), height: CGFloat(dim.depth)))
		floor.rotation = SCNVector4(x: 1, y: 0, z: 0, w: -Float.pi/2)
		floor.position = SCNVector3(x: dim.width / 2, y: 0, z: dim.depth / 2)
		node.addChildNode(floor)
		
		let ceil = SCNNode(geometry: SCNPlane(width: CGFloat(dim.width), height: CGFloat(dim.depth)))
		ceil.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float.pi/2)
		ceil.position = SCNVector3(x: dim.width / 2, y: dim.height, z: dim.depth / 2)
		node.addChildNode(ceil)
		
		let left = SCNNode(geometry: SCNPlane(width: CGFloat(dim.depth), height: CGFloat(dim.height)))
		left.rotation = SCNVector4(x: 0, y: 1.0, z: 0, w: Float.pi/2)
		left.position = SCNVector3(x: 0, y: dim.height / 2, z: dim.depth / 2)
		node.addChildNode(left)
		
		let right = SCNNode(geometry: SCNPlane(width: CGFloat(dim.depth), height: CGFloat(dim.height)))
		right.rotation = SCNVector4(x: 0, y: 1, z: 0, w: -Float.pi/2)
		right.position = SCNVector3(x: dim.width, y: dim.height / 2, z: dim.depth / 2)
		node.addChildNode(right)
		
		let back = SCNNode(geometry: SCNPlane(width: CGFloat(dim.width), height: CGFloat(dim.height)))
		back.position = SCNVector3(x: dim.width / 2, y: dim.height / 2, z: 0)
		node.addChildNode(back)
		
		let front = SCNNode(geometry: SCNPlane(width: CGFloat(dim.width), height: CGFloat(dim.height)))
		front.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float.pi)
		front.position = SCNVector3(x: dim.width / 2, y: dim.height / 2, z: dim.depth)
		node.addChildNode(front)
		
		ceil.geometry?.firstMaterial = SCNMaterial(imageName: "ceiling.jpg", inBundle : Bundle(for: type(of: self)), imageWidth: 28, width: dim.width, height: dim.depth)
		floor.geometry?.firstMaterial = SCNMaterial(imageName: "wood.png", inBundle : Bundle(for: type(of: self)),imageWidth: 60, width: dim.width, height: dim.depth)
		back.geometry?.firstMaterial = SCNMaterial(imageName: "brick-wall-free-textures-01.jpg", inBundle : Bundle(for: type(of: self)),
		                                           imageHeight : 129.54, width : dim.width, height: dim.height)
		front.geometry?.firstMaterial = SCNMaterial(imageName: "door_wall_3.png", inBundle : Bundle(for: type(of: self)),
		                                            imageWidth : dim.width, width : -dim.width, height: -dim.height)
		// brick-wall-free-textures-01.jpg  h: ~129.54 - http://www.highresolutiontextures.com/stone-wall-brick-wall-free-textures
		let wallMaterial = SCNMaterial(imageName: "brick-wall-free-textures-01.jpg", inBundle : Bundle(for: type(of: self)),
		                               imageHeight : 129.54, width : dim.depth, height: dim.height)
		left.geometry?.firstMaterial = wallMaterial
		right.geometry?.firstMaterial = wallMaterial
		
		var x : Float = 80
		_ = Picture(imageName: "rr_picture_1.jpg", inBundle: Bundle(for: type(of: self)), imageWidth: 30.48, location: SCNVector3(x: x, y: 40, z: 0), inNode: left); x -= 40
		_ = Picture(imageName: "rr_picture_2.jpg", inBundle: Bundle(for: type(of: self)), imageWidth: 30.48, location: SCNVector3(x: x, y: 40, z: 0), inNode: left); x -= 40
		_ = Picture(imageName: "rr_picture_3.jpg", inBundle: Bundle(for: type(of: self)), imageWidth: 30.48, location: SCNVector3(x: x, y: 40, z: 0), inNode: left); x -= 40
		_ = Picture(imageName: "rr_picture_4.jpg", inBundle: Bundle(for: type(of: self)), imageWidth: 30.48, location: SCNVector3(x: x, y: 40, z: 0), inNode: left)
		
		let lightNode1 = SCNNode(geometry: SCNBox(width: 3, height: 3, length: 3, chamferRadius: 1))
		lightNode1.geometry?.firstMaterial?.emission.contents = UIColor.white
		lightNode1.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float.pi)
		let light1 = SCNLight()
		light1.color = UIColor.white
		light1.type = .spot
		light1.spotInnerAngle = 0
		light1.spotOuterAngle = 100
		lightNode1.light = light1
		lightNode1.position = SCNVector3(x: -(dim.width / 2) + 122, y: -(dim.depth / 2) + 60, z: 0)
		ceil.addChildNode(lightNode1)
		
		camera = SCNNode()
		camera.camera = SCNCamera()
		camera.position = SCNVector3(x: 0, y: -(dim.depth / 2) + 60, z: 0)
		camera.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float.pi)
		camera.camera!.zNear = 10
		camera.camera!.zFar = 400
		camera.camera!.xFov = 124
		ceil.addChildNode(camera)
		
		let lightNode2 = SCNNode(geometry: SCNBox(width: 3, height: 3, length: 3, chamferRadius: 1))
		lightNode2.geometry?.firstMaterial?.emission.contents = UIColor.white
		lightNode2.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float.pi)
		let light2 = SCNLight()
		light2.color = UIColor.white
		light2.type = .spot
		light2.spotInnerAngle = 0
		light2.spotOuterAngle = 100
		lightNode2.light = light2
		lightNode2.position = SCNVector3(x: (dim.width / 2) - 122, y: -(dim.depth / 2) + 60, z: 0)
		ceil.addChildNode(lightNode2)
		
		let lightNode3 = SCNNode(geometry: SCNBox(width: 3, height: 3, length: 3, chamferRadius: 1))
		lightNode3.geometry?.firstMaterial?.emission.contents = UIColor.white
		lightNode3.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float.pi)
		let light3 = SCNLight()
		light3.color = UIColor.white
		light3.type = .spot
		light3.spotInnerAngle = 0
		light3.spotOuterAngle = 180
		lightNode3.light = light3
		lightNode3.position = SCNVector3(x: 0, y: 0, z: 0)
		ceil.addChildNode(lightNode3)
		
		lights.append(lightNode1)
		lights.append(lightNode2)
		mainLights.append(lightNode3)
	}
	
	private func constructBench()
	{
		// position the bench 4 feet up along the back wall - in the bench's coordinate space, the top is y=0
		bench.position = SCNVector3(x: 0, y: bench_size, z: 0)
		
		let top = SCNNode(geometry: SCNPlane(width: CGFloat(dim.width), height: CGFloat(bench_size)))
		top.rotation = SCNVector4(x: 1, y: 0, z: 0, w: -Float.pi/2)
		top.position = SCNVector3(x: dim.width / 2, y: 0, z: bench_size / 2)
		bench.addChildNode(top)
		
		let front = SCNNode(geometry: SCNPlane(width: CGFloat(dim.width), height: CGFloat(bench_size)))
		front.position = SCNVector3(x: dim.width / 2, y: -bench_size / 2, z: bench_size)
		bench.addChildNode(front)
		
		top.geometry?.firstMaterial?.diffuse.contents = UIColor.brown
		// let the curtain cover the full height
		front.geometry?.firstMaterial = SCNMaterial(imageName: "black-curtain.jpg", inBundle : Bundle(for: type(of: self)),
		                                            imageHeight : bench_size, width : dim.width, height: bench_size)
		
		node.addChildNode(bench)
	}
	
	private func constructBackdrop()
	{
		// extend the full width - 2 inches, and 3 feet (on the bench)
		let width: Float = dim.width - (2 * 2.54)
		let height: Float = 91.44
		
		backdropGeometry = SCNPlane(width: CGFloat(width), height: CGFloat(height))
		backdropGeometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
		
		let backdrop = SCNNode(geometry: backdropGeometry)
		backdrop.position = SCNVector3(x: (width / 2) + 2.54, y: height / 2, z: 2.54)
		bench.addChildNode(backdrop)
		
		// https://www.theatreworldbackdrops.com/2103/european-countryside-backdrop  European-Countryside-Scenic-Backdrop.jpg  h=height
		backdropGeometry?.firstMaterial = SCNMaterial(imageName: "European-Countryside-Scenic-Backdrop.jpg", inBundle : Bundle(for: type(of: self)),
		                                              imageHeight : height, width : width, height: height)
	}
}
