//
//  Joint.swift
//  VScaleFramework
//
//  Copyright © 2017 Glenn R. Golden. All rights reserved.
//

import Foundation
import SceneKit

// a Joint joining two lines in a path
public class Joint: CustomStringConvertible, Equatable
{
	// with this line
	public private(set) var line: Int
	
	// in this state of the joined line
	public private(set) var state: Int
	
	// Equatable
	public static func == (lhs: Joint, rhs: Joint) -> Bool
	{
		return lhs.line == rhs.line && lhs.state == rhs.state
	}
	
	// create with the line with this id, its state
	public init(id: Int, state: Int)
	{
		self.line = id
		self.state = state
	}
	
	// create with this line and state
	public convenience init(line: Line, state: Int)
	{
		self.init(id: line.id, state: state)
	}
	
	// CustomStringConvertible
	public var description: String
	{
		return  "Joint: line: \(line) state: \(state)"
	}
	
	// return a Joint to the corresponding line based on the ID map
	public func mapId(idMap: [Int:Int]) -> Joint?
	{
		if let newId = idMap[line]
		{
			return Joint(id: newId, state: state)
		}
		return nil
	}
}
