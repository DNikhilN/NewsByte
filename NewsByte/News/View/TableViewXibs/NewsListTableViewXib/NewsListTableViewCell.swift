//
//  NewsListTableViewCell.swift
//  NewsByte
//
//  Created on 11/09/25.
//

import UIKit

class NewsListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bookmarkBtnOutlet: UIButton!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var imgVw: UIImageView!
    
    var completionForBookmarkSelection: ((Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUi()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupUi(){
        imgVw.layer.cornerRadius = 10
        imgVw.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        imgVw.clipsToBounds = true
        imgVw.layer.borderWidth = 0.5
        imgVw.layer.borderColor = UIColor.systemGray.cgColor
        
        bookmarkBtnOutlet.layer.shadowColor   = UIColor.black.cgColor
        bookmarkBtnOutlet.layer.shadowOpacity = 0.35       // adjust 0–1
        bookmarkBtnOutlet.layer.shadowOffset  = CGSize(width: 0, height: 1)
        bookmarkBtnOutlet.layer.shadowRadius  = 2
        bookmarkBtnOutlet.clipsToBounds       = false
    }
    
    @IBAction func bookmarkBtn(_ sender: UIButton) {
        self.completionForBookmarkSelection?(sender.tag)
    }
    
    
}
