//
//  ViewController.swift
//  HealthKitDemo
//
//  Created by 怦然心动-LM on 2024/5/15.
//

import UIKit
import HealthKit

class ViewController: UIViewController {

    private lazy var datas = PLVHealthKitManager.dataTypesToWrite.compactMap { $0 }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        makeConstraints()
        
        let writeTypes = Set<HKSampleType>(PLVHealthKitManager.dataTypesToWrite.compactMap { $0 })
        let readTypes = Set<HKObjectType>(PLVHealthKitManager.dataTypesToRead.compactMap { $0 })
        PLVHealthKitManager.shared.healthKitPermission.plv_checkShouldRequestAuthorization(
            dataTypesToWrite: writeTypes,
            dataTypesToRead: readTypes
        ) { [weak self] shouldRequest, error in
            guard let self = self else { return }
            print("HealthKit should request authorization: \(shouldRequest), error: \(String(describing: error))")
            
            if shouldRequest {
                PLVHealthKitManager.shared.healthKitPermission.plv_requestAuthorization { [weak self] status, error in
                    guard let self = self else { return }
                    
                    let haveAuthSwitchOn: Bool = {
                        let writeTypes = PLVHealthKitManager.dataTypesToWrite
                        if let _ = writeTypes.compactMap({ $0 }).first(where: { type in
                            let status = PLVHealthKitManager.shared.healthKitPermission.plv_writeAuthorizationStatus(for: type)
                            return status == .authorized
                        }) {
                            return true
                        } else {
                            return false
                        }
                    }()
                    if !haveAuthSwitchOn {
                        gotoSetting()
                    }
                    print("HealthKit permission status: \(String(describing: status)), haveAuthSwitchOn: \(haveAuthSwitchOn), error: \(String(describing: error))")
                }
            }
        }
    }
    
    private func setupSubviews() {
        title = "Health Kit"
        
        view.addSubview(tableView)
    }
    
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.delegate = self
        view.dataSource = self
        
        view.estimatedSectionHeaderHeight = 0
        view.estimatedSectionFooterHeight = 0
        view.estimatedRowHeight = 0
        
        view.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        return view
    }()
    
    private func makeConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

// MARK: - Action

extension ViewController {
    
    private func gotoSetting() {
        if let URL = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(URL) {
            UIApplication.shared.open(URL)
        }
    }
}

// MARK: - Delegate

// MARK: UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let data = datas[indexPath.item]
        cell.textLabel?.text = data.identifier
        return cell
    }
}

// MARK: UITableViewDelegate
extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let data = datas[indexPath.item]
        // Check write auth status.
        let writeStatus = PLVHealthKitManager.shared.healthKitPermission.plv_writeAuthorizationStatus(for: data)
        print("Authorization status: \(String(describing: writeStatus)), for: \(data)")
        
        switch data {
        case HKObjectType.height:
            // write, async
            if writeStatus == .authorized {
                PLVHealthKitManager.shared.plv_writeHeight(1.9, unit: .cmUnit, date: Date())
            }
            
            // read
            let end = Date()
            let start = Date(timeIntervalSince1970: 0)
            PLVHealthKitManager.shared.plv_readLastestHeight(unit: .cmUnit, start: start, end: end) { height in
                print("lastest height: \(String(describing: height))")
            }
        case HKObjectType.weight:
            // write, async
            if writeStatus == .authorized {
                PLVHealthKitManager.shared.plv_writeWeight(65, unit: .kgUnit, date: Date())
            }
            
            // read
            let end = Date()
            let start = Date(timeIntervalSince1970: 0)
            PLVHealthKitManager.shared.plv_readLastestWeight(unit: .lbUnit, start: start, end: end) { weight in
                print("lastest weight: \(String(describing: weight))")
            }
        case HKObjectType.BMI:
            // write, async
            if writeStatus == .authorized {
                PLVHealthKitManager.shared.plv_writeBodyMassIndex(24.0, date: Date())
            }
            
            // read
            let end = Date()
            let start = Date(timeIntervalSince1970: 0)
            PLVHealthKitManager.shared.plv_readBodyMassIndex(start: start, end: end) { BMIArray in
                print("BMI array: \(String(describing: BMIArray))")
            }
        case HKObjectType.heartRate:
            // write, async
            if writeStatus == .authorized {
                PLVHealthKitManager.shared.plv_writeHeartRate(99, date: Date())
            }
            
            // read
            let end = Date()
            let start = end.addingTimeInterval(-3600)
            PLVHealthKitManager.shared.plv_readHeartRate(start: start, end: end) { heartRateArray in
                print("heartRate array: \(String(describing: heartRateArray))")
            }
        case HKObjectType.bloodPressureDiastolic:
            // write, async
            if writeStatus == .authorized {
                PLVHealthKitManager.shared.plv_writeBloodPressure(
                    bloodPressureSystolic: 120,
                    bloodPressureDiastolic: 66,
                    date: Date()
                )
            }
            
            // read
            let end = Date()
            let start = end.addingTimeInterval(-3600)
            PLVHealthKitManager.shared.plv_readBloodPresure(start: start, end: end) { _, correlations, error in
                correlations?.forEach { correlation in
                    if let systolic = correlation.objects(for: .bloodPressureSystolic!).first as? HKQuantitySample,
                       let diastolic = correlation.objects(for: .bloodPressureDiastolic!).first as? HKQuantitySample {
                        let systolicValue = systolic.quantity.doubleValue(for: .bloodPressureUnit)
                        let diastolicValue = diastolic.quantity.doubleValue(for: .bloodPressureUnit)
                        let unitString = String(describing: HKUnit.bloodPressureUnit)
                        print("Read blood pressure, systolic: \(systolicValue) \(unitString), diastolic: \(diastolicValue) \(unitString)")
                    }
                }
            }
        case HKObjectType.bloodPressureSystolic:
            // write, async
            if writeStatus == .authorized {
                PLVHealthKitManager.shared.plv_writeBloodPressure(
                    bloodPressureSystolic: 120,
                    bloodPressureDiastolic: 66,
                    date: Date()
                )
            }
            
            // read
            let end = Date()
            let start = end.addingTimeInterval(-3600)
            PLVHealthKitManager.shared.plv_readBloodPresure(start: start, end: end) { _, correlations, error in
                correlations?.forEach { correlation in
                    if let systolic = correlation.objects(for: .bloodPressureSystolic!).first as? HKQuantitySample,
                       let diastolic = correlation.objects(for: .bloodPressureDiastolic!).first as? HKQuantitySample {
                        let systolicValue = systolic.quantity.doubleValue(for: .bloodPressureUnit)
                        let diastolicValue = diastolic.quantity.doubleValue(for: .bloodPressureUnit)
                        let unitString = String(describing: HKUnit.bloodPressureUnit)
                        print("Read blood pressure, systolic: \(systolicValue) \(unitString), diastolic: \(diastolicValue) \(unitString)")
                    }
                }
            }
        case HKObjectType.oxygenSaturation:
            // write, async
            if writeStatus == .authorized {
                PLVHealthKitManager.shared.plv_writeBloodOxygenSaturation(0.98, date: Date())
            }
        case HKObjectType.bodyTemperature:
            // write, async
            if writeStatus == .authorized {
                PLVHealthKitManager.shared.plv_writeBodyTemperature(36.5, unit: .CUnit, date: Date())
            }
        case HKObjectType.bloodGlucose:
            // write, async
            if writeStatus == .authorized {
                PLVHealthKitManager.shared.plv_writeBloodGlucose(6.0, unit: .mg_dL, date: Date())
            }
            
            // read
            let end = Date()
            let start = end.addingTimeInterval(-3600)
            PLVHealthKitManager.shared.plv_readBloodGlucose(unit: .mmol_L, start: start, end: end) { bloodGlucoseArray in
                print("bloodGlucose array: \(String(describing: bloodGlucoseArray))")
            }
        default: break
        }
    }
}
