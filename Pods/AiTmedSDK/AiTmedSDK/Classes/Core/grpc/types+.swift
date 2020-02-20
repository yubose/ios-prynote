//
//  types+.swift
//  AiTmedSDK
//
//  Created by Yi Tong on 2/6/20.
//

import SwiftProtobuf

public struct Vertex {
    public var ctime: Int64 = 0
    
    public var mtime: Int64 = 0
    
    public var atime: Int64 = 0
    
    public var atimes: Int32 = 0
    
    public var tage: Int32 = 0
    
    public var id: Data = SwiftProtobuf.Internal.emptyData
    
    public var type: Int32 = 0
    
    public var name: String = String()
    
    public var deat: String = String()
    
    public var pk: Data = SwiftProtobuf.Internal.emptyData
    
    public var esk: Data = SwiftProtobuf.Internal.emptyData
    
    public var uid: String = String()
    
    init(v: Aitmed_Ecos_V1beta1_Vertex) {
        self.ctime = v.ctime
        self.mtime = v.mtime
        self.atime = v.atime
        self.atimes = v.atimes
        self.tage = v.tage
        self.id = v.id
        self.type = v.type
        self.name = v.name
        self.deat = v.deat
        self.pk = v.pk
        self.esk = v.esk
        self.uid = v.uid
    }
    
    func toGRPCVertex() -> Aitmed_Ecos_V1beta1_Vertex {
        var v = Aitmed_Ecos_V1beta1_Vertex()
        v.ctime = self.ctime
        v.mtime = self.mtime
        v.atime = self.atime
        v.atimes = self.atimes
        v.tage = self.tage
        v.id = self.id
        v.type = self.type
        v.name = self.name
        v.deat = self.deat
        v.pk = self.pk
        v.esk = self.esk
        v.uid = self.uid
        return v
    }
    
    public init() {}
}

public struct Edge {
    public var ctime: Int64 = 0
    
    public var mtime: Int64 = 0
    
    public var atime: Int64 = 0
    
    public var atimes: Int32 = 0
    
    public var tage: Int32 = 0
    
    public var id: Data = SwiftProtobuf.Internal.emptyData
    
    public var type: Int32 = 0
    
    public var name: String = String()
    
    public var deat: String = String()
    
    public var subtype: Int32  = 0
    
    public var bvid: Data = SwiftProtobuf.Internal.emptyData
    
    public var evid: Data = SwiftProtobuf.Internal.emptyData
    
    public var stime: Int64 = 0
    
    public var etime: Int64 = 0
    
    public var refid: Data = SwiftProtobuf.Internal.emptyData
    
    public var besak: Data = SwiftProtobuf.Internal.emptyData
    
    public var eesak: Data = SwiftProtobuf.Internal.emptyData
    
    public var sig: Data = SwiftProtobuf.Internal.emptyData
    
    var unknownFields = SwiftProtobuf.UnknownStorage()
    
    func toGRPCEdge() -> Aitmed_Ecos_V1beta1_Edge {
        var e = Aitmed_Ecos_V1beta1_Edge()
        e.ctime = self.ctime
        e.mtime = self.mtime
        e.atime = self.atime
        e.atimes = self.atimes
        e.tage = self.tage
        e.id = self.id
        e.type = self.type
        e.name = self.name
        e.deat = self.deat
        e.subtype = self.subtype
        e.bvid = self.bvid
        e.evid = self.evid
        e.stime = self.stime
        e.etime = self.etime
        e.refid = self.refid
        e.besak = self.besak
        e.eesak = self.eesak
        e.sig = self.sig
        e.unknownFields = self.unknownFields
        return e
    }
    
    init(e: Aitmed_Ecos_V1beta1_Edge) {
        self.ctime = e.ctime
        self.mtime = e.mtime
        self.atime = e.atime
        self.atimes = e.atimes
        self.tage = e.tage
        self.id = e.id
        self.type = e.type
        self.name = e.name
        self.deat = e.deat
        self.subtype = e.subtype
        self.bvid = e.bvid
        self.evid = e.evid
        self.stime = e.stime
        self.etime = e.etime
        self.refid = e.refid
        self.besak = e.besak
        self.eesak = e.eesak
        self.sig = e.sig
        self.unknownFields = e.unknownFields
    }
    
    public init() {}
}

public struct Doc {
    public var ctime: Int64 = 0
    
    public var mtime: Int64 = 0
    
    public var atime: Int64 = 0
    
    public var atimes: Int32 = 0
    
    public var tage: Int32 = 0
    
    public var id: Data = SwiftProtobuf.Internal.emptyData
    
    public var type: Int32 = 0
    
    public var name: String = String()
    
    public var deat: String = String()
    
    public var size: Int32 = 0
    
    public var fid: Data = SwiftProtobuf.Internal.emptyData
    
    public var eid: Data = SwiftProtobuf.Internal.emptyData
    
    public var bsig: Data = SwiftProtobuf.Internal.emptyData
    
    public var esig: Data = SwiftProtobuf.Internal.emptyData
    
    var unknownFields = SwiftProtobuf.UnknownStorage()
    
    func toGRPCDoc() -> Aitmed_Ecos_V1beta1_Doc {
        var d = Aitmed_Ecos_V1beta1_Doc()
        d.ctime = self.ctime
        d.mtime = self.mtime
        d.atime = self.atime
        d.atimes = self.atimes
        d.tage = self.tage
        d.id = self.id
        d.type = self.type
        d.name = self.name
        d.deat = self.deat
        d.size = self.size
        d.fid = self.fid
        d.eid = self.eid
        d.bsig = self.bsig
        d.esig = self.esig
        d.unknownFields = self.unknownFields
        return d
    }
    
    init(d: Aitmed_Ecos_V1beta1_Doc) {
        self.ctime = d.ctime
        self.mtime = d.mtime
        self.atime = d.atime
        self.atimes = d.atimes
        self.tage = d.tage
        self.id = d.id
        self.type = d.type
        self.name = d.name
        self.deat = d.deat
        self.size = d.size
        self.fid = d.fid
        self.eid = d.eid
        self.bsig = d.bsig
        self.esig = d.esig
        self.unknownFields = d.unknownFields
    }
    
    public init() {}
}
