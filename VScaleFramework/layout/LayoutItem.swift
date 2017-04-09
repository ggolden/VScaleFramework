//
//  LayoutItem.swift
//  VScaleFramework
//
//  Copyright © 2017 Glenn R. Golden. All rights reserved.
//

import Foundation
import SceneKit

// base class for any layout scenery or structure item
public class LayoutItem
{
	public let node : SCNNode
	
	public var position: SCNVector3
	{
		get
		{
			return node.position
		}
		
		set(position)
		{
			node.position = position
		}
	}
	
	public var rotation: SCNVector4
	{
		get
		{
			return node.rotation
		}
		
		set(rotation)
		{
			node.rotation = rotation
		}
	}
	
	public init()
	{
		node = SCNNode()
		construct()
	}
	
	public convenience init(position: SCNVector3, rotation: SCNVector4 = SCNVector4Make(0, 0, 0, 0), inNode: SCNNode)
	{
		self.init()
		
		node.position = position
		node.rotation = rotation
		inNode.addChildNode(node)
	}
	
	func construct()
	{
	}
}
