//
//  Layout.swift
//  VScaleFramework
//
//  Copyright © 2017 Glenn R. Golden. All rights reserved.
//

import Foundation
import SceneKit

// a VScale layout, with track plan, trains, and scenery or structure items
public class Layout
{
	// all the items
	private var items: [LayoutItem] = []
	
	// compute the height above trackPlan that trainPath has
	private var trainOffsetY: Float? = nil
	
	// the node containing all items
	public let node: SCNNode
	
	// the track plan
	public let trackPlan: Path
	
	public private(set) var trainOffset: SCNVector3 = SCNVector3Zero
	
	public init()
	{
		node  = SCNNode()
		trackPlan = Path()
	}
	
	public convenience init(position: SCNVector3 = SCNVector3Make(0, 0, 0), rotation: SCNVector4 = SCNVector4Make(0, 0, 0, 0), inNode: SCNNode)
	{
		self.init()
		
		node.position = position
		node.rotation = rotation
		inNode.addChildNode(node)
	}
	
	public func addItem(_ item: LayoutItem, at: Placement) -> LayoutItem
	{
		items.append(item)
		
		item.position = at.position
		item.rotation = at.rotation
		node.addChildNode(item.node)
		
		return item
	}
	
	public func layRailroad()
	{
		// lay track bed and track on each segment of the trackPlan path
		trackPlan.eachSegment() { (s: Segment) in layRailroadSegment(s) }
		
		// the train runs on a path elevated from this, above the tracks
		trainOffset = SCNVector3(x: 0, y: trainOffsetY!, z: 0)
	}
	
	private func layRailroadSegment(_ s: Segment)
	{
		// track bed
		let bed = TrackBed(length: s.length)
		bed.node.position = s.start
		bed.node.rotation = s.rotateToPath()
		node.addChildNode(bed.node)
		
		// track
		let track = Track(length: s.length)
		track.node.position = s.start + SCNVector3(x: 0, y: bed.height, z: 0)
		track.node.rotation = s.rotateToPath()
		node.addChildNode(track.node)
		
		if trainOffsetY == nil
		{
			trainOffsetY = bed.height + track.height
		}
	}
}
