//
//  TrainCar
//  VScaleFramework
//
//  Copyright © 2017 Glenn R. Golden. All rights reserved.
//

import Foundation
import SceneKit

// base class for all train cars
public class TrainCar
{
	private let CONNECTOR_WIDTH: Float = 1
	private let CONNECTOR_DIM: Float = 0.25
	
	private let TRUCKS_HEIGHT: Float = 0.75
	private let WHEEL_RADIUS: Float = 0.5
	private let WHEEL_DEPTH: Float = 0.1
	
	private let CHASSIS_HEIGHT: Float = 0.5
	
	public let GAP: Float = 0.3
	public let CHASSIS_DEPTH: Float = 2.5
	
	public let GUAGE: Float = 1.5924 // rail center to center, a.k.a guage, based on prototype 4'7" Note: this shold be 1.5924, but HO scale is called 16.5mm guage ???
	
	public private(set) var nodes: [SCNNode] = []
	public var camera: SCNNode? = nil
	public var light: SCNNode? = nil
	public private(set) var length: Float = 0
	
	// offset of all the parts above (y) the positions given in place and adjust
	public var offset: SCNVector3 = SCNVector3Zero
	
	// offsets of trucks from the chassis in x
	private var trucksOffsets: [Float] = []
	
	// ordered like nodes: [chassis (main), leading truck, trailing truck]
	private var placements: [Path.Placement] = []
	
	// what's the length of the path for this car?  If continuous, there is no length
	public var pathLength: Float?
	{
		return placements.first?.length
	}
	
	// what distance along the path is the car?  If continuous, there is no distance
	public var pathDistance: Float?
	{
		return placements.first?.distance
	}
	
	// what is the central length pivot, given a leading distance along the path
	public func pivot(leading: Float) -> Float
	{
		return leading - (length / 2)
	}
	
	// what is the central length pivot, given a trailing distance along the path
	public func pivot(trailing: Float) -> Float
	{
		return trailing + (length / 2)
	}
	
	// what is the central length pivot, given a central distance along the path
	public func pivot(center: Float) -> Float
	{
		return center
	}
	
	// what's the leading length along the path given the current position
	public func leading(pivot: Float) -> Float
	{
		return pivot + (length / 2)
	}
	
	// what's the central length along the path given the current position
	public func center(pivot: Float) -> Float
	{
		return pivot
	}
	
	// what's the trailing length along the path given the current position
	public func trailing(pivot: Float) -> Float
	{
		return pivot - (length / 2)
	}
	
	// create
	public init()
	{
		nodes.append(SCNNode())
		construct()
		
		let (min, max) = nodes.first!.boundingBox
		length = abs(max.x - min.x) // - (2 * CONNECTOR_WIDTH)
		
	}
	
	// place the car on its path, at a leading distance
	public func position(path: Path, leadingDistance: Float)
	{
		let d = pivot(leading: leadingDistance)
		
		let carPlacement = Path.Placement(path: path, distance: d)
		let truckLeadingPlacement = Path.Placement(path: path, distance: d + trucksOffsets[0])
		let truckTrailingPlacement = Path.Placement(path: path, distance: d + trucksOffsets[1])
		
		placements = [carPlacement,truckLeadingPlacement, truckTrailingPlacement]
		
		adjust()
	}
	
	// move the car - return actual movement
	public func advance(distance: Float) -> Float
	{
		var moved: Float? = nil
		
		for p in placements
		{
			if (moved == nil) || (moved! > 0)
			{
				moved = p.advance(distance: distance)
			}
		}
		
		adjust()
		
		return moved ?? 0
	}
	
	// set the car's turnout for a given line on the path
	public func setTurnout(turnout: Line, state: Int)
	{
		for p in placements
		{
			p.state[turnout.id] = state
		}
	}
	
	// adjust the car's position and rotation
	private func adjust()
	{
		if let p = placements.first
		{
			// position the trucks
			for i in 1 ... 2
			{
				nodes[i].position = placements[i].position + offset
				nodes[i].rotation = placements[i].rotation
			}
			
			// position the chassis
			nodes.first!.position = p.position + offset
			
			// rotate the chassis to the segment the trucks make
			let segment = Segment(from: nodes[2].position, to: nodes[1].position)
			nodes.first!.rotation = segment.rotateToPath()
		}
	}
	
	// this gets implemented in the sub-class
	func construct()
	{
	}
	
	//https://en.wikipedia.org/wiki/List_of_railroad_truck_parts
	
	// construct a common (blocky for now) chassis and trucks for any train car
	func constructChassis(width: Float) -> Float
	{
		// build up from the bottom - leaving room for 1/2 of the wheel
		var height : Float = WHEEL_RADIUS
		
		// trucks
		let truckWidth = 6 * WHEEL_RADIUS
		let trucksGeometry = SCNBox(width: CGFloat(truckWidth), height: CGFloat(TRUCKS_HEIGHT), length: CGFloat(CHASSIS_DEPTH - GAP), chamferRadius: 0)
		trucksGeometry.materials.first?.diffuse.contents = UIColor.black
		
		for n in [SCNNode(), SCNNode()]
		{
			let truckNode = SCNNode(geometry: trucksGeometry)
			truckNode.position = SCNVector3(x: 0, y: height + (TRUCKS_HEIGHT/2), z: 0)
			n.addChildNode(truckNode)
			nodes.append(n)
		}
		
		trucksOffsets.append((width/2) - (GAP/2) - (truckWidth/2))
		trucksOffsets.append((-width/2) + (GAP/2) + (truckWidth/2))
		
		// wheels
		let wheelGeomerty = SCNCylinder(radius: CGFloat(WHEEL_RADIUS), height: CGFloat(WHEEL_DEPTH))
		wheelGeomerty.materials.first?.diffuse.contents = UIColor.orange
		let wheelRotation = SCNVector4(x: 1, y: 0, z: 0, w: -Float.pi/2)
		
		let xPlacements = [-(WHEEL_RADIUS * 3/2), WHEEL_RADIUS * 3/2]
		for t in [nodes[1], nodes[2]]
		{
			for x in xPlacements
			{
				let nodeNear = SCNNode(geometry: wheelGeomerty)
				nodeNear.position = SCNVector3(x: x,
				                               y: WHEEL_RADIUS,
				                               z: GUAGE / 2)
				nodeNear.rotation = wheelRotation
				t.addChildNode(nodeNear)
				
				let nodeFar = SCNNode(geometry: wheelGeomerty)
				nodeFar.position = SCNVector3(x: x,
				                              y: WHEEL_RADIUS,
				                              z: -GUAGE / 2)
				nodeFar.rotation = wheelRotation
				t.addChildNode(nodeFar)
			}
		}
		
		height += TRUCKS_HEIGHT
		
		// chassis
		let chassisGeometry = SCNBox(width: CGFloat(width), height: CGFloat(CHASSIS_HEIGHT), length: CGFloat(CHASSIS_DEPTH), chamferRadius: 0)
		chassisGeometry.materials.first?.diffuse.contents = UIColor.red
		let chassisNode = SCNNode(geometry: chassisGeometry)
		chassisNode.position = SCNVector3(x: 0, y: height + (CHASSIS_HEIGHT/2), z: 0)
		nodes.first!.addChildNode(chassisNode)
		
		// connectors
		let connectorGeometry = SCNBox(width: CGFloat(CONNECTOR_WIDTH), height: CGFloat(CONNECTOR_DIM), length: CGFloat(CONNECTOR_DIM), chamferRadius: 0)
		connectorGeometry.materials.first?.diffuse.contents = UIColor.black
		let connector1Node = SCNNode(geometry: connectorGeometry)
		connector1Node.position = SCNVector3(x: (-width/2) - (CONNECTOR_WIDTH/2), y: height + (CONNECTOR_DIM/2), z: 0)
		nodes.first!.addChildNode(connector1Node)
		let connector2Node = SCNNode(geometry: connectorGeometry)
		connector2Node.position = SCNVector3(x: (width/2) + (CONNECTOR_WIDTH/2), y: height + (CONNECTOR_DIM/2), z: 0)
		nodes.first!.addChildNode(connector2Node)
		
		height += CHASSIS_HEIGHT
		
		return height
	}
}
