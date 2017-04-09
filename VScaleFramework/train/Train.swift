//
//  Train.swift
//  VScaleFramework
//
//  Copyright © 2017 Glenn R. Golden. All rights reserved.
//

import Foundation
import SceneKit

// a train of train cars
public class Train
{
	private var cars: [TrainCar] = []
	
	// settable train speed
	public var velocity: Float = 0
	
	// access the first car - usually the engine
	public var first: TrainCar?
	{
		return cars.first
	}
	
	// create
	public init()
	{
	}
	
	// add another train car
	public func add(_ car: TrainCar) -> Train
	{
		cars.append(car)
		
		return self
	}
	
	// position the train on the layout train path so the first car is at distance along the path
	public func place(layout: Layout, distance: Float, outbound: Bool = true)
	{
		// compute the length of the train
		var length: Float = 0
		for car in cars
		{
			length += car.length
		}
		
		// adjust if we need to fit the train on the path
		let adjusted = max(distance, length)
		
		// place each car
		var d = adjusted
		for car in cars
		{
			car.offset = layout.trainOffset
			car.position(path: layout.trackPlan, leadingDistance: d)
			d -= car.length
			
			for n in car.nodes
			{
				layout.node.addChildNode(n)
			}
		}
	}
	
	// move the train a distance along the path
	public func advance(distance d: Float)
	{
		var distance = d
		
		if let lead = cars.first
		{
			// for paths that are not continuous (have a length), don't let the lead car's leading edge run off the path
			if let len = lead.pathLength
			{
				let leadCarLeadingExceedsPath = lead.leading(pivot: lead.pathDistance! + distance) - len
				if leadCarLeadingExceedsPath > 0
				{
					distance -= leadCarLeadingExceedsPath
				}
			}
		}
		
		for car in cars
		{
			// if we reach the path end and can't move a car full distance, reduce the subsequent moves, too
			distance = car.advance(distance: distance)
		}
	}
	
	// move the train one time unit, based on velocity
	public func advance(time: Float)
	{
		let distance = time * velocity
		advance(distance: distance)
	}
	
	// set the state of a given turnout for this train
	public func setTurnout(turnout: Line, state: Int)
	{
		for car in cars
		{
			car.setTurnout(turnout: turnout, state: state)
		}
	}
}
