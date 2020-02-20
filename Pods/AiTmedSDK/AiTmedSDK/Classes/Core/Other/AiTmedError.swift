//
//  AiTmedError.swift
//  Prynote
//
//  Created by Yi Tong on 10/29/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

protocol InformativeError{
    var msg: String { get }
}

public enum AiTmedError: Error {
    case grpcFailed(GRPCError)
    case apiResultFailed(APIResultError)
    case credentialFailed(CredentialError)
    case internalError(InternalError)
    case unkown(String)
    
    public var title: String {
        switch self {
        case .grpcFailed(_):
            return "grpc error"
        case .apiResultFailed(_):
            return "api error"
        case .credentialFailed(_):
            return "credential error"
        case .internalError(_):
            return "internal error"
        case .unkown(_):
            return "unkown error"
        }
    }
    
    public var msg: String {
        switch self {
        case .credentialFailed(let error as InformativeError),
             .grpcFailed(let error as InformativeError),
             .apiResultFailed(let error as InformativeError),
             .internalError(let error as InformativeError):
            return error.msg
        case .unkown(let detail):
            return detail
        }
    }
    
    public enum CredentialError: InformativeError {
        case passwordWrong
        case passwordNeeded
        case credentialNeeded
        case signInNeeded
        case besakNil
        case eesakNil
        case JWTExpired(String)
        
        var msg: String {
            switch self {
            case .passwordWrong:
                return "password is wrong"
            case .passwordNeeded:
                return "password needed"
            case .credentialNeeded:
                return "credential needed"
            case .signInNeeded:
                return "signin needed"
            case .besakNil:
                return "besak is nil"
            case .eesakNil:
                return "eesak is nil"
            case .JWTExpired(_):
                return "JWT has expired"
            }
        }
    }
    
    public enum GRPCError: InformativeError {
        case unkown(String)
        
        var msg: String {
            switch self {
            case .unkown(let detail):
                return detail
            }
        }
    }
    
    public enum APIResultError: InformativeError {
        case userNotExist
        case apiNoResponse
        case uploadFailed
        case downloadFailed
        case OPTCodeWrong
        case unkown(String)
        
        var msg: String {
            switch self {
            case .userNotExist:
                return "user not exist"
            case .apiNoResponse:
                return "api no response"
            case .uploadFailed:
                return "upload failed"
            case .downloadFailed:
                return "download failed"
            case .OPTCodeWrong:
                return "verification code is not correct"
            case .unkown(let detail):
                return detail
            }
        }
    }
    
    public enum InternalError: InformativeError {
        case dataCorrupted
        case zipFailed
        case decodeDeatFailed
        case decodeNameFailed
        case encodeNameFailed
        case encryptionFailed
        
        var msg: String {
            switch self {
            case .dataCorrupted:
                return "data corrupt"
            case .zipFailed:
                return "zip failed"
            case .decodeDeatFailed:
                return "decode deat failed"
            case .decodeNameFailed:
                return "decode name failed"
            case .encodeNameFailed:
                return "encode name failed"
            case .encryptionFailed:
                return "encryption failed"
            }
        }
    }
}
