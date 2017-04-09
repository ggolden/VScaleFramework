//
//  Picture.swift
//  VScaleFramework
//
//  Copyright © 2017 Glenn R. Golden. All rights reserved.
//

import Foundation
import SceneKit

// A picture to hang on the wall of the room, with an image and frame
public class Picture
{
	// the node containing the picture
	public let node : SCNNode
	
	// create with the named image (found in the bundle), mapping the image to imageWidth: in room scale,
	// located at location: in the node (and added to the node) inNode:
	public init(imageName: String, inBundle: Bundle,
	            imageWidth: Float,
	            location: SCNVector3, inNode: SCNNode)
	{
		let f: Float = 2
		
		node = SCNNode()
		
		if let image = UIImage(named: imageName,
		                       in : inBundle,
		                       compatibleWith: nil)
		{
			let width = imageWidth
			let height = imageWidth * Float(image.size.height / image.size.width)
			
			let top = SCNNode(geometry: SCNBox(width: CGFloat(width + (2 * f)), height: CGFloat(f), length: CGFloat(f), chamferRadius: 0))
			let bottom = SCNNode(geometry: SCNBox(width: CGFloat(width + (2 * f)), height: CGFloat(f), length: CGFloat(f), chamferRadius: 0))
			let left = SCNNode(geometry: SCNBox(width: CGFloat(f), height: CGFloat(height), length: CGFloat(f), chamferRadius: 0))
			let right = SCNNode(geometry: SCNBox(width: CGFloat(f), height: CGFloat(height), length: CGFloat(f), chamferRadius: 0))
			let picture = SCNNode(geometry: SCNPlane(width: CGFloat(width), height: CGFloat(height)))
			
			let frameMaterial = SCNMaterial()
			frameMaterial.diffuse.contents = UIColor.black
			top.geometry?.firstMaterial = frameMaterial
			left.geometry?.firstMaterial = frameMaterial
			bottom.geometry?.firstMaterial = frameMaterial
			right.geometry?.firstMaterial = frameMaterial
			
			picture.geometry?.firstMaterial = SCNMaterial(imageName: imageName, inBundle: inBundle, imageWidth: imageWidth, width: width, height: height)
			
			top.position = SCNVector3(x: 0, y: (height + f) / 2, z: f / 2)
			bottom.position = SCNVector3(x: 0, y: -(height + f) / 2, z: f / 2)
			left.position = SCNVector3(x: -(width + f) / 2, y: 0, z: f / 2)
			right.position = SCNVector3(x: (width + f) / 2, y: 0, z: f / 2)
			picture.position = SCNVector3(x: 0, y: 0, z: f / 2)
			
			node.addChildNode(picture)
			node.addChildNode(top)
			node.addChildNode(left)
			node.addChildNode(bottom)
			node.addChildNode(right)
		}
		
		node.position = location
		inNode.addChildNode(node)
	}
}
