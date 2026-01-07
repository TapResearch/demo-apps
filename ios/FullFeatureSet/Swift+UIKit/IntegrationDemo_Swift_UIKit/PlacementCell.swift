//
//  PlacementCell.swift
//  TestApp_Swift_UIKit
//
//  Created by Jeroen Verbeek on 3/16/23.
//

import UIKit
import TapResearchSDK

///---------------------------------------------------------------------------------------------
///---------------------------------------------------------------------------------------------
class PlacementCell : UITableViewCell {

	@IBOutlet weak var title: UILabel!
	@IBOutlet weak var subLabel: UILabel! // Not used right now since we get no infomration about a placement anymore.

	///---------------------------------------------------------------------------------------------
	class func cell(tableView: UITableView, indexPath: IndexPath, placement: String, info: String? = nil) -> PlacementCell {

		var cell: PlacementCell? = tableView.dequeueReusableCell(withIdentifier: "PlacementCell") as? PlacementCell
		if(cell == nil) {
			cell = PlacementCell(style: .default, reuseIdentifier: "PlacementCell")
		}
		cell?.fillCell(placement: placement, indexPath: indexPath, info: info)
		return cell!
	}

	///---------------------------------------------------------------------------------------------
	func fillCell(placement: String, indexPath: IndexPath, info: String?) {

		self.accessibilityLabel = placement
		title.text = placement
		if let info = info {
			subLabel.text = info
			subLabel.isHidden = false
		}
		else {
			subLabel.text = ""
			subLabel.isHidden = true
		}
	}

}

