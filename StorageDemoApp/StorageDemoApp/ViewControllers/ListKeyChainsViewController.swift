//
//  ListKeyChainsViewController.swift
//  whitelabelling
//
//  Created by Nitin Bhatia on 15/09/23.
//

//this file will help to control keychain data

import Cocoa

class ListKeyChainViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    //outlets
    @IBOutlet weak var keyChainDataTableView: NSTableView!
    
    //variables
    var data: [[String:Any]] = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
    }
    
    //MARK: helps to set the table view
    func setTableView() {
        if let data = Storages.shared.read(service: Constants.KEY_CHAIN_WRAPPER) as? [[String:Any]] {
            self.data = data.filterForAppleAccount()
            keyChainDataTableView.reloadData()
        }
    }
    
    //MARK: - table view delegates and data source
    func numberOfRows(in tableView: NSTableView) -> Int {
        return data.count
    }
    
    //MARK: making cell
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let person = data[row]
        
        if tableColumn?.identifier.rawValue == "dataCell" {
            //tableColumn?.width = view.frame.width
            // tableColumn?.headerCell.drawsBackground = true
            //tableColumn?.headerCell.backgroundColor = NSColor.lightGray
            let title: String = "Apple Account"
            tableColumn?.headerCell.stringValue = title
            let dataColumn = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView
            dataColumn?.textField?.stringValue = person["acct"] as! String
            return dataColumn
        } else {
            //tableColumn?.width = view.frame.width
            // tableColumn?.headerCell.drawsBackground = true
            //tableColumn?.headerCell.backgroundColor = NSColor.lightGray
            let title: String = "Action"
            tableColumn?.headerCell.stringValue = title
            
            //             tableColumn?.headerCell.attributedStringValue = NSAttributedString(string: title, attributes: [
            //                 NSAttributedString.Key.font: fontMedium,
            //                 NSAttributedString.Key.foregroundColor: text1Tint,
            //                 NSAttributedString.Key.paragraphStyle : paragraphStyle])
            
            
            
            
            let actionColumn = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? ListKeyChainActionCell
            actionColumn?.btnDelete.tag = row
            
            actionColumn?.btnDelete.target = self
            actionColumn?.btnDelete.action = #selector(self.actionTaken(_:))
            
            return actionColumn
        }
    }
    
    //MARK: did column selected in header view
    func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        print(tableColumn)
    }
    
    //MARK: height of row
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 30
    }
    
    //MARK: did row selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let table = notification.object as? NSTableView else {
            return
        }
        
        for i in table.selectedRowIndexes {
            let cell = table.view(atColumn: 0, row: i, makeIfNecessary: true) as? CustomerListViewCell
            cell?.imgCheckMark.isHidden = false
        }
    }
    
    //MARK: when delete button pressed
    @objc func actionTaken(_ sender: NSButton) {
        if askForConfirmation() {
            Storages.shared.delete(service: Constants.KEY_CHAIN_WRAPPER, account: data[sender.tag]["acct"] as! String)
            data.remove(at: sender.tag)
            keyChainDataTableView.removeRows(at: IndexSet(arrayLiteral: sender.tag), withAnimation: .effectFade.union(.slideLeft))
        }
    }
    
    //MARK: asking for confirmation
    private func askForConfirmation() -> Bool {
        let modal = createAlert(title: "Please Confirm", message: "Are you sure you want to delete it?", okButtonTitle: "Delete", shouldShowCancelButton: true)
        let alert = modal.runModal()
        
        if alert == NSApplication.ModalResponse.alertFirstButtonReturn {
            return true
        }
        return false
    }
}
