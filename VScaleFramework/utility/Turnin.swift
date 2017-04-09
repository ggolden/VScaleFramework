//
//  Turnin.swift
//  VScaleFramework
//
//  Copyright © 2017 Glenn R. Golden. All rights reserved.
//

import Foundation
import SceneKit

// a subclass of line, representing a reveresed railroad turnout, with two inbound joints, and one outbound
public class Turnin: Line
{
	private let LENGTH: Float = 10
	private let ANGLE = Float.pi/6
	
	private var inboundJointAlt: Joint? = nil
	
	// which way is the turnout set
	public private(set) var state: Int = 0
	
	// CustomStringConvertible
	public override var description: String
	{
		let srv = super.description
		return "Turnin \(srv) in(alt) \(String(describing: inboundJointAlt))"
	}
	
	// turnouts may not be extended with new segments
	public override func extendable() -> Bool
	{
		return false
	}
	
	public override func copy(offset: SCNVector3 = SCNVector3Zero) -> Turnin
	{
		let copy = Turnin(at: startPos + offset, angle: startAngle)
		
		for segment in segments
		{
			let seg = segment.copy(offset: offset)
			copy.add(segment: seg)
		}
		
		copy.setInbound(state: 0, joint: super.inbound())
		copy.setOutbound(joint: super.outbound())
		
		copy.state = state
		copy.inboundJointAlt = inboundJointAlt
		
		return copy
	}
	
	public convenience init(at: SCNVector3, angle: Float, toMain: Bool = true)
	{
		self.init(at: at, angle: angle)
		
		if (toMain)
		{
			// start at the cursor, main line extends along the cursorAngle some length
			let main = Segment(from: at,
			                   to: SCNVector3Make(at.x + LENGTH * cos(angle), at.y, at.z + LENGTH * sin(angle)))
			
			// end at the mainSegment end, start an angle away and back
			// start at the cursor, alt line extends along the cursorAngle + (or - for left hand turnout) the turnout number
			let alt = Segment(from: SCNVector3Make(main.end.x - LENGTH * cos(angle + ANGLE),  main.end.y,  main.end.z - LENGTH * sin(angle + ANGLE)),
			                  to: main.end)
			
			super.add(segment: main)
			super.add(segment: alt)
		}
		else
		{
			// start at the cursor, alt line extends along the cursorAngle some length
			let alt = Segment(from: at,
			                  to: SCNVector3Make(at.x + LENGTH * cos(angle), at.y, at.z + LENGTH * sin(angle)))
			
			// end at the alt end, start an angle away and back
			// start at the cursor, alt line extends along the cursorAngle + (or - for left hand turnout) the turnout number
			let main = Segment(from: SCNVector3Make(alt.end.x - LENGTH * cos(angle + ANGLE),  alt.end.y,  alt.end.z - LENGTH * sin(angle + ANGLE)),
			                   to: alt.end)
			
			super.add(segment: main)
			super.add(segment: alt)
		}
	}
	
	public override func next(segmentIndex: Int) -> Int?
	{
		// one segment only
		return nil
	}
	
	// get the inbound direction joint given the dynamic state for our line
	public override func inbound(state: [Int:Int])  -> Joint?
	{
		// if no dymanic state, we are on the main (0) segment
		let s = state[id] ?? 0
		
		// 0 uses Line.inboundJoint, 1 uses our other outboundJoint
		if s == 0
		{
			return super.inbound(state: state)
		}
		
		return inboundJointAlt
	}
	
	// set the line's inbound direction joint used when we are in this line state
	public override func setInbound(state: Int, joint: Joint?)
	{
		// 0 uses Line.inboundJoint, 1 uses our other outboundJoint
		if state == 0
		{
			super.setInbound(joint: joint)
		}
		else
		{
			inboundJointAlt = joint
		}
	}
	
	// which segment (index) to enter when coming into the line from a joint
	// TODO: deal with inbound / outbound?  Currently doing outbound
	public override func enter(from: Int, joint: Joint, state: [Int:Int]) -> Int
	{
		// enter into the segment joined to the joint we entered from
		if (from == super.inbound()!.line)
		{
			return 0;
		}
		return 1
	}
	
	// get the first segment, given this line state
	public override func first(state: Int) -> Segment?
	{
		return segments[state]
	}
	
	// get the last segment, given this line state
	public override func last(state: Int) -> Segment?
	{
		// both alternatives end at the same place, so use main (0) and ignore state
		return segments[0]
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
		
		if let j = inboundJointAlt
		{
			inboundJointAlt = j.mapId(idMap: idMap)
		}
	}
}
