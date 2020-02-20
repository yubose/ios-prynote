//
//  Common.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/16/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

//MARK: - Retrieve
public class RetrieveArgs {
    let ids: [Data]//if empty, all objects in that type will be retrieved
    var xfname: String // the "field name", for which the "id" is compared against, default field name is "id"
    var type: Int32?
    var maxCount: Int32?//if nil, no limitation on maxCount
    
    public init(ids: [Data], xfname: String, type: Int32? = nil, maxCount: Int32? = nil) {
        self.ids = ids
        self.type = type
        self.maxCount = maxCount
        self.xfname = xfname
    }
}

public class RetrieveSingleArgs: RetrieveArgs {
    public init(id: Data, type: Int32? = nil) {
        super.init(ids: [id], xfname: "id", type: type, maxCount: nil)
    }
}

//MARK: - Delete
public struct DeleteArgs {
    let id: Data
    
    init(id: Data) {
        self.id = id
    }
}
