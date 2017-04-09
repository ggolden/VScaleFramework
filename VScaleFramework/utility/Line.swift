//
//  Line.swift
//  VScaleFramework
//
//  Copyright © 2017 Glenn R. Golden. All rights reserved.
//

import Foundation
import SceneKit

// a line in a path made up of one or more segments, joined at the inbound and outbound ends to other lines
public class Line : CustomStringConvertible, Equatable
{
	private static var ID: Int = 0
	private static var lines: [Line] = []
	
	// line id
	public let id: Int
	
	// the line segments
	public private(set) var segments: [Segment] = []
	
	private var outboundJoint: Joint? = nil
	private var inboundJoint: Joint? = nil
	
	// the starting position of the line
	public let startPos: SCNVector3
	
	// the starting angle of the line
	public let startAngle: Float
	
	// find the line with this id
	public static func line(withId: Int) -> Line?
	{
		if let i = lines.index(where: {$0.id == withId})
		{
			return lines[i]
		}
		
		return nil
	}
	
	// init with the starting point and angle
	public init(at: SCNVector3, angle: Float)
	{
		id = Line.ID
		Line.ID += 1
		
		startPos = at
		startAngle = angle
		
		Line.lines.append(self)
	}
	
	// CustomStringConvertible
	public var description: String
	{
		return "Line \(id) in: \(String(describing: inboundJoint)) out: \(String(describing: outboundJoint)) = \(segments.count) segments: \(String(describing: segments.first))"
	}
	
	// Equatable
	static public func == (lhs: Line, rhs: Line) -> Bool
	{
		return lhs.id == rhs.id
	}
	
	// is this line one that can be extended
	public func extendable() -> Bool
	{
		return true
	}
	
	// deep copy
	public func copy(offset: SCNVector3 = SCNVector3Zero) -> Line
	{
		let copy = Line(at: startPos + offset, angle: startAngle)
		for segment in segments
		{
			let seg = segment.copy(offset: offset)
			copy.segments.append(seg)
		}
		copy.outboundJoint = outboundJoint
		copy.inboundJoint = inboundJoint
		
		return copy
	}
	
	// the position and angle from which to extend the line
	public func extendFrom(state: Int = 0) -> (pos: SCNVector3, angle: Float)
	{
		if let s = last(state: state)
		{
			return (s.end, s.angle)
		}
		
		return (startPos, startAngle)
	}
	
	// get the outbound direction joint given the dynamic state for our line
	public func outbound(state: [Int:Int] = [:])  -> Joint?
	{
		// ignoring state, since we have only the one
		return outboundJoint
	}
	
	// set the line's outbound direction joint used when we are in this line state
	public func setOutbound(state: Int = 0, joint: Joint?)
	{
		// ignoring state, since we have only the one
		outboundJoint = joint
	}
	
	// get the inbound direction joint given the dynamic state for our line
	public func inbound(state: [Int:Int] = [:]) -> Joint?
	{
		// ignoring state, since we have only the one
		return inboundJoint
	}
	
	// set the line's inbound direction joint used when we are in this line state
	public func setInbound(state: Int = 0, joint: Joint?)
	{
		// ignoring state, since we have only the one
		inboundJoint = joint
	}
	
	// add a segment
	public func add(segment: Segment)
	{
		segments.append(segment)
	}
	
	// what is the next segment index?
	public func next(segmentIndex: Int) -> Int?
	{
		if segmentIndex + 1 < segments.count
		{
			return segmentIndex + 1
		}
		
		return nil
	}
	
	// which segment (index) to enter when coming into the line from a joint
	// TODO: deal with inbound / outbound?
	public func enter(from: Int, joint: Joint, state: [Int:Int]) -> Int
	{
		// we have just the one entry point, so ignore both states and from id
		return 0;
	}
	
	// get the first segment, given this line state
	public func first(state: Int = 0) -> Segment?
	{
		return segments.first
	}
	
	// get the last segment, given this line state
	public func last(state: Int = 0) -> Segment?
	{
		return segments.last
	}
	
	// what is the linear length of this line?
	public func length(state: Int = 0) -> Float
	{
		var rv: Float = 0
		for segment in segments
		{
			rv += segment.length
		}
		
		return rv
	}
	
	// recreate joints to point to lines with these mapped ids
	public func mapJoints(idMap: [Int:Int])
	{
		if let j = inboundJoint
		{
			inboundJoint = j.mapId(idMap: idMap)
		}
		
		if let j = outboundJoint
		{
			outboundJoint = j.mapId(idMap: idMap)
		}
	}
	
	// add a segment, extending from the cursor to to:
	public func extend(to: SCNVector3) -> Line
	{
		if !extendable()
		{
			return self
		}
		
		let (from, _) = extendFrom()
		
		let segment = Segment(from: from, to: to)
		segments.append(segment)
		
		return self
	}
	
	// add a segment, extending to a position offset from the cursor by a set of x,y,z offsets by:
	public func extend(by: SCNVector3) -> Line
	{
		if !extendable()
		{
			return self
		}
		
		let (from, _) = extendFrom()
		
		let to = from + by
		
		return extend(to: to)
	}
	
	// add a segment, extending to a position length: and angle: (or cursor angle if not specified) from the cursor
	public func extend(angle: Float? = nil, length: Float) -> Line
	{
		if !extendable()
		{
			return self
		}
		
		let (from, fromAngle) = extendFrom()
		
		let a = angle ?? fromAngle
		
		let x: Float = from.x + length * cos(a)
		let z: Float = from.z + length * sin(a)
		let to = SCNVector3Make(x, from.y, z)
		
		return extend(to: to)
	}
	
	// add a segment, extending to a position length: and cursorAngle + diverging: from the cursor
	public func extend(diverging: Float, length: Float) -> Line
	{
		if !extendable()
		{
			return self
		}
		
		let (from, fromAngle) = extendFrom()
		
		let a = fromAngle + diverging
		
		let x: Float = from.x + length * cos(a)
		let z: Float = from.z + length * sin(a)
		let to = SCNVector3Make(x, from.y, z)
		
		return extend(to: to)
	}
	
	// add straight segments, curving to cover arc: radians, each segment length length:, using a radius r: extended out from the current path end
	// + arc is a right hand turn
	// TODO: segmentLength at 0.5 looks good, but causes some performance problems
	public func extend(segmentLength: Float = 5, arc: Float, radius: Float) -> Line
	{
		if !extendable()
		{
			return self
		}
		
		// positive arc, center is positive radius: offset; negative arc, - raduis
		let sign: Float = (arc >= 0 ? 1 : -1)
		
		var center: SCNVector3? = nil
		var start: SCNVector3? = nil
		var endAngle: Float? = nil
		
		if let seg = segments.last
		{
			center = seg.projectionFrom(distance: seg.length, offset: radius * sign)
			start = seg.end
			endAngle = (seg.angle + arc).positiveRadians
		}
		else
		{
			center = startPos.perperdicular(angle: startAngle, length: radius * sign)
			start = startPos
			endAngle = (startAngle + arc).positiveRadians
		}
		
		if let c = center, let s = start, let e = endAngle
		{
			// get the angle of the circle where our tangent hits
			let angleStart = atan2(s.z - c.z, s.x - c.x).positiveRadians
			
			let angleDelta = sign * asin(segmentLength / (2 * radius)) * 2
			
			var angle = angleStart + angleDelta
			var angleTraversed: Float = 0
			while angleTraversed < abs(arc)
			{
				let to = SCNVector3(x: c.x + (radius * cos(angle)), y: s.y, z: c.z + (radius * sin(angle)))
				_ = extend(to: to)
				
				angle += angleDelta
				angleTraversed += abs(angleDelta)
			}
			
			// override the angle of the last segment to complete the arc
			segments.last!.overrideAngle = e
		}
		
		return self
	}
	
	// extend with a segment back to a joint (to a line / state)
	public func close(to j: Joint) -> Line
	{
		if !extendable()
		{
			return self
		}
		
		if let l = Line.line(withId: j.line), let s = l.first(state: j.state)
		{
			// extend the path to meet the start
			let to = s.start
			_ = extend(to: to)
			
			// set the outbound joint of the cursor line to the start
			setOutbound(joint: j)
			
			// set the inbound joint of l to this one
			l.setInbound(state: j.state, joint: Joint(id: id, state: 0))
		}
		
		return self
	}
}
