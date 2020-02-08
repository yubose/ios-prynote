//
//  Bundle+.swift
//  AiTmed-Core
//
//  Created by tongyi on 2/5/20.
//
extension Bundle {
    static var current: Bundle {
        return Bundle(for: StartViewController.self)
    }
}
