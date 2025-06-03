//
//  SMSDelegate.swift
//  WomanProtection
//
//  Created by Zeynep on 3.06.2025.
//

import MessageUI

class SMSDelegate: NSObject, MFMessageComposeViewControllerDelegate {
    static let shared = SMSDelegate()

    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true)
    }
}
