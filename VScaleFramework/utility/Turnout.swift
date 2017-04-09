//
//  Turnout.swift
//  VScaleFramework
//
//  Copyright © 2017 Glenn R. Golden. All rights reserved.
//

import Foundation
import SceneKit

public class Turnout: Line
{
	private let LENGTH: Float = 10
	private let ANGLE: Float = Float.pi/6
	
	private var outboundJointAlt: Joint? = nil
	
	// which way is the turnout set
	public private(set) var state: Int = 0
	
	// CustomStringConvertible
	public override var description: String
	{
		let srv = super.description
		return "Turnout \(srv) out(alt) \(String(describing: outboundJointAlt))"
	}
	
	// turnouts may not be extended with new segments
	public override func extendable() -> Bool
	{
		return false
	}
	
	public override func copy(offset: SCNVector3 = SCNVector3Zero) -> Turnout
	{
		let copy = Turnout(at: startPos + offset, angle: startAngle)
		
		for segment in segments
		{
			let seg = segment.copy(offset: offset)
			copy.add(segment: seg)
		}
		
		copy.setInbound(joint: super.inbound())
		copy.setOutbound(state: 0, joint: super.outbound())
		
		copy.state = state
		copy.outboundJointAlt = outboundJointAlt
		
		return copy
	}
	
	public override init(at: SCNVector3, angle: Float)
	{
		super.init(at: at, angle: angle)
		
		// start at the cursor, main line extends along the cursorAngle some length
		let main = Segment(from: at,
		                   to: SCNVector3Make(at.x + LENGTH * cos(angle), at.y, at.z + LENGTH * sin(angle)))
		
		// start at the cursor, alt line extends along the cursorAngle + (or - for left hand turnout) the turnout number
		let alt = Segment(from: at,
		                  to: SCNVector3Make(at.x + LENGTH * cos(angle + ANGLE), at.y, at.z + LENGTH * sin(angle + ANGLE)))
		
		super.add(segment: main)
		super.add(segment: alt)
	}
	
	public override func next(segmentIndex: Int) -> Int?
	{
		// one segment only
		return nil
	}
	
	// get the outbound direction joint given the dynamic state for our line
	public override func outbound(state: [Int:Int])  -> Joint?
	{
		// if no dymanic state, we are on the main (0) segment
		let s = state[id] ?? 0
		
		// 0 uses Line.outboundJoint, 1 uses our other outboundJoint
		if s == 0
		{
			return super.outbound(state: state)
		}
		
		return outboundJointAlt
	}
	
	// set the line's outbound direction joint used when we are in this line state
	public override func setOutbound(state: Int, joint: Joint?)
	{
		// 0 uses Line.outboundJoint, 1 uses our other outboundJoint
		if state == 0
		{
			super.setOutbound(joint: joint)
		}
		else
		{
			outboundJointAlt = joint
		}
	}
	
	// which segment (index) to enter when coming into the line from a joint
	// TODO: deal with inbound / outbound?  Currently doing outbound
	public override func enter(from: Int, joint: Joint, state: [Int:Int]) -> Int
	{
		// enter into the segment based on dynamic state, ignoring the joint state and from id
		// if no dynamic state, use the main (0) segment
		let s = state[id] ?? 0
		
		return s;
	}
	
	// get the first segment, given this line state
	public override func first(state: Int) -> Segment?
	{
		return segments[state]
	}
	
	// get the last segment, given this line state
	public override func last(state: Int) -> Segment?
	{
		// pick the state's segment
		return segments[state]
	}
	
	// what is the linear length of this line?
	public override func length(state: Int) -> Float
	{
		return segments[state].length
	}
	
	// recreate joints to point to lines with these mapped ids
	public override func mapJoints(idMap: [Int:Int])
	{
		super.mapJoints(idMap: idMap)
		
		if let j = outboundJointAlt
		{
			outboundJointAlt = j.mapId(idMap: idMap)
		}
	}
}
