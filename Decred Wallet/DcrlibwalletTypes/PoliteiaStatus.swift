//
//  PoliteiaStatus.swift
//  Decred Wallet
//
//  Created by JustinDo on 8/17/20.
//  Copyright © 2020 Decred. All rights reserved.
//

import Foundation

enum PoliteiaStatus: Int, Codable {
    case INVALID = 0
    case NOT_AUTHORIZED = 1
    case AUTHORIZED = 2
    case VOTE_STARTED = 3
    case RESULTAPPROVED = 4
//    case RESULTREJECT = 4
    case NON_EXISTENT = 5
    case ABANDONED = 6
    
}

//extension PoliteiaStatus: Codable {
//    enum Key: CodingKey {
//        case rawValue
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: Key.self)
//        let rawValue = try container.decode(Int.self, forKey: .rawValue)
//        switch rawValue {
//        case 0:
//            self = .INVALID
//        case 1:
//            self = .NOT_AUTHORIZED
//        case 2:
//            self = .AUTHORIZED
//        case 3:
//            self = .VOTE_STARTED
//        case 4:
//            self = .RESULTAPPROVED
//        case 5:
//            self = .NON_EXISTENT
//        case 6:
//            self = .ABANDONED
//        default:
//            self = .INVALID
//        }
//    }
//}

extension PoliteiaStatus: CustomStringConvertible {
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
        case .RESULTAPPROVED:
            return LocalizedStrings.poliApproved
//        case .RESULTREJECT:
//            return LocalizedStrings.poliRejected
        case .NON_EXISTENT:
            return LocalizedStrings.poliNonExistent
        case .ABANDONED:
            return LocalizedStrings.poliAbandoned
        }
    }
}

//extension PoliteiaStatus {
//    init(va: Int) {
//        switch va {
//        case "EVERYONE":
//            self = .ALL
//        case "ALL_FRIENDS":
//            self = .ALL_FRIEND
//        case "FRIENDS_OF_FRIENDS":
//            self = .FRIEND_FRIEND
//        case "SELF":
//            self = .SELF
//        default:
//            self = .ALL
//        }
//    }
//}
