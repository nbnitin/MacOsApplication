//
//  ListKeyChainActionCell.swift
//  StorageDemoApp
//
//  Created by Nitin Bhatia on 21/09/23.
//

import Cocoa

class ListKeyChainActionCell: NSTableCellView {
    
    //outlets
    @IBOutlet weak var btnDelete: NSButton!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
    
}

class CustomerListViewCell: NSTableCellView {
    
    //outlets
    @IBOutlet weak var imgCheckMark: NSImageView!
    @IBOutlet weak var txtCustomerName: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
    
}
