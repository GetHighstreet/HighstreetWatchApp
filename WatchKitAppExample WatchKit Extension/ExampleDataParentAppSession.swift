//
//  ExampleDataParentAppSession.swift
//  WatchKitAppExample
//
//  Created by Thomas Visser on 01/05/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import WatchKitExtensionCore
import BrightFutures

class ExampleDataParentAppSession: NSObject, ParentAppSession {
    
    required override init() {
    
    }
    
    func execute<R : ParentAppRequest>(request: R, cache: ResponseCache?) -> Future<R.ResponseType, Error> {
        return execute(request)
    }
    
    func execute<R : ParentAppRequest>(request: R) -> Future<R.ResponseType, Error> {
        
        if let homePromotionsRequest = request as? HomePromotionsListRequest {
            return Future.succeeded(promotions as! R.ResponseType)
        } else if let productListRequest = request as? ProductListRequest {
            let products: [Product]
            switch productListRequest.type {
            case .Category(let id):
                products = categoryProducts[id]!.map { indexedProducts[$0]! }
            case .Favorites:
                products = favorites.map { indexedProducts[$0]! }
            }
            
            if let range = intersection(validRange(products), productListRequest.range) {
                return Future.succeeded((products.count, Array(products[range])) as! R.ResponseType)
            } else {
                return Future.succeeded((products.count, [Product]()) as! R.ResponseType)
            }
        } else if let favoriteChangeRequest = request as? ChangeProductFavoriteStateRequest {
            switch favoriteChangeRequest.action {
            case .Add:
                // first remove it, if it was already a favorite
                if let index = find(favorites, favoriteChangeRequest.productId) {
                    favorites.removeAtIndex(index)
                }
                favorites.insert(favoriteChangeRequest.productId, atIndex: 0)
            case .Remove:
                if let index = find(favorites, favoriteChangeRequest.productId) {
                    favorites.removeAtIndex(index)
                }
            }
        }
        
        return Future.never()
    }
    
}

let promotions = [
    HomePromotion(id: 25, categoryId: 68, image: Image.RemoteImage(url: "http://i.imgur.com/xGBk3m9.jpg")),
    HomePromotion(id: 65, categoryId: 1213, image: Image.RemoteImage(url: "http://i.imgur.com/2cKWvU8.jpg")),
    HomePromotion(id: 27, categoryId: 365, image: Image.RemoteImage(url: "http://i.imgur.com/zO1GHtB.jpg")),
    HomePromotion(id: 66, categoryId: 69, image: Image.RemoteImage(url: "http://i.imgur.com/zO1GHtB.jpg")),
    HomePromotion(id: 29, categoryId: 71, image: Image.RemoteImage(url: "http://i.imgur.com/5Cyn66c.jpg")),
]

let products = [
    Product(id: 60689, name: "Tanktop Aleja", secondaryAttribute: "SELECTED FEMME", price: "€ 39,95", image: Image.RemoteImage(url: "http://i.imgur.com/S7KqCya.jpg")),
    Product(id: 60059, name: "Layla Dress", secondaryAttribute: "MINUS", price: "€ 119,99", image: Image.RemoteImage(url: "http://i.imgur.com/XcWJHF7.jpg")),
    Product(id: 60053, name: "Agam Dress", secondaryAttribute: "MINUS", price: "€ 119,99", image: Image.RemoteImage(url: "http://i.imgur.com/BfPhf2R.jpg")),
    Product(id: 60020, name: "Top Dion White", secondaryAttribute: "READY TO FISH", price: "€ 159,00", image: Image.RemoteImage(url: "http://i.imgur.com/XFK8G9X.jpg")),
    Product(id: 60019, name: "Afreem Dress", secondaryAttribute: "MINUS", price: "€ 119,99", image: Image.RemoteImage(url: "http://i.imgur.com/CzkTGFX.jpg")),
    Product(id: 60010, name: "Dress Don Black", secondaryAttribute: "READY TO FISH", price: "€ 119,99", image: Image.RemoteImage(url: "http://i.imgur.com/PTWgsEA.jpg")),
    Product(id: 60004, name: "Dress Don White", secondaryAttribute: "READY TO FISH", price: "€ 119,99", image: Image.RemoteImage(url: "http://i.imgur.com/dmaOUmj.jpg")),
    Product(id: 59992, name: "Jumpsuit Devon Orange", secondaryAttribute: "READY TO FISH", price: "€ 219,00", image: Image.RemoteImage(url: "http://i.imgur.com/NKk9Y3i.jpg")),
    Product(id: 59987, name: "Kaftan nadja", secondaryAttribute: "SELECTED FEMME", price: "€ 59,95", image: Image.RemoteImage(url: "http://i.imgur.com/IUQf1hQ.jpg")),
    
    Product(id: 60636, name: "Alva kimono", secondaryAttribute: "HIPPY CHICK", price: "€ 99,95", image: Image.RemoteImage(url: "http://i.imgur.com/4Xsa6ll.jpg")),
    Product(id: 60047, name: "Tasje Salvador", secondaryAttribute: "LEON & HARPER", price: "€ 79,95", image: Image.RemoteImage(url: "http://i.imgur.com/v0k75ZL.jpg"))
    
]

func indexed<E, K>(source: [E], keyForElement: (E) -> (K)) -> [K:E] {
    var res = [K:E]()
    for elem in source {
        res[keyForElement(elem)] = elem
    }
    return res
}

let indexedProducts = indexed(products) { $0.id }

let categoryProducts = [
    68: [60689, 60059, 60053, 60020, 60019, 60010, 60004, 59992, 59987],
    1213: [60636, 60047]
]

var favorites = [Int]()