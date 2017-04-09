//
//  Track.swift
//  VScaleFramework
//
//  Copyright © 2017 Glenn R. Golden. All rights reserved.
//

import Foundation
import SceneKit

// model a trackbed with a stone-ish texture
public class TrackBed
{
	private let TIE_LENGTH : Float = 2.9745 // based on 102" prototype, HO 1:87.1 scale, scenekit unit = 1cm
	
	public let node : SCNNode
	public private(set) var height : Float = 0
	
	public init(length : Float)
	{
		node = SCNNode()
		
		let bedHeight = constructBed(length: length)
		height = bedHeight
	}
	
	private func constructBed(length : Float) -> Float
	{
		let height = TIE_LENGTH / 4
		let camfer = 2 * height
		// the top holds our tie length (plus?)
		// the camfer is 2:1
		let width = TIE_LENGTH + (2 * camfer)
		
		let bedPath = crossSectionBed(width: width, height: height, camfer: camfer)
		let bedGeometry = SCNShape(path: bedPath, extrusionDepth: CGFloat(length))
		// bedGeometry.firstMaterial?.diffuse.contents = UIColor.yellow
		bedGeometry.materials = materialsBed(width: width, length: length)
		
		let bedNode = SCNNode(geometry: bedGeometry)
		bedNode.rotation = SCNVector4(x: 0, y: 1, z: 0, w: Float.pi/2)
		bedNode.position = SCNVector3(x: length / 2, y: self.height, z: 0)
		node.addChildNode(bedNode)
		
		return height
	}
	
	// cross section in the xy plane, sits at y=0 (with y height), centered around x=0 (with x width)
	private func crossSectionBed(width w : Float, height h : Float, camfer c : Float) -> UIBezierPath
	{
		let path = UIBezierPath();
		
		path.move(to: CGPoint(x: CGFloat(-1 * (w / 2)), y: 0)) // lower left
		path.addLine(to: CGPoint(x: CGFloat(-(w / 2) + c), y: CGFloat(h))) // upper left
		path.addLine(to: CGPoint(x: CGFloat((w / 2) - c), y: CGFloat(h))) // upper right
		path.addLine(to: CGPoint(x: CGFloat(w / 2), y: CGFloat(0))) // lower right
		path.close()
		
		return path
	}
	
	private func materialsBed(width: Float, length: Float) -> [ SCNMaterial ]
	{
		// materials[ "top" (right side) cross-section, "bottom" (left side) cross-section, extrusion]
		let mEnds = SCNMaterial()
		mEnds.diffuse.contents = UIColor.darkGray
		let m3 = SCNMaterial()
		
		let mode = SCNWrapMode.repeat
		
		// tile the texture without distortion
		// http://naldzgraphics.net/freebies/gravel-textures - http://royaltyfreestock.deviantart.com/art/Gravel-39502548: "gravel_by_royaltyfreestock.jpg"
		// http://naldzgraphics.net/freebies/gravel-textures - http://chaotic-oasis-stock.deviantart.com/art/STOCK-Gravel-Texture-003-268242360: "stock___gravel_texture_003_by_gothicairshy-d4fpd4o.jpg"
		// http://naldzgraphics.net/freebies/gravel-textures - http://moltenlead.deviantart.com/art/Gravel-11451272: "gravel_by_moltenlead.jpg"
		// http://www.photos-public-domain.com/tag/gravel: "gray-gravel-rock-texture.jpg" "red-and-black-rocks-gravel-texture.jpg"
		if let texture = UIImage(named: "gray-gravel-rock-texture.jpg",
		                         in : Bundle(for: type(of: self)),
		                         compatibleWith: nil)
		{
			// it will be applied across the width (i.e. the top edge of the texture will align with the left side of the roadbed)
			// we want the width of the texture to cover the width, so use a 1 multiplier for x
			// we want the height of the texture to be tiled over the length
			let textureScaleY : Float = (Float(texture.size.width) / Float(texture.size.height)) * (length / width)
			
			m3.diffuse.contents = texture
			m3.diffuse.wrapS = mode
			m3.diffuse.wrapT = mode
			m3.diffuse.contentsTransform = SCNMatrix4MakeScale(1, textureScaleY, 1)
			
			m3.normal.contents = texture
			m3.normal.wrapS = mode
			m3.normal.wrapT = mode
			m3.normal.contentsTransform = SCNMatrix4MakeScale(1, textureScaleY, 1)
		}
		else
		{
			m3.diffuse.contents = UIColor.yellow
		}
		
		return [mEnds, mEnds, m3]
	}
}
