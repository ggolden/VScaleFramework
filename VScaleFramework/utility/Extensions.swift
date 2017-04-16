//
//  Extensions.swift
//  VScaleFramework
//
//  Copyright © 2017 Glenn R. Golden. All rights reserved.
//

import Foundation
import SceneKit

extension CGFloat
{
	// display to 2 decimals
	public func d2() -> String
	{
		return String(format: "%.2f", self)
	}
}

extension Double
{
	// display to 2 decimals
	public func d2() -> String
	{
		return String(format: "%.2f", Float(self))
	}
}

infix operator ==~ : AdditionPrecedence
infix operator ==~~~~ : AdditionPrecedence
infix operator =~= : AdditionPrecedence

extension Float
{
	// approximately equal - to deal with real number rounding
	static public func ==~ (left: Float, right: Float) -> Bool
	{
		return fabs(left.distance(to: right)) <= 1e-7
	}
	
	// approximately equal (with a wider margin than ==~) - to deal with real number rounding
	static public func ==~~~~ (left: Float, right: Float) -> Bool
	{
		return fabs(left.distance(to: right)) <= 1e-4
	}
	
	// display to 2 decimals
	public func d2() -> String
	{
		return String(format: "%.2f", self)
	}
	
	// display as a # of PIs - TODOL change to a normal character, since this one is not easy to actually type!
	public var πs: Float
	{
		return self / Float.pi
	}
	
	// wrap a radians value to its positive equivalence
	public var positiveRadians: Float
	{
		if (self < 0)
		{
			return self + (2 * Float.pi)
		}
		// TODO: other wrapping
		
		return self
	}
	
	// expressed in ft (returned in cm)
	public var feet: Float
	{
		return self * 30.48
	}
	
	// expressed in inches (returned in cm)
	public var inches: Float
	{
		return self * 2.54
	}
}

extension SCNVector3
{
	// the distance between two points
	public func distance(to t: SCNVector3) -> Float
	{
		return sqrt(pow((t.x - self.x), 2) + pow((t.y - self.y), 2) + pow((t.z - self.z), 2));
	}
	
	// compare two vectors
	static public func ==(left: SCNVector3, right: SCNVector3) -> Bool
	{
		return (left.x == right.x) && (left .y == right.y) && (left.z == right.z)
	}
	
	// compare two vectors for inequality
	static public func !=(left: SCNVector3, right: SCNVector3) -> Bool
	{
		return (left.x != right.x) || (left .y != right.y) || (left.z != right.z)
	}
	
	// compare two vectors with some margin for rounding errors
	static public func =~=(left: SCNVector3, right: SCNVector3) -> Bool
	{
		return (abs(left.x - right.x) < 0.01) && (abs(left .y - right.y) < 0.01) && (abs(left.z - right.z) < 0.01)
	}
	
	// add two vectors, component (dot) wise
	static public func +(left: SCNVector3, right: SCNVector3) -> SCNVector3
	{
		return SCNVector3(x: left.x + right.x, y: left.y + right.y, z: left.z + right.z)
	}
	
	// store dimensions in a vector, access the width
	public var width : Float
	{
		return self.x
	}
	
	// store dimensions in a vector, access the height
	public var height : Float
	{
		return self.y
	}
	
	// store dimensions in a vector, access the depth
	public var depth : Float
	{
		return self.z
	}
	
	// find the point normal to the line extended from self by angle:, length: away from the line (flat along y)
	public func perperdicular(angle: Float, length: Float) -> SCNVector3
	{
		let a = angle + (Float.pi/2)
		let x: Float = self.x + length * cos(a)
		let z: Float = self.z + length * sin(a)
		return SCNVector3Make(x, self.y, z)
	}
}

extension SCNVector4
{
	// compare two vectors
	static public func ==(left: SCNVector4, right: SCNVector4) -> Bool
	{
		return (left.x == right.x) && (left .y == right.y) && (left.z == right.z) && (left.w == right.w)
	}
	
	// compare two vectors for inequality
	static public func !=(left: SCNVector4, right: SCNVector4) -> Bool
	{
		return (left.x != right.x) || (left .y != right.y) || (left.z != right.z) || (left.w != right.w)
	}
	
	// compare two vectors with some margin to account for rounding errors
	static public func =~=(left: SCNVector4, right: SCNVector4) -> Bool
	{
		return (abs(left.x - right.x) < 0.01) && (abs(left .y - right.y) < 0.01) && (abs(left.z - right.z) < 0.01) && (abs(left.w - right.w) < 0.01)
	}
}

extension SCNScene
{
	// Bundle(for: type(of: self))
	// Bundle(for: Path.self)

	// load a .dae model with this name (no extension) from the framework's bundle, returning the first child node
	static public func nodeFromDAE(from: String) -> SCNNode?
	{
		// use a class in the framework for the bundle
		if let p = Bundle(for: Path.self).path(forResource: from, ofType: "dae"),
			let scn = try? SCNScene(url: URL(fileURLWithPath: p)),
			let n = scn.rootNode.childNodes.first
		{
			return n
		}
		
		return nil
	}
}

extension SCNMaterial
{
	// Create a material from an image, applied to the diffuse property.
	// Tile to fill width and height given the image width coverage and preserving image aspect ratio.
	// May be rotated 90 degrees (counterclockwise), and may be flipped 180 degrees.
	// Image coverage can be give in width or height.  If neither, use pixel image size.
	convenience init?(imageName: String, inBundle: Bundle,
	                  imageWidth: Float? = nil, imageHeight: Float? = nil,
	                  width: Float, height: Float,
	                  rotated: Bool = false, flipped: Bool = false)
	{
		self.init()
		
		if let texture = UIImage(named: imageName,
		                         in : inBundle,
		                         compatibleWith: nil)
		{
			var iw = imageWidth ?? 0
			var ih = imageHeight ?? 0
			if (iw == 0) && (ih == 0)
			{
				iw = Float(texture.size.width)
				ih = Float(texture.size.height)
			}
			else if iw == 0
			{
				iw = Float(texture.size.width / texture.size.height) * ih
			}
			else if ih == 0
			{
				ih = Float(texture.size.height / texture.size.width) * iw
			}
			
			self.diffuse.contents = texture
			self.diffuse.wrapS = .repeat
			self.diffuse.wrapT = .repeat
			
			if (!rotated)
			{
				let fx = width / iw
				let fy = fx * Float(texture.size.width / texture.size.height) * (height / width)
				self.diffuse.contentsTransform = SCNMatrix4MakeScale(fx, fy, 1)
				
				if (flipped)
				{
					self.diffuse.contentsTransform = SCNMatrix4Rotate(self.diffuse.contentsTransform, Float.pi, 0, 0, 1)
				}
			}
			else
			{
				let fx = width / ih
				let fy = fx * Float(texture.size.height / texture.size.width) * (height / width)
				
				let angle = flipped ? -Float.pi/2 : Float.pi/2
				self.diffuse.contentsTransform = SCNMatrix4Rotate(SCNMatrix4MakeScale(fx, fy, 1), angle, 0, 0, 1)
			}
		}
		else
		{
			self.diffuse.contents = UIColor.white
		}
	}
}
