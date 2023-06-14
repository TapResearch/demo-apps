//
//  PlacementCell.swift
//  IntegrationDemo_Swift_UIKit
//
//  Created by Jeroen Verbeek on 3/16/23.
//

import UIKit

///---------------------------------------------------------------------------------------------
///---------------------------------------------------------------------------------------------
class PlacementCell : UITableViewCell {
	
	@IBOutlet weak var title: UILabel!
	@IBOutlet weak var subLabel: UILabel!
	
	///---------------------------------------------------------------------------------------------
	class func cell(tableView: UITableView, placement: String) -> PlacementCell {
		
		var cell: PlacementCell? = tableView.dequeueReusableCell(withIdentifier: "PlacementCell") as? PlacementCell
		if(cell == nil) {
			cell = PlacementCell(style: .default, reuseIdentifier: "PlacementCell")
		}
		cell?.fillCell(placement: placement)
		return cell!
	}

	///---------------------------------------------------------------------------------------------
	func fillCell(placement: String) {
		
		title.text = placement
		subLabel.text = ""
	}

}
