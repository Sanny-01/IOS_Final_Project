//
//  ExchangeRates+CoreDataProperties.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 12.09.22.
//
//

import Foundation
import CoreData


extension ExchangeRates {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExchangeRates> {
        return NSFetchRequest<ExchangeRates>(entityName: "ExchangeRates")
    }

    @NSManaged public var gelToEur: Double
    @NSManaged public var gelToUsd: Double
    @NSManaged public var gelToGbp: Double
    @NSManaged public var usdToEur: Double

}

extension ExchangeRates : Identifiable {

}
