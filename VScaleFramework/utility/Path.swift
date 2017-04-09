//
//  Path.swift
//  VScaleFramework
//
//  Copyright © 2017 Glenn R. Golden. All rights reserved.
//

import Foundation
import SceneKit

// a path made up of one or more lines of various types
public class Path: CustomStringConvertible
{
	// the lines of the path
	public private(set) var lines: [Line] = []
	
	// the length of the path
	public private(set) var length: Float = 0
	
	// CustomStringConvertible
	public var description: String
	{
		var rv = "Path: \n"
		
		for line in lines
		{
			rv += line.description + "\n"
		}
		
		return rv
	}
	
	// what's the next line / segment from the given ones
	private func next(lineIndex: Int, segmentIndex: Int, state: [Int:Int] /*= [:]*/) -> (lineIndex: Int, segmentIndex: Int)?
	{
		// current line
		let line = lines[lineIndex]
		
		// if we have a next segment
		if let nextSegment = line.next(segmentIndex: segmentIndex)
		{
			return (lineIndex, nextSegment)
		}
		
		// pick the outbound joint for our line type and our line state
		if let outbound = line.outbound(state: state), let toLineIndex = lines.index(where: {$0.id == outbound.line})
		{
			let toLine = lines[toLineIndex]
			let toSegmentIndex = toLine.enter(from: line.id, joint: outbound, state: state)
			
			return (toLineIndex, toSegmentIndex)
		}
		
		return nil
	}
	
	// access the last line
	public var lastLine: Line?
	{
		return lines.last
	}
	
	// create
	public init()
	{
	}
	
	// create a line in the path, from and with this inbound joint.
	public func line(inbound: Joint) -> Line
	{
		let fromLine = Line.line(withId: inbound.line)!
		let (fromPos, fromAngle) = fromLine.extendFrom(state: inbound.state)
		
		let line = Line(at: fromPos, angle: fromAngle)
		line.setInbound(joint: inbound)
		
		fromLine.setOutbound(state: inbound.state, joint: Joint(line: line, state: 0))
		
		lines.append(line)
		
		return line
	}
	
	// create a line in the path from this position with this starting angle
	public func line(at: SCNVector3, angle: Float) -> Line
	{
		let line = Line(at: at, angle: angle)
		
		lines.append(line)
		
		return line
	}
	
	// create a turnout, from and with this inbound joint
	public func turnout(inbound: Joint) -> Turnout
	{
		let fromLine = Line.line(withId: inbound.line)!
		let (fromPos, fromAngle) = fromLine.extendFrom(state: inbound.state)
		
		let turnout = Turnout(at: fromPos, angle: fromAngle)
		turnout.setInbound(joint: inbound)
		
		fromLine.setOutbound(state: inbound.state, joint: Joint(line: turnout, state: 0))
		
		lines.append(turnout)
		
		return turnout
	}
	
	// create a turnout, from this position with this starting angle
	public func turnout(at: SCNVector3, angle: Float) -> Turnout
	{
		let turnout = Turnout(at: at, angle: angle)
		
		lines.append(turnout)
		
		return turnout
	}
	
	// create a turnin, from and with this inbound joint
	public func turnin(state: Int, inbound: Joint) -> Turnin
	{
		let fromLine = Line.line(withId: inbound.line)!
		let (fromPos, fromAngle) = fromLine.extendFrom(state: inbound.state)
		
		let turnin = Turnin(at: fromPos, angle: fromAngle, toMain: (state == 0))
		turnin.setInbound(state: state, joint: inbound)
		
		fromLine.setOutbound(state: inbound.state, joint: Joint(line: turnin, state: 0))
		
		lines.append(turnin)
		
		return turnin
	}
	
	// create a turnin, from this position with this starting angle
	public func turnin(state: Int, at: SCNVector3, angle: Float) -> Turnin
	{
		let turnin = Turnin(at: at, angle: angle, toMain: (state == 0))
		
		lines.append(turnin)
		
		return turnin
	}
	
	// do something with each segment
	public func eachSegment(_ f: (Segment) -> Void)
	{
		let segments: [Segment] = lines.flatMap { $0.segments }
		
		for segment in segments
		{
			f(segment)
		}
	}
	
	// create a new path which is offset from self
	public func path(offset: SCNVector3) -> Path
	{
		let p = Path()
		
		var idMap = [Int:Int]()
		
		// duplicate all the lines, with the offset, mapping source and copy IDs
		for line in lines
		{
			let newLine = line.copy(offset: offset)
			p.lines.append(newLine)
			
			idMap[line.id] = newLine.id
		}
		
		// adjust all the joints source IDs to copy IDs
		for line in p.lines
		{
			line.mapJoints(idMap: idMap)
		}
		
		return p
	}
	
	// a placement along this path
	public class Placement
	{
		weak private var path: Path?
		private var lineIndex: Int
		private var segmentIndex: Int
		private var segmentDistance: Float
		
		// is the path continuous, given the state of all the lines
		public private(set) var continuous = false
		
		// the path length, only if not continuous
		public private(set) var length: Float? = 0
		
		// the distance of this placement along the path
		public private(set) var distance: Float = 0
		
		// the states of each line (by id) of the path
		public var state: [Int:Int] = [:]
		{
			didSet
			{
				setContinuous()
				setLength()
			}
		}
		
		// walk the path to see if it is continuous, based on current states
		private func setContinuous()
		{
			if let p = path
			{
				// if while traversing the path, we end up on a line again, we have a continuous path
				// TODO: a wye loop will see the line again, but running backwards, so it's a different line ...
				var line = 0
				var segment = 0
				var linesSeen: Set<Int> = [line]
				
				while let next = p.next(lineIndex: line, segmentIndex: segment, state: state)
				{
					// when we cross to a new line
					if next.lineIndex != line
					{
						if (linesSeen.contains(next.lineIndex))
						{
							continuous = true
							return
						}
						else
						{
							linesSeen.insert(next.lineIndex)
						}
					}
					
					(line, segment) = next
				}
				
				continuous = false
			}
		}
		
		// walk the path setting the length
		private func setLength()
		{
			if let p = path
			{
				if continuous
				{
					length = nil
					return
				}
				
				if p.lines.isEmpty
				{
					length = 0
					return
				}
				
				// start here, go till end
				var line = 0
				var segment = 0
				var seg = p.lines[line].segments[segment]
				var len = seg.length
				
				while let next = p.next(lineIndex: line, segmentIndex: segment, state: state)
				{
					(line, segment) = next
					seg = p.lines[line].segments[segment]
					len += seg.length
				}
				
				length = len
			}
		}
		
		// create the placement on a path, with a given set of line states, at a distance along the path
		public init(path p: Path, state s: [Int:Int] = [:], distance d: Float)
		{
			path = p
			state = s
			
			let distanceToAdvance = max(0, d)
			
			// start at the start, advance the distance
			distance = 0
			lineIndex = 0
			segmentIndex = 0
			segmentDistance = 0
			
			setContinuous()
			setLength()
			
			_ = advance(distance: distanceToAdvance)
		}
		
		// advance the position a distance (if possible), return actual movement
		public func advance(distance delta: Float) -> Float
		{
			var moved: Float = 0
			
			if let p = path
			{
				// the segment
				var segment = p.lines[lineIndex].segments[segmentIndex]
				
				// we will compute the move from the segment's leading edge: adjust the distance to move, adding how far into the segment we already are
				var distanceToMove = delta + segmentDistance
				moved -= segmentDistance
				
				// advance to the segment for this (adjusted) delta
				while distanceToMove > segment.length
				{
					// advance to the end of this segment
					distanceToMove -= segment.length
					moved += segment.length
					segmentDistance = segment.length
					
					// if we have more segments
					if let next = p.next(lineIndex: lineIndex, segmentIndex: segmentIndex, state: state)
					{
						// move into the next segment
						(lineIndex, segmentIndex) = next
						segment = p.lines[lineIndex].segments[segmentIndex]
						segmentDistance = 0
					}
					else
					{
						// we have run out of path
						distanceToMove = 0
					}
				}
				
				// if left with distance to move, we can advance into this segment
				if (distanceToMove > 0)
				{
					segmentDistance = distanceToMove
					moved += distanceToMove
				}
				
				// adjust our distance into the path, wrapping ??? .truncatingRemainder(dividingBy: p.length)
				distance += moved
			}
			
			return moved
		}
		
		// position vector for the placement's distance along the path
		public var position: SCNVector3
		{
			if let p = path
			{
				let segment = p.lines[lineIndex].segments[segmentIndex]
				let rv = segment.move(from: segment.start, distance: segmentDistance)
				return rv
			}
			
			return SCNVector3Zero
		}
		
		// rotation vector for the placement's distance along the path
		public var rotation: SCNVector4
		{
			if let p = path
			{
				let segment = p.lines[lineIndex].segments[segmentIndex]
				let rv = segment.rotateToPath()
				return rv
			}
			
			return SCNVector4Zero
		}
		
		public func projectionFrom(offset: Float) -> SCNVector3
		{
			if let p = path
			{
				let segment = p.lines[lineIndex].segments[segmentIndex]
				let rv = segment.projectionFrom(distance: segmentDistance, offset: offset)
				return rv
			}
			
			return SCNVector3Zero
		}
	}
}

