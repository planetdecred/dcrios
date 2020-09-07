//
//  PoliteiaStatus.swift
//  Decred Wallet
//
// Copyright © 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation

enum PoliteiaVoteStatus: Int, Codable {
    case INVALID = 0
    case NOT_AUTHORIZED = 1
    case AUTHORIZED = 2
    case VOTE_STARTED = 3
    case FINISH = 4
    case APPROVED = 41
    case REJECT = 42
    case NON_EXISTENT = 5
    case ABANDONED = 6
}

extension PoliteiaVoteStatus: CustomStringConvertible {
    var description: String {
        switch self {
        case .INVALID:
            return LocalizedStrings.poliInvalid
        case .NOT_AUTHORIZED:
            return LocalizedStrings.poliNotAuthorized
        case .AUTHORIZED:
            return LocalizedStrings.poliAuthorized
        case .VOTE_STARTED:
            return LocalizedStrings.poliVoteStarted
        case .APPROVED:
            return LocalizedStrings.poliApproved
        case .REJECT:
            return LocalizedStrings.poliRejected
        case .NON_EXISTENT:
            return LocalizedStrings.poliNonExistent
        case .ABANDONED:
            return LocalizedStrings.poliAbandoned
        default:
            return ""
        }
    }
}
