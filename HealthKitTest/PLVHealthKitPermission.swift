//
//  PLVHealthKitPermission.swift
//  HealthKitDemo
//
//  Created by 怦然心动-LM on 2024/5/15.
//

import UIKit
import HealthKit

struct PLVHealthKitPermission {
    
    enum PLVHealthKitPermissionStatus {
        /// 用户未选择
        case notDetermined
        /// 拒绝
        case denied
        /// 允许
        case authorized
        /// 设备不支持
        case notSupport
    }
    
    let healthStore = HKHealthStore()
    
    func plv_isHealthDataAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    /// 检查对应类型是否需要发起 request auth 请求.
    ///
    /// 适用场景:
    /// - 新增类型
    /// - 增加了 读/写 权限
    @available(iOS 12.0, *)
    func plv_checkShouldRequestAuthorization(
        dataTypesToWrite: Set<HKSampleType> = [],
        dataTypesToRead: Set<HKObjectType> = [],
        completion callback: @escaping (Bool, (any Error)?) -> Void
    ) {
        healthStore.getRequestStatusForAuthorization(toShare: dataTypesToWrite, read: dataTypesToRead) { status, error in
            DispatchQueue.main.async {
                switch status {
                case .shouldRequest:
                    callback(true, error)
                default:
                    callback(false, error)
                }
            }
        }
    }
    
    /// 请求对应类型[读、写]权限.
    ///
    /// 首次请求系统会弹出权限开关页面;
    /// 若后续发起请求类型含新增, 则系统会再次弹出权限开关页面, 但仅包含新增类型.
    ///
    /// - Parameters:
    ///   - dataTypesToWrite: 写权限类型
    ///   - dataTypesToRead: 读权限类型
    func plv_requestAuthorization(
        dataTypesToWrite: Set<HKSampleType?>? = PLVHealthKitManager.dataTypesToWrite,
        dataTypesToRead: Set<HKObjectType?>? = PLVHealthKitManager.dataTypesToRead,
        completion callback: ((PLVHealthKitPermissionStatus, (any Error)?) -> Void)?
    ) {
        if plv_isHealthDataAvailable() {
            var shareTypes: Set<HKSampleType>? {
                guard let dataTypesToWrite = dataTypesToWrite else {
                    return nil
                }
                return Set<HKSampleType>(dataTypesToWrite.compactMap { $0 })
            }
            var readTypes: Set<HKObjectType>? {
                guard let dataTypesToRead = dataTypesToRead else {
                    return nil
                }
                return Set<HKObjectType>(dataTypesToRead.compactMap { $0 })
            }
            healthStore.requestAuthorization(toShare: shareTypes, read: readTypes) { authorized, error in
                DispatchQueue.main.async {
                    callback?(authorized ? .authorized : .denied, error)
                }
            }
        } else {
            callback?(.notSupport, nil)
        }
    }
    
    /// 获取对应类型[写]权限状态.
    ///
    /// - Parameter type: HKObjectType
    /// - Returns: PLVHealthKitPermissionStatus
    func plv_writeAuthorizationStatus(for type: HKObjectType) -> PLVHealthKitPermissionStatus {
        guard plv_isHealthDataAvailable() else {
            return .notSupport
        }
        
        var authStatus: PLVHealthKitPermissionStatus = .notDetermined
        switch healthStore.authorizationStatus(for: type) {
        case .sharingAuthorized:    authStatus = .authorized
        case .notDetermined:        authStatus = .notDetermined
        case .sharingDenied:        authStatus = .denied
        default:                    authStatus = .notSupport
        }
        return authStatus
    }
}
