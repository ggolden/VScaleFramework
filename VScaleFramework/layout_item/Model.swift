//
//  Model.swift
//  VScaleFramework
//
//  Copyright © 2017 Glenn R. Golden. All rights reserved.
//

import Foundation
import SceneKit

// a layout item loaded from a DAE model file
// only the single root node from the model is added - make it contain the entire model
public class Model : LayoutItem
{
	private let modelName: String

	public init(model: String)
	{
		modelName = model;

		super.init()
	}

	override func construct()
	{
		if let p = Bundle(for: Model.self).path(forResource: modelName, ofType: "dae"),
			let scn = try? SCNScene(url: URL(fileURLWithPath: p)),
			let n = scn.rootNode.childNodes.first
		{
			node.addChildNode(n)
		}
	}
}

