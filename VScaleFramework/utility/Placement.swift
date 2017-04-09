//
//  Placement.swift
//  VScaleFramework
//
//  Copyright © 2017 Glenn R. Golden. All rights reserved.
//

import Foundation
import SceneKit

// statically places and orients an item relative to a path
// use Path.Placement for a dynamic placement that can move
public class Placement
{
	public let position: SCNVector3
	public let rotation: SCNVector4
	
	// absolute placement
	public init(position: SCNVector3, rotation: SCNVector4 = SCNVector4Make(0, 0, 0, 0))
	{
		self.position = position
		self.rotation = rotation
	}
	
	// along to a path
	public convenience init(path: Path, state: [Int:Int] = [:], distance: Float, offset: Float)
	{
		let placement = Path.Placement(path: path, state: state, distance: distance)
		
		let position = placement.projectionFrom(offset: offset)
		let rotation = placement.rotation
		
		self.init(position: position, rotation: rotation)
	}
}
