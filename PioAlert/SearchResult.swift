//
//  SearchResult.swift
//  PioAlert
//
//  Created by LiveLife on 29/04/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import Foundation

class SearchRecord {
    
    var resultType:SearchRecordType!
    
    var imagePath:String!
    var titleText:String!
    var subTitleText:String!
    
    
    enum SearchRecordType {
        case shop
        case promo
        case product
        case notSpecified
    }
    
    init(json: [String:AnyObject]) {
        self.resultType = SearchRecordType.notSpecified
    }
    
    func setResultType(_ resultType: SearchRecordType) {
        self.resultType = resultType
    }
}
