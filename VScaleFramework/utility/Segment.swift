//
//  Segment.swift
//  VScaleFramework
//
//  Copyright © 2017 Glenn R. Golden. All rights reserved.
//

import Foundation
import SceneKit

// a straight line segment used in lines in paths
public class Segment : CustomStringConvertible
{
	// starting position of the segment
	public let start : SCNVector3
	
	// ending position of the segment
	public let end: SCNVector3
	
	// length of the segment
	public let length : Float
	
	// override to the natural angle of the segment
	public var overrideAngle: Float? = nil
	
	// the natural (or overriden) angle of the segment
	public var angle: Float
	{
		if let o = overrideAngle
		{
			return o
		}
		
		return actualAngle
	}
	
	private let dX: Float
	private let dY: Float
	private let dZ: Float
	private let EmSx: Float
	private let EmSy: Float
	private let EmSz: Float
	private let actualAngle: Float
	
	// CustomStringConvertible
	public var description: String
	{
		return "\(start) -> \(end)"
	}
	
	// copy the segment with an offset
	public func copy(offset: SCNVector3 = SCNVector3Zero) -> Segment
	{
		let copy = Segment(from: start + offset, to: end + offset)
		return copy
	}
	
	// create from: to:
	public init(from: SCNVector3, to: SCNVector3)
	{
		start = from
		end = to
		length = start.distance(to: end)
		EmSx = end.x - start.x
		EmSy = end.y - start.y
		EmSz = end.z - start.z
		dX = abs(EmSx)
		dY = abs(EmSy)
		dZ = abs(EmSz)
		actualAngle = atan2(EmSz, EmSx)
	}
	
	// compute a position moving along the segment from: for a distance:
	public func move(from: SCNVector3, distance : Float) -> SCNVector3
	{
		let distanceToEdge = from.distance(to: end)
		if (distance > distanceToEdge)
		{
			// stop at end, not beyond
			return end
		}
		
		let segment = (distance / length)
		let dx = segment * dX
		let dz = segment * dZ
		let dy = segment * dY
		
		let xFactor : Float = (start.x > end.x) ? -1 : 1
		let zFactor : Float = (start.z > end.z) ? -1 : 1
		let yFactor : Float = (start.y > end.y) ? -1 : 1
		
		let rv = SCNVector3(x: from.x + (xFactor * dx), y: from.y + (yFactor * dy), z: from.z + (zFactor * dz))
		return rv
	}
	
	// compute a position moving along the segment from: for a distance coorsponding to the time and velocity
	public func move(from: SCNVector3, time : Float, velocity : Float) -> SCNVector3
	{
		let distance = time * velocity
		return move(from: from, distance: distance)
	}
	
	// is this point on the segment?
	public func isOnPath(_ p: SCNVector3) -> Bool
	{
		// must match y: TODO: y may elevate
		if (p.y != start.y)
		{
			return false
		}
		
		// from: http://stackoverflow.com/questions/907390/how-can-i-tell-if-a-point-belongs-to-a-certain-line
		// The best way to determine if a point R = (rx, ry) lies on the line connecting points P = (px, py) and Q = (qx, qy) is to check whether the determinant of the matrix
		// {{qx - px, qy - py}, {rx - px, ry - py}},
		// namely (qx - px) * (ry - py) - (qy - py) * (rx - px) is close to 0.
		
		let det = (EmSx * (p.z - start.z)) - (EmSz * (p.x - start.x))
		// let det = (lengthX * (Double(p.z) - startZ)) - (lengthZ * (Double(p.x) - startX))
		let rv = abs(det) < 3 // 0.5 // 0.05// 0.005
		// if (!rv) { print("isOnPath \(p) det= \(det)") }
		
		return rv
	}
	
	// return a point on the segment, projected normal from the given point
	public func projectionTo(from p : SCNVector3) -> SCNVector3
	{
		// http://math.stackexchange.com/questions/62633/orthogonal-projection-of-a-point-onto-a-line
		
		// handle 3d
		
		var x = p.x
		let y = p.y
		var z = p.z
		
		if EmSx == 0
		{
			x = start.x
			// z = p.z
		}
		else if EmSz == 0
		{
			// x = p.x
			z = start.z
		}
		else
		{
			let C = EmSz / EmSx
			let D = -1 * (EmSx / EmSz)
			let A =  start.z - (C * start.x)
			let B = p.z + ((-1 * D) * p.x)
			
			x = (B - A) / (C - D)
			z = (C * x) + A
		}
		
		return SCNVector3(x: x, y: y, z: z)
	}
	
	// point extended (offset) from the path (normal) at a distance along the path (making a right turn from the path)
	public func projectionFrom(distance: Float, offset: Float) -> SCNVector3
	{
		// v is tha angle at the to point between the length (h) and DX
		// for the full length triangle:
		// sin(v) = DY / L
		// cos(v) = DX / L
		// for the smaller triangls offsetting the f1 and f2 points from f: v is the same v as the big triangls, the angle at f between the short l (width / 2) and the dy
		// sin(v) = dx / l
		// cos(v) = dy / l
		// combining:
		// DY / L = dx / l
		// DX / L = dy / l
		// dx = l * (DY / L)
		// dy = l * (DX / L)
		
		// length of path
		let L = length
		
		// offset from (normal to) the line
		let l = offset
		
		// x component of L
		let DX = EmSx
		
		// z component of L
		let DZ = EmSz
		
		let dx = Float((l * (-DZ / L)))
		let dz = Float((l * (DX / L)))
		
		// point on path
		let pt = move(from: start, time: 1, velocity: distance)
		
		// print("f \(f)  t \(t)  L \(L)  l \(l)  DX \(DX)  DZ \(DZ)  dx \(dx)  dz \(dz)")
		
		// f1 and f2 are the from points, accounting for width
		let p = SCNVector3(x: pt.x + dx, y: pt.y, z: pt.z + dz)
		
		return p
	}
	
	// compute the rotation to along with the segment
	public func rotateToPath() -> SCNVector4
	{
		var theta : Float = 0
		if EmSx == 0
		{
			// +-90 degree rotation
			if EmSz >= 0
			{
				theta = -Float.pi/2
			}
			else
			{
				theta = Float.pi/2
			}
		}
		else if EmSz == 0
		{
			// already aligned with X, 0 or 180 degree rotation
			if EmSx >= 0
			{
				theta = 0
			}
			else
			{
				theta = Float.pi
			}
		}
		else
		{
			if EmSx >= 0
			{
				theta = -atan(EmSz/EmSx)
			}
			else
			{
				theta = -atan(EmSz/EmSx) - Float.pi
			}
		}
		
		// rotate around y
		return SCNVector4(x: 0, y: 1, z: 0, w: theta)
	}
	
	// compute a rotation to align with the reverse of the segment
	public func rotateToPathReversed() -> SCNVector4
	{
		let start = self.end
		let end = self.start
		let EmSx = end.x - start.x
		// let EmSy = end.y - start.y
		let EmSz = end.z - start.z
		
		var theta : Float = 0
		if EmSx == 0
		{
			// +-90 degree rotation
			if EmSz >= 0
			{
				theta = -Float.pi/2
			}
			else
			{
				theta = Float.pi/2
			}
		}
		else if EmSz == 0
		{
			// already aligned with X, 0 or 180 degree rotation
			if EmSx >= 0
			{
				theta = 0
			}
			else
			{
				theta = Float.pi
			}
		}
		else
		{
			if EmSx >= 0
			{
				theta = -atan(EmSz/EmSx)
			}
			else
			{
				theta = -atan(EmSz/EmSx) - Float.pi
			}
		}
		
		// rotate around y
		return SCNVector4(x: 0, y: 1, z: 0, w: theta)
	}
}
