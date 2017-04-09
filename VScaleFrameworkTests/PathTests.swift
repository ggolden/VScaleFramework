//
//  PathTests.swift
//  VScaleFramework
//
//  Copyright © 2017 Glenn R. Golden. All rights reserved.
//

import XCTest
import SceneKit
import Foundation

@testable import VScaleFramework

class PathTests: XCTestCase {
	
	let pathStart = SCNVector3(x: 0, y: 0, z: 0)
	let pathEnd = SCNVector3(x: 100, y: 0, z: 0)
	var path : Path!
	var revPath : Path!
	
	let pathZStart = SCNVector3(x: 0, y: 0, z: 0)
	let pathZEnd = SCNVector3(x: 0, y: 0, z: 100)
	var pathZ : Path!
	var revPathZ : Path!
	
	let pathDStart = SCNVector3(x: 0, y: 0, z: 0)
	let pathDEnd = SCNVector3(x: 100, y: 0, z: 100)
	var pathD : Path!
	var revPathD : Path!
	
	let pathD2Start = SCNVector3(x: -50, y:0, z: -20)
	let pathD2End = SCNVector3(x: 50, y: 0, z: -120)
	var pathD2 : Path!
	var revPathD2 : Path!
	
	override func setUp() {
		super.setUp()
		
		path = Path()
		_ = path.line(at: pathStart, angle:0).extend(to: pathEnd)
		revPath = Path()
		_ = revPath.line(at: pathEnd, angle: 0).extend(to:pathStart)
		
		
		pathZ = Path()
		_ = pathZ.line(at: pathZStart, angle: 0).extend(to: pathZEnd)
		revPathZ = Path()
		_ = revPathZ.line(at: pathZEnd, angle: 0).extend(to: pathZStart)
		
		pathD = Path()
		_ = pathD.line(at: pathDStart, angle: 0).extend(to: pathDEnd)
		revPathD = Path()
		_ = revPathD.line(at: pathDEnd, angle: 0).extend(to: pathDStart)
		
		pathD2 = Path()
		_ = pathD2.line(at: pathD2Start, angle: 0).extend(to: pathD2End)
		revPathD2 = Path()
		_ = revPathD2.line(at: pathD2End, angle: 0).extend(to: pathD2Start)
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		path = nil
		revPath = nil
		pathZ = nil
		revPathZ = nil
		pathD = nil
		revPathD = nil
		pathD2 = nil
		revPathD2 = nil
		
		super.tearDown()
	}
	
	func testUnitMove()
	{
		let placement = Path.Placement(path: path, distance: 0)
		XCTAssertTrue(placement.position.x == pathStart.x, "\(placement.position)")
		XCTAssertTrue(placement.position.y == pathStart.y, "\(placement.position)")
		XCTAssertTrue(placement.position.z == pathStart.z, "\(placement.position)")
		
		let advanced = placement.advance(distance: 1)
		XCTAssertTrue(advanced == 1, "\(advanced)")
		
		XCTAssertTrue(placement.position.x == pathStart.x + 1, "\(placement.position)")
		XCTAssertTrue(placement.position.y == pathStart.y, "\(placement.position)")
		XCTAssertTrue(placement.position.z == pathStart.z, "\(placement.position)")
	}
	
	func testNonUnitMove()
	{
		let placement = Path.Placement(path: path, distance: 0)
		XCTAssertTrue(placement.position.x == pathStart.x, "\(placement.position)")
		XCTAssertTrue(placement.position.y == pathStart.y, "\(placement.position) ")
		XCTAssertTrue(placement.position.z == pathStart.z, "\(placement.position)")
		
		let advanced = placement.advance(distance: 1.5)
		XCTAssertTrue(advanced == 1.5, "\(advanced)")
		
		XCTAssertTrue(placement.position.x == pathStart.x + 1.5, "\(placement.position)")
		XCTAssertTrue(placement.position.y == pathStart.y, "\(placement.position)")
		XCTAssertTrue(placement.position.z == pathStart.z, "\(placement.position)")
	}
	
	func testRevUnitMove()
	{
		let placement = Path.Placement(path: revPath, distance: 0)
		XCTAssertTrue(placement.position.x == pathEnd.x, "\(placement.position)")
		XCTAssertTrue(placement.position.y == pathEnd.y, "\(placement.position)")
		XCTAssertTrue(placement.position.z == pathEnd.z, "\(placement.position)")
		
		let advanced = placement.advance(distance: 1)
		XCTAssertTrue(advanced == 1, "\(advanced)")
		
		XCTAssertTrue(placement.position.x == pathEnd.x - 1, "\(placement.position)")
		XCTAssertTrue(placement.position.y == pathEnd.y, "\(placement.position)")
		XCTAssertTrue(placement.position.z == pathEnd.z, "\(placement.position)")
	}
	
	func testUnitMoveZ()
	{
		let placement = Path.Placement(path: pathZ, distance: 0)
		XCTAssertTrue(placement.position.x == pathZStart.x, "\(placement.position)")
		XCTAssertTrue(placement.position.y == pathZStart.y, "\(placement.position)")
		XCTAssertTrue(placement.position.z == pathZStart.z, "\(placement.position)")
		
		let advanced = placement.advance(distance: 1)
		XCTAssertTrue(advanced == 1, "\(advanced)")
		
		XCTAssertTrue(placement.position.x == pathZStart.x, "\(placement.position)")
		XCTAssertTrue(placement.position.y == pathZStart.y, "\(placement.position)")
		XCTAssertTrue(placement.position.z == pathZStart.z + 1, "\(placement.position)")
	}
	
	func testRevUnitMoveZ()
	{
		let placement = Path.Placement(path: revPathZ, distance: 0)
		XCTAssertTrue(placement.position.x == pathZEnd.x, "\(placement.position)")
		XCTAssertTrue(placement.position.y == pathZEnd.y, "\(placement.position)")
		XCTAssertTrue(placement.position.z == pathZEnd.z, "\(placement.position)")
		
		let advanced = placement.advance(distance: 1)
		XCTAssertTrue(advanced == 1, "\(advanced)")
		
		XCTAssertTrue(placement.position.x == pathZEnd.x, "\(placement.position)")
		XCTAssertTrue(placement.position.y == pathZEnd.y, "\(placement.position)")
		XCTAssertTrue(placement.position.z == pathZEnd.z - 1, "\(placement.position)")
	}
	
	func testUnitMoveD()
	{
		let placement = Path.Placement(path: pathD, distance: 0)
		XCTAssertTrue(placement.position.x == pathDStart.x, "\(placement.position)")
		XCTAssertTrue(placement.position.y == pathDStart.y, "\(placement.position)")
		XCTAssertTrue(placement.position.z == pathDStart.z, "\(placement.position)")
		
		let advanced = placement.advance(distance: 1)
		XCTAssertTrue(advanced == 1, "\(advanced)")
		
		XCTAssertTrue(placement.position.x ==~ (pathDStart.x + sqrt(0.5)), "\(placement.position)")
		XCTAssertTrue(placement.position.y == pathDStart.y, "\(placement.position)")
		XCTAssertTrue(placement.position.z ==~ (pathDStart.z + sqrt(0.5)), "\(placement.position)")
	}
	
	func testRevUnitMoveD()
	{
		let placement = Path.Placement(path: revPathD, distance: 0)
		XCTAssertTrue(placement.position.x == pathDEnd.x, "\(placement.position)")
		XCTAssertTrue(placement.position.y == pathDEnd.y, "\(placement.position)")
		XCTAssertTrue(placement.position.z == pathDEnd.z, "\(placement.position)")
		
		let advanced = placement.advance(distance: 1)
		XCTAssertTrue(advanced == 1, "\(advanced)")
		
		XCTAssertTrue(placement.position.x ==~ (pathDEnd.x - sqrt(0.5)), "\(placement.position)")
		XCTAssertTrue(placement.position.y == pathDEnd.y, "\(placement.position)")
		XCTAssertTrue(placement.position.z ==~ (pathDEnd.z - sqrt(0.5)), "\(placement.position)")
	}
	
	func testUnitMoveD2()
	{
		let placement = Path.Placement(path: pathD2, distance: 0)
		XCTAssertTrue(placement.position.x == pathD2Start.x, "\(placement.position)")
		XCTAssertTrue(placement.position.y == pathD2Start.y, "\(placement.position)")
		XCTAssertTrue(placement.position.z == pathD2Start.z, "\(placement.position)")
		
		let advanced = placement.advance(distance: 1)
		XCTAssertTrue(advanced == 1, "\(advanced)")
		
		XCTAssertTrue(placement.position.x ==~ (pathD2Start.x + sqrt(0.5)), "\(placement.position)")
		XCTAssertTrue(placement.position.y == pathD2Start.y, "\(placement.position)")
		XCTAssertTrue(placement.position.z ==~ (pathD2Start.z - sqrt(0.5)), "\(placement.position)")
	}
	
	func testRevUnitMoveD2()
	{
		let placement = Path.Placement(path: revPathD2, distance: 0)
		XCTAssertTrue(placement.position.x == pathD2End.x, "\(placement.position)")
		XCTAssertTrue(placement.position.y == pathD2End.y, "\(placement.position)")
		XCTAssertTrue(placement.position.z == pathD2End.z, "\(placement.position)")
		
		let advanced = placement.advance(distance: 1)
		XCTAssertTrue(advanced == 1, "\(advanced)")
		
		XCTAssertTrue(placement.position.x ==~ (pathD2End.x - sqrt(0.5)), "\(placement.position)")
		XCTAssertTrue(placement.position.y == pathD2End.y, "\(placement.position)")
		XCTAssertTrue(placement.position.z ==~ (pathD2End.z + sqrt(0.5)), "\(placement.position)")
	}
	
	func testPathOffset()
	{
		let offset = SCNVector3Make(0, 5, 0)
		let p = path.path(offset: offset)
		let p1 = Path.Placement(path: path, distance: 0)
		let p2 = Path.Placement(path: p, distance: 0)
		XCTAssertTrue(p1.position + offset == p2.position, "\(p1.position) \(p2.position)")
		
		var moved: Float = 0
		repeat
		{
			moved = p1.advance(distance: 1)
			let moved2 = p2.advance(distance: 1)
			XCTAssertTrue(moved == moved2, "\(moved2)")
			XCTAssertTrue(p1.position + offset == p2.position, "\(p1.position) \(p2.position)")
		} while moved == 1
	}
	
	func testPathPlacementAdvance()
	{
		var p1 = Path.Placement(path: path, distance: 0)
		var p2 = Path.Placement(path: path, distance: 1)
		XCTAssertTrue(p1.position != p2.position, "\(p1.position) \(p2.position)")
		
		var advanced = p1.advance(distance: 1)
		XCTAssertTrue(advanced == 1, "\(advanced)")
		XCTAssertTrue(p1.position == p2.position, "\(p1.position) \(p2.position)")
		
		p1 = Path.Placement(path: path, distance: 0)
		p2 = Path.Placement(path: path, distance: 50)
		XCTAssertTrue(p1.position != p2.position, "\(p1.position) \(p2.position)")
		
		advanced = p1.advance(distance: 50)
		XCTAssertTrue(advanced == 50, "\(advanced)")
		XCTAssertTrue(p1.position == p2.position, "\(p1.position) \(p2.position)")
		
		advanced = p1.advance(distance: 1)
		advanced = p2.advance(distance: 1)
		XCTAssertTrue(advanced == 1, "\(advanced)")
		XCTAssertTrue(p1.position == p2.position, "\(p1.position) \(p2.position)")
		
		p1 = Path.Placement(path: path, distance: 0)
		p2 = Path.Placement(path: path, distance: 0.00166)
		XCTAssertTrue(p1.position != p2.position, "\(p1.position) \(p2.position)")
		
		advanced = p1.advance(distance: 0.00166)
		XCTAssertTrue(advanced == 0.00166, "\(advanced)")
		XCTAssertTrue(p1.position == p2.position, "\(p1.position) \(p2.position)")
	}
	
	func testAngle()
	{
		var angle = path.lines.first!.segments.first!.angle
		XCTAssertTrue(angle == 0, "\(angle)")
		
		angle = revPath.lines.first!.segments.first!.angle
		XCTAssertTrue(angle ==~~~~ Float.pi, "\(angle.πs)")
		
		angle = pathZ.lines.first!.segments.first!.angle
		XCTAssertTrue(angle ==~~~~ Float.pi/2, "\(angle.πs)")
		
		angle = revPathZ.lines.first!.segments.first!.angle
		XCTAssertTrue(angle ==~~~~ -Float.pi/2, "\(angle.πs)")
		
		angle = pathD.lines.first!.segments.first!.angle
		XCTAssertTrue(angle ==~~~~ Float.pi/4, "\(angle)")
		
		angle = revPathD.lines.first!.segments.first!.angle
		XCTAssertTrue(angle ==~~~~ -Float.pi * 3/4, "\(angle.πs)")
	}
	
	func testMultiSegmentLine()
	{
		_ = path.lastLine!
			.extend(by: SCNVector3Make(100, 0, 0))
			.extend(by: SCNVector3Make(100, 0, 0))
		let p = Path.Placement(path: path, distance: 0)
		let max = 300
		for i in 1 ... max
		{
			let advanced = p.advance(distance: 1)
			XCTAssertTrue(advanced == 1, "\(i) \(advanced)")
			XCTAssertTrue(p.position =~= (pathStart + SCNVector3Make(Float(i), 0, 0)), "\(i) \(p.position)")
		}
		let  advanced = p.advance(distance: 1)
		XCTAssertTrue(advanced == (max >= 300 ? 0 : 1), "\(advanced)")
		XCTAssertTrue(p.position =~= (pathStart + SCNVector3Make(Float(min(300, max+1)), 0, 0)), "\(p.position)")
	}
	
	func testTwoLinePath()
	{
		let path = Path()
		let l1 = path.line(at: SCNVector3Make(0, 0, 0), angle: 0).extend(to: SCNVector3Make(100, 0, 0))
		let l2 = path.line(inbound: Joint(line: l1, state: 0)).extend(by:  SCNVector3Make(100, 0, 0))
		_ = path.line(inbound: Joint(line: l2, state: 0)).extend(by: SCNVector3Make(100, 0, 0))
		
		let length: Float = 300
		
		let p = Path.Placement(path: path, distance: 0)
		let max = length
		for i in 1 ... Int(max)
		{
			let advanced = p.advance(distance: 1)
			XCTAssertTrue(advanced == 1, "\(i) \(advanced)")
			XCTAssertTrue(p.position =~= (pathStart + SCNVector3Make(Float(i), 0, 0)), "\(i) \(p.position)")
		}
		let  advanced = p.advance(distance: 1)
		XCTAssertTrue(advanced == (max >= length ? 0 : 1), "\(advanced)")
		XCTAssertTrue(p.position =~= (pathStart + SCNVector3Make(Float(min(length, max+1)), 0, 0)), "\(p.position)")
	}
	
	func testPlacementPathLengthTurnout()
	{
		let path = Path()
		
		let l1 = path.line(at: SCNVector3Make(0, 0, 0), angle: 0)
			.extend(to: SCNVector3Make(10, 0, 0))
		
		let t1 = path.turnout(inbound: Joint(line: l1, state: 0)) // len 10
		
		let l2 = path.line(inbound: Joint(line: t1, state: 0))
			.extend(by: SCNVector3Make(10, 0, 0))
		
		let t2 = path.turnout(inbound: Joint(line: l2, state: 0)) // len 10
		
		_ = path.line(inbound: Joint(line: t2, state: 0))
			.extend(by: SCNVector3Make(10, 0, 0))
		
		let p = Path.Placement(path: path, distance: 0)
		
		let advanced = p.advance(distance: 1000)
		XCTAssertTrue(advanced == 50, "\(advanced)")
		
		XCTAssertTrue(p.length == 50, "\(p.length ?? -1)")
		XCTAssertTrue(p.continuous == false, "\(p.continuous)")
	}
	
	func testPlacementPathLengthTurnin()
	{
		let path = Path()
		
		let l1 = path.line(at: SCNVector3Make(0, 0, 0), angle: 0)
			.extend(to: SCNVector3Make(10, 0, 0))
		
		// _ = path.turnout(inbound: Joint(line: l1, state: 0)) // len 10
		_ = path.turnin(state: 0, inbound: Joint(line: l1, state: 0)) // len 10
		
		let p = Path.Placement(path: path, distance: 0)
		
		let advanced = p.advance(distance: 1000)
		XCTAssertTrue(advanced == 20, "\(advanced)")
		
		XCTAssertTrue(p.length == 20, "\(p.length ?? -1)")
		XCTAssertTrue(p.continuous == false, "\(p.continuous)")
	}
	
	func testPlacementPathLengthTurnin2()
	{
		let path = Path()
		
		let l1 = path.line(at: SCNVector3Make(0, 0, 0), angle: 0)
			.extend(to: SCNVector3Make(10, 0, 0))
		
		let t1 = path.turnout(inbound: Joint(line: l1, state: 0)) // len 10
		
		let l2 = path.line(inbound: Joint(line: t1, state: 0))
			.extend(by: SCNVector3Make(10, 0, 0))
		
		//		let t2 = path.turnout(inbound: Joint(line: l2, state: 0)) // len 10
		let t2 = path.turnin(state: 0, inbound: Joint(line: l2, state: 0)) // len 10
		
		_ = path.line(inbound: Joint(line: t2, state: 0))
			.extend(by: SCNVector3Make(10, 0, 0))
		
		let p = Path.Placement(path: path, distance: 0)
		
		let advanced = p.advance(distance: 1000)
		XCTAssertTrue(advanced == 50, "\(advanced)")
		
		XCTAssertTrue(p.length == 50, "\(p.length ?? -1)")
		XCTAssertTrue(p.continuous == false, "\(p.continuous)")
	}
	
	func testContinuousPathLength()
	{
		let path = Path()
		let l1 = path.line(at: SCNVector3Make(0, 0, 0), angle: 0)
			.extend(to: SCNVector3Make(10, 0, 0))
		_ = path.line(inbound: Joint(line: l1, state: 0))
			.extend(by: SCNVector3Make(10, 0, 0))
			.close(to: Joint(line: l1, state: 0))
		
		let p = Path.Placement(path: path, distance: 0)
		
		let advanced = p.advance(distance: 1000)
		XCTAssertTrue(advanced == 1000, "\(advanced)")
		
		XCTAssertTrue(p.length == nil, "\(p.length ?? -1)")
		XCTAssertTrue(p.continuous == true, "\(p.continuous)")
	}
	
	func testLineSwitchLinePath()
	{
		let path = Path()
		let l1 = path.line(at: SCNVector3Make(0, 0, 0), angle: 0)
			.extend(to: SCNVector3Make(100, 0, 0))
		
		let t1 = path.turnout(inbound:Joint(line: l1, state: 0)) // len 10
		
		let l2 = path.line(inbound: Joint(line: t1, state: 0))
			.extend(by: SCNVector3Make(100, 0, 0))
		
		let t2 = path.turnin(state: 0, inbound: Joint(line: l2, state: 0)) // len 10
		
		_ = path.line(inbound: Joint(line: t2, state: 0))
			.extend(by: SCNVector3Make(100, 0, 0))
		
		let p = Path.Placement(path: path, distance: 0)
		let length = p.length
		XCTAssertTrue(length == 320, "\(length ?? -1)")
		
		let max = length!
		for i in 1 ... Int(max)
		{
			let advanced = p.advance(distance: 1)
			XCTAssertTrue(advanced == (i > Int(length!) ? 0 : 1), "\(advanced)")
			XCTAssertTrue(p.position =~= (pathStart + SCNVector3Make(Float(min(length!, Float(i))), 0, 0)), "\(p.position)")
		}
		let  advanced = p.advance(distance: 1)
		XCTAssertTrue(advanced == (max >= length! ? 0 : 1), "\(advanced)")
		XCTAssertTrue(p.position =~= (pathStart + SCNVector3Make(Float(min(length!, max+1)), 0, 0)), "\(p.position)")
	}
	
	func testLineSwitchLinePathOffset()
	{
		let path = Path()
		
		let l1 = path.line(at: SCNVector3Make(0, 0, 0), angle: 0) // len 100
			.extend(to: SCNVector3Make(100, 0, 0))
		
		let t1 = path.turnout(inbound: Joint(line: l1, state: 0)) // len 10
		
		let l2 = path.line(inbound: Joint(line: t1, state: 0)) // len 100
			.extend(by: SCNVector3Make(100, 0, 0))
		
		let t2 = path.turnout(inbound: Joint(line: l2, state: 0)) // len 10
		
		_ = path.line(inbound: Joint(line: t2, state: 0)) // len 100
			.extend(by: SCNVector3Make(100, 0, 0))
		
		var p = Path.Placement(path: path, distance: 0)
		XCTAssertTrue(p.length == 320, "\(String(describing: p.length))")
		
		let pOffset = path.path(offset: SCNVector3Make(0, 5, 0))
		
		p = Path.Placement(path: pOffset, distance: 0)
		let length = p.length
		XCTAssertTrue(length == 320, "\(String(describing: length))")
		
		let max = length!
		for i in 1 ... Int(max)
		{
			let advanced = p.advance(distance: 1)
			let predicted = pathStart + SCNVector3Make(Float(min(length!, Float(i))), 5, 0)
			XCTAssertTrue(advanced == (i > Int(length!) ? 0 : 1), "\(advanced)")
			XCTAssertTrue(p.position =~= predicted, "\(predicted) - \(p.position)")
		}
		let  advanced = p.advance(distance: 1)
		XCTAssertTrue(advanced == (max >= length! ? 0 : 1), "\(advanced)")
		XCTAssertTrue(p.position =~= (pathStart + SCNVector3Make(Float(min(length!, max+1)), 5, 0)), "\(p.position)")
	}
	
	func testLineSwitchState()
	{
		let path = Path()
		
		let l1 = path.line(at: SCNVector3Make(0, 0, 0), angle: 0)
			.extend(to: SCNVector3Make(10, 0, 0))
		
		let t1 = path.turnout(inbound: Joint(line: l1, state: 0)) // len 10
		
		_ = path.line(inbound: Joint(line: t1, state: 0))
			.extend(length: 80)
		
		_ = path.line(inbound: Joint(line: t1, state: 1))
			.extend(length: 30)
		
		let p = Path.Placement(path: path, distance: 0)
		XCTAssertTrue(p.length == 100, "\(String(describing: p.length))")
		
		p.state[t1.id] = 1
		XCTAssertTrue(p.length == 50, "\(String(describing: p.length))")
	}
	
	func testLineSwitchState2()
	{
		let path = Path()
		
		let l1 = path.line(at: SCNVector3Make(0, 0, 0), angle: 0)
			.extend(to: SCNVector3Make(10, 0, 0))
		
		let t1 = path.turnin(state: 0, inbound: Joint(line: l1, state: 0)) // len 10
		
		_ = path.line(inbound: Joint(line: t1, state: 0))
			.extend(length: 80)
		
		let p = Path.Placement(path: path, distance: 0)
		XCTAssertTrue(p.length == 100, "\(String(describing: p.length))")
		
		p.state[t1.id] = 1
		XCTAssertTrue(p.length == 100, "\(String(describing: p.length))")
	}
	
	func testAltLengths()
	{
		let path = Path()
		
		let l1 = path.line(at: SCNVector3Make(30, 0, 30), angle: 0)
			.extend(by: SCNVector3Make(100, 0, 0))
		
		let t1 = path.turnout(inbound: Joint(line: l1, state: 0)) // len 10
		
		let l2 = path.line(inbound: Joint(line: t1, state: 0))
			.extend(by: SCNVector3Make(100, 0, 0))
		
		let t2 = path.turnin(state: 0, inbound: Joint(line: l2, state: 0)) // len 10
		/* let l3 */_ = path.line(inbound: Joint(line: t2, state: 0))
			.extend(by: SCNVector3Make(100, 0, 0))
		
		let l4 = path.line(inbound: Joint(line: t1, state: 1))
			// .extend(segmentLength: 0.5, arc: -Float.pi/6, radius: 30)
			.extend(angle: -Float.pi/6, length: 1)
		
		let t3 = path.turnout(inbound: Joint(line: l4, state: 0))
		
		/* let l5 */_ = path.line(inbound: Joint(line: t3, state: 0))
			.extend(length: 100)
		
		/* let l6 */_ = path.line(inbound: Joint(line: t3, state: 1))
			// .extend(segmentLength: 0.5, arc: -Float.pi/6, radius: 30)
			.extend(angle: -Float.pi/6, length: 1)
			.extend(by: SCNVector3Make(100, 0, 0))
		
		let p = Path.Placement(path: path, distance: 0)
		XCTAssertTrue(p.length == 320, "\(String(describing: p.length))")
		XCTAssertTrue(p.continuous == false, "\(p.continuous)")
		
		p.state[t1.id] = 1
		XCTAssertTrue(p.length == 221, "\(String(describing: p.length))")
		XCTAssertTrue(p.continuous == false, "\(p.continuous)")
		
		p.state[t3.id] = 1
		XCTAssertTrue(p.length == 222, "\(String(describing: p.length))")
		XCTAssertTrue(p.continuous == false, "\(p.continuous)")
	}
}
