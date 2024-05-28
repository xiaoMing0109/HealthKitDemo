//
//  PLVHealthKitManager.swift
//  HealthKitDemo
//
//  Created by 怦然心动-LM on 2024/5/15.
//

import UIKit
import HealthKit

class PLVHealthKitManager {
    
    static let shared = PLVHealthKitManager()
    
    /// [写]权限
    static let dataTypesToWrite: Set<HKSampleType?> = [
        .height,
        .weight,
        .heartRate,
        .BMI,
        .bloodPressureSystolic,
        .bloodPressureDiastolic,
        .oxygenSaturation,
        .bloodGlucose,
        .bodyTemperature,
        // Add other data types you want to write here.
    ]
    
    /// [读]权限
    static var dataTypesToRead: Set<HKObjectType?> = [
        .height,
        .weight,
        // Add other data types you want to read here.
    ]
    
    typealias SaveObjectHandler = (Bool, HKSample?, (any Error)?) -> Void
    typealias SaveObjectsHandler = (Bool, [HKSample]?, (any Error)?) -> Void
    
    // MARK: Public Properties
    
    private(set) lazy var healthKitPermission = PLVHealthKitPermission()
    
    // MARK: Private Properties
    
    
    // MARK: Life Cycle
    
    init() {}
    
    deinit {}
}

// MARK: - Private

extension PLVHealthKitManager {}

// MARK: - Write

extension PLVHealthKitManager {

    /// - Note: 该方法暂时保留
    func plv_writeQuantityArray(
        _ array: [(value: Double, date: Date, unit: HKUnit)],
        completion: SaveObjectsHandler? = nil
    ) {
        guard let type = HKObjectType.height else {
            completion?(false, nil, nil)
            return
        }
        
        let samples: [HKQuantitySample] = array.map { tuple in
            let quantity = HKQuantity(unit: tuple.unit, doubleValue: tuple.value)
            let sample = HKQuantitySample(
                type: type,
                quantity: quantity,
                start: tuple.date,
                end: tuple.date
            )
            return sample
        }
        healthKitPermission.healthStore.save(samples) { success, error in
            DispatchQueue.main.async {
                completion?(success, samples, error)
            }
            if let error = error {
                print("☹️ Write quantity array error: \(error.localizedDescription)")
            } else {
                print("😊 Write height successfully!")
            }
        }
    }
    
    /// Write height.
    /// - Parameters:
    ///   - height: Double type.
    ///   - unit: .meter()/.meterUnit(with: .centi)/.inch()
    ///   - date: Record date.
    func plv_writeHeight(
        _ height: Double,
        unit: HKUnit,
        date: Date,
        completion: SaveObjectHandler? = nil
    ) {
        guard let type = HKObjectType.height else {
            completion?(false, nil, nil)
            return
        }
        
        let quantity = HKQuantity(unit: unit, doubleValue: height)
        let sample = HKQuantitySample(
            type: type,
            quantity: quantity,
            start: date,
            end: date
        )
        healthKitPermission.healthStore.save(sample) { success, error in
            DispatchQueue.main.async {
                completion?(success, sample, error)
            }
            if let error = error {
                print("☹️ Write height error: \(error.localizedDescription)")
            } else {
                print("😊 Write height successfully!")
            }
        }
    }
    
    /// Write weight.
    /// - Parameters:
    ///   - weight: Double type.
    ///   - unit: .gramUnit(with: .kilo)/.pound()
    ///   - date: Record date.
    func plv_writeWeight(
        _ weight: Double,
        unit: HKUnit,
        date: Date,
        completion: SaveObjectHandler? = nil
    ) {
        guard let type = HKObjectType.weight else {
            completion?(false, nil, nil)
            return
        }
        
        let quantity = HKQuantity(unit: unit, doubleValue: weight)
        let sample = HKQuantitySample(
            type: type,
            quantity: quantity,
            start: date,
            end: date
        )
        healthKitPermission.healthStore.save(sample) { success, error in
            DispatchQueue.main.async {
                completion?(success, sample, error)
            }
            if let error = error {
                print("☹️ Write weight error: \(error.localizedDescription)")
            } else {
                print("😊 Write weight successfully!")
            }
        }
    }
    
    /// Write BMI.
    func plv_writeBodyMassIndex(
        _ bodyMassIndex: Double,
        date: Date,
        completion: SaveObjectHandler? = nil
    ) {
        guard let type = HKObjectType.BMI else {
            completion?(false, nil, nil)
            return
        }
        
        let quantity = HKQuantity(unit: .bmiUnit, doubleValue: bodyMassIndex)
        let sample = HKQuantitySample(
            type: type,
            quantity: quantity,
            start: date,
            end: date
        )
        healthKitPermission.healthStore.save(sample) { success, error in
            DispatchQueue.main.async {
                completion?(success, sample, error)
            }
            if let error = error {
                print("☹️ Write body mass index error: \(error.localizedDescription)")
            } else {
                print("😊 Write body mass index successfully!")
            }
        }
    }
    
    /// Write heartRate.
    func plv_writeHeartRate(
        _ heartRate: Double,
        date: Date,
        completion: SaveObjectHandler? = nil
    ) {
        guard let type = HKObjectType.heartRate else {
            completion?(false, nil, nil)
            return
        }
        
        let quantity = HKQuantity(unit: .heartRateUnit, doubleValue: heartRate)
        let sample = HKQuantitySample(
            type: type,
            quantity: quantity,
            start: date,
            end: date
        )
        healthKitPermission.healthStore.save(sample) { success, error in
            DispatchQueue.main.async {
                completion?(success, sample, error)
            }
            if let error = error {
                print("☹️ Write heartRate error: \(error.localizedDescription)")
            } else {
                print("😊 Write heartRate successfully!")
            }
        }
    }
    
    /// Write blood pressure.
    /// - Parameters:
    ///   - bloodPressureSystolic: 收缩压
    ///   - bloodPressureDiastolic: 舒张压
    func plv_writeBloodPressure(
        bloodPressureSystolic: Double,
        bloodPressureDiastolic: Double,
        date: Date,
        completion: SaveObjectsHandler? = nil
    ) {
        guard let systolicType = HKObjectType.bloodPressureSystolic,
              let diastolicType = HKObjectType.bloodPressureDiastolic,
              let bloodPressureType = HKObjectType.bloodPressure
        else {
            completion?(false, nil, nil)
            return
        }
        
        let systolicQuantity = HKQuantity(unit: .bloodPressureUnit, doubleValue: bloodPressureSystolic)
        let systolicSample = HKQuantitySample(
            type: systolicType,
            quantity: systolicQuantity,
            start: date,
            end: date
        )
        
        let diastolicQuantity = HKQuantity(unit: .bloodPressureUnit, doubleValue: bloodPressureDiastolic)
        let diastolicSample = HKQuantitySample(
            type: diastolicType,
            quantity: diastolicQuantity,
            start: date,
            end: date
        )
        
        let correlation = HKCorrelation(type: bloodPressureType, start: date, end: date, objects: [systolicSample, diastolicSample])
        healthKitPermission.healthStore.save(correlation) { success, error in
            DispatchQueue.main.async {
                completion?(success, [systolicSample, diastolicSample], error)
            }
            if let error = error {
                print("☹️ Write blood pressure error: \(error.localizedDescription)")
            } else {
                print("😊 Write blood pressure successfully!")
            }
        }
    }
    
    /// Write blood oxygen.
    /// - Parameters:
    ///   - oxygenSaturation: 0.0...1.0
    ///   - date: Record date.
    func plv_writeBloodOxygenSaturation(
        _ oxygenSaturation: Double,
        date: Date,
        completion: SaveObjectHandler? = nil
    ) {
        guard let type = HKObjectType.oxygenSaturation else {
            completion?(false, nil, nil)
            return
        }
        
        let quantity = HKQuantity(unit: .oxygenSaturationUnit, doubleValue: oxygenSaturation)
        let sample = HKQuantitySample(
            type: type,
            quantity: quantity,
            start: date,
            end: date
        )
        healthKitPermission.healthStore.save(sample) { success, error in
            DispatchQueue.main.async {
                completion?(success, sample, error)
            }
            if let error = error {
                print("☹️ Write blood oxygen saturation error: \(error.localizedDescription)")
            } else {
                print("😊 Write blood oxygen saturation successfully!")
            }
        }
    }
    
    /// Write body temperature.
    /// - Parameters:
    ///   - weight: Double type.
    ///   - unit: .degreeCelsius()/.degreeFahrenheit()/.kelvin()
    ///   - date: Record date.
    func plv_writeBodyTemperature(
        _ bodyTemperature: Double,
        unit: HKUnit,
        date: Date,
        completion: SaveObjectHandler? = nil
    ) {
        guard let type = HKObjectType.bodyTemperature else {
            completion?(false, nil, nil)
            return
        }
        
        let quantity = HKQuantity(unit: unit, doubleValue: bodyTemperature)
        let sample = HKQuantitySample(
            type: type,
            quantity: quantity,
            start: date,
            end: date
        )
        healthKitPermission.healthStore.save(sample) { success, error in
            DispatchQueue.main.async {
                completion?(success, sample, error)
            }
            if let error = error {
                print("☹️ Write body temperature error: \(error.localizedDescription)")
            } else {
                print("😊 Write body temperature successfully!")
            }
        }
    }
    
    /// Write blood glucose.
    /// - Parameters:
    ///   - bloodGlucose: Double type.
    ///   - unit: HKUnit {`.mg_dL/HKUnit.mmol_L`}
    func plv_writeBloodGlucose(
        _ bloodGlucose: Double,
        unit: HKUnit,
        date: Date,
        completion: SaveObjectHandler? = nil
    ) {
        guard let type = HKObjectType.bloodGlucose else {
            completion?(false, nil, nil)
            return
        }
        
        let quantity = HKQuantity(unit: unit, doubleValue: bloodGlucose)
        let sample = HKQuantitySample(
            type: type,
            quantity: quantity,
            start: date,
            end: date
        )
        healthKitPermission.healthStore.save(sample) { success, error in
            DispatchQueue.main.async {
                completion?(success, sample, error)
            }
            if let error = error {
                print("☹️ Write blood glucose error: \(error.localizedDescription)")
            } else {
                print("😊 Write blood glucose successfully!")
            }
        }
    }
}

// MARK: - Read

extension PLVHealthKitManager {
    
    /// 获取用户生物特性
    ///
    /// 生物特性仅可获取, 无法写入。若未填写则获取失败。
    func plv_readAgeSexAndBloodType() throws -> (birthComponents: DateComponents,
                                                 biologicalSex: HKBiologicalSex,
                                                 bloodType: HKBloodType) {
        do {
            // This method throws an error if these data are not available.
            let birthdayComponents  = try healthKitPermission.healthStore.dateOfBirthComponents()
            let biologicalSex       = try healthKitPermission.healthStore.biologicalSex()
            let bloodType           = try healthKitPermission.healthStore.bloodType()
            
            // Unwrap the wrappers to get the underlying enum values.
            let unwrappedBiologicalSex = biologicalSex.biologicalSex
            let unwrappedBloodType = bloodType.bloodType
            
            return (birthdayComponents, unwrappedBiologicalSex, unwrappedBloodType)
        }
    }
    
    /// Read lastest height.
    /// - Parameters:
    ///   - unit: .meter()/.inch()
    ///   - start: Start date.
    ///   - end: End date.
    ///   - completion: Double type.
    func plv_readLastestHeight(
        unit: HKUnit,
        start: Date,
        end: Date,
        completion: @escaping (Double?) -> Void
    ) {
        guard let type = HKObjectType.height else {
            completion(nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: [])
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            guard error == nil, let samples = samples as? [HKQuantitySample] else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let result = samples.last.map { $0.quantity.doubleValue(for: unit) }
            DispatchQueue.main.async {
                completion(result)
            }
        }
        healthKitPermission.healthStore.execute(query)
    }
    
    /// Read lastest weight.
    /// - Parameters:
    ///   - unit: .gramUnit(with: .kilo)/.pound()
    ///   - start: Start date.
    ///   - end: End date.
    ///   - completion: Double type.
    func plv_readLastestWeight(
        unit: HKUnit,
        start: Date,
        end: Date,
        completion: @escaping (Double?) -> Void
    ) {
        guard let type = HKObjectType.weight else {
            completion(nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: [])
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            guard error == nil, let samples = samples as? [HKQuantitySample] else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let result = samples.last.map { $0.quantity.doubleValue(for: unit) }
            DispatchQueue.main.async {
                completion(result)
            }
        }
        healthKitPermission.healthStore.execute(query)
    }
    
    /// Read BMI.
    /// - Parameters:
    ///   - start: Start date.
    ///   - end: End date.
    ///   - completion: Double array.
    func plv_readBodyMassIndex(
        start: Date,
        end: Date,
        completion: @escaping ([Double]?) -> Void
    ) {
        guard let type = HKObjectType.BMI else {
            completion(nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: [])
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            guard error == nil, let samples = samples as? [HKQuantitySample] else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let results = samples.map { $0.quantity.doubleValue(for: .bmiUnit) }
            DispatchQueue.main.async {
                completion(results)
            }
        }
        healthKitPermission.healthStore.execute(query)
    }
    
    /// 获取心率
    func plv_readHeartRate(
        start: Date,
        end: Date,
        completion: @escaping ([Double]?) -> Void
    ) {
        guard let type = HKObjectType.heartRate else {
            completion(nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: [])
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            guard error == nil, let samples = samples as? [HKQuantitySample] else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let results = samples.map { $0.quantity.doubleValue(for: .heartRateUnit) }
            DispatchQueue.main.async {
                completion(results)
            }
        }
        healthKitPermission.healthStore.execute(query)
    }
    
    /// 获取血糖
    func plv_readBloodGlucose(
        unit: HKUnit,
        start: Date,
        end: Date,
        completion: @escaping ([Double]?) -> Void
    ) {
        guard let type = HKObjectType.bloodGlucose else {
            completion(nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: [])
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            guard error == nil, let samples = samples as? [HKQuantitySample] else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let results = samples.map { $0.quantity.doubleValue(for: unit) }
            DispatchQueue.main.async {
                completion(results)
            }
        }
        healthKitPermission.healthStore.execute(query)
    }
    
    /// 获取血压
    func plv_readBloodPresure(
        start: Date,
        end: Date,
        completion: @escaping (HKCorrelationQuery?, [HKCorrelation]?, (any Error)?) -> Void
    ) {
        guard let type = HKObjectType.bloodPressure else {
            completion(nil, nil, nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: [])
        let query = HKCorrelationQuery(type: type, predicate: predicate, samplePredicates: nil) { query, correlations, error in
            guard error == nil, let correlations = correlations else {
                DispatchQueue.main.async {
                    completion(query, correlations, error)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(query, correlations, error)
            }
        }
        healthKitPermission.healthStore.execute(query)
    }
    
    /// Stops a long-running query.
    func plv_stopRead(_ query: HKQuery) {
        healthKitPermission.healthStore.stop(query)
    }
}

// MARK: - Utils

extension PLVHealthKitManager {
    
    /// Calculate age from dateOfBirthComponents.
    func plv_transformAge(from dateOfBirthComponents: DateComponents) -> Int {
        let today = Date()
        let calendar = Calendar.current
        let todayDateComponents = calendar.dateComponents([.year], from: today)
        let thisYear = todayDateComponents.year!
        let age = thisYear - dateOfBirthComponents.year!
        return age
    }
    
    /// 获取推荐 Units.
    ///
    ///  默认情况下，首选单位基于设备的当前语言环境。例如，在美国，bodyMass 标识符的首选单位是磅, 其他地区可能使用公斤或磅。
    ///  用户可以随时在健康应用程序中更改他们的首选单位。
    ///
    /// - Warning:  这个方法返回的结果是基于你的应用程序的权限:
    ///             如果您从未请求过某个类型的访问权限，则此方法将返回一个未确定授权的错误。
    ///             如果用户拒绝访问某个类型，则此方法返回该类型的设备当前区域设置的默认单位。
    ///             如果用户授予读或共享访问权限，则此方法返回该类型的当前首选单元(可能是也可能不是默认单元)。
    ///
    /// - Parameter quantityTypes: Set<HKQuantityType>
    func plv_fetchPreferredUnits(
        for quantityTypes: Set<HKQuantityType>,
        completion: @escaping ([HKQuantityType: HKUnit]) -> Void
    ) {
        healthKitPermission.healthStore.preferredUnits(for: quantityTypes) { map, error in
            DispatchQueue.main.async {
                completion(map)
            }
        }
    }
}

// MARK: - Notification

extension PLVHealthKitManager {}

// MARK: - Observe

extension PLVHealthKitManager {}

// MARK: - HKObjectType & HKUnit

extension HKObjectType {
    /// 性别, 只读
    static let sex = HKObjectType.characteristicType(forIdentifier: .biologicalSex)
    /// 血型, 只读
    static let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType)
    /// 生日, 只读
    static let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth)
    /// 身高
    static let height = HKQuantityType.quantityType(forIdentifier: .height)
    /// 体重
    static let weight = HKQuantityType.quantityType(forIdentifier: .bodyMass)
    /// 心率
    static let heartRate = HKQuantityType.quantityType(forIdentifier: .heartRate)
    /// BMI
    static let BMI = HKQuantityType.quantityType(forIdentifier: .bodyMassIndex)
    /// 舒张压
    static let bloodPressureDiastolic = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)
    /// 收缩压
    static let bloodPressureSystolic = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)
    /// 血压, 仅存储读取时使用。写入真正类型为 `bloodPressureDiastolic、bloodPressureSystolic`.
    ///
    /// - Warning: 不要添加进 [读、写] 授权类型中。
    ///            Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: 'Authorization to read the following types is disallowed: HKCorrelationTypeIdentifierBloodPressure')
    static let bloodPressure = HKCorrelationType.correlationType(forIdentifier: .bloodPressure)
    /// 血氧
    static let oxygenSaturation = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)
    /// 体温
    static let bodyTemperature = HKQuantityType.quantityType(forIdentifier: .bodyTemperature)
    /// 血糖
    static let bloodGlucose = HKQuantityType.quantityType(forIdentifier: .bloodGlucose)
    /// 步数
    static let stepCount = HKQuantityType.quantityType(forIdentifier: .stepCount)
}

extension HKUnit {
    /// kg
    static let kgUnit = HKUnit.gramUnit(with: .kilo)
    /// lb
    static let lbUnit = HKUnit.pound()
    /// m
    static let mUnit = HKUnit.meter()
    /// cm
    static let cmUnit = HKUnit.meterUnit(with: .centi)
    /// inch
    static let inchUnit = HKUnit.inch()
    /// count
    static let stepUnit = HKUnit.count()
    /// count
    static let bmiUnit = HKUnit.count()
    /// second
    static let timeUnit = HKUnit.second()
    /// meter
    static let distanceUnit = HKUnit.meter()
    /// kilocalorie
    static let calorieUnit = HKUnit.kilocalorie()
    /// count/min
    static let heartRateUnit = HKUnit(from: "count/min")
    /// mmHg
    static let bloodPressureUnit = HKUnit.millimeterOfMercury()
    /// % (0.0 - 1.0)
    static let oxygenSaturationUnit = HKUnit.percent()
    /// degC
    static let CUnit = HKUnit.degreeCelsius()
    /// degF
    static let FUnit = HKUnit.degreeFahrenheit()
    /// K
    static let KUnit = HKUnit.liter()
    /// mmol/L
    static let mmol_L = HKUnit.moleUnit(
        with: .milli,
        molarMass: HKUnitMolarMassBloodGlucose
    ).unitDivided(by: .liter())
    /// mg/dL
    static let mg_dL = HKUnit.gramUnit(with: .milli).unitDivided(by: .literUnit(with: .deci))
}
