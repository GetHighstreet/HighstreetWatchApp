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
    
    func execute<R : ParentAppRequest>(request: R, cache: ResponseCache?) -> Future<R.ResponseType> {
        return execute(request)
    }
    
    func execute<R : ParentAppRequest>(request: R) -> Future<R.ResponseType> {
        
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
    HomePromotion(id: 25, categoryId: 68, image: Image.RemoteImage(url: "http://cms.highstreet.imgix.net/negenstraatjes/promotions/wawasEJo2EwzWpmBz5N-5A@2x.jpg?rect=341,310,1365,1427&w=308&h=322")),
    HomePromotion(id: 65, categoryId: 1213, image: Image.RemoteImage(url: "http://cms.highstreet.imgix.net/negenstraatjes/promotions/SOdsvNoeGtXtGkpmf8nNeg@2x.jpg?rect=341,310,1365,1427&w=308&h=322")),
    HomePromotion(id: 27, categoryId: 365, image: Image.RemoteImage(url: "http://cms.highstreet.imgix.net/negenstraatjes/promotions/3BG2dE6DpHjv2b9O45S2bA@2x.jpg?rect=341,310,1365,1427&w=308&h=322")),
    HomePromotion(id: 66, categoryId: 69, image: Image.RemoteImage(url: "http://cms.highstreet.imgix.net/negenstraatjes/promotions/ClRJlRm8nq4bsnx9yimIbw@2x.jpg?rect=341,310,1365,1427&w=308&h=322")),
    HomePromotion(id: 29, categoryId: 71, image: Image.RemoteImage(url: "http://cms.highstreet.imgix.net/negenstraatjes/promotions/VdBZDLpqJ51qNIeJlSxCHA@2x.jpg?rect=341,310,1365,1427&w=308&h=322")),
]

let products = [
    Product(id: 60689, name: "Tanktop Aleja", secondaryAttribute: "SELECTED FEMME", price: "€ 39,95", image: Image.RemoteImage(url: "http://9straatjes.api.highstreetapp.com/hs-api/1.5/images/media/catalog/product/s/f/sfaleja_white_2_.jpg?size=259")),
    Product(id: 60059, name: "Layla Dress", secondaryAttribute: "MINUS", price: "€ 119,99", image: Image.RemoteImage(url: "http://9straatjes.api.highstreetapp.com/hs-api/1.5/images/media/catalog/product/m/i/mi1114_-_100_black_-_main.jpg?size=259")),
    Product(id: 60053, name: "Agam Dress", secondaryAttribute: "MINUS", price: "€ 119,99", image: Image.RemoteImage(url: "http://9straatjes.api.highstreetapp.com/hs-api/1.5/images/media/catalog/product/m/i/mi1046_-_532_mood_indigo_-_main.jpg?size=259")),
    Product(id: 60020, name: "Top Dion White", secondaryAttribute: "READY TO FISH", price: "€ 159,00", image: Image.RemoteImage(url: "http://9straatjes.api.highstreetapp.com/hs-api/1.5/images/media/catalog/product/d/i/dion_white_90.jpg?size=259")),
    Product(id: 60019, name: "Afreem Dress", secondaryAttribute: "MINUS", price: "€ 119,99", image: Image.RemoteImage(url: "http://9straatjes.api.highstreetapp.com/hs-api/1.5/images/media/catalog/product/m/i/mi1008_-_9014_liquid_print_-_main.jpg?size=259")),
    Product(id: 60010, name: "Dress Don Black", secondaryAttribute: "READY TO FISH", price: "€ 119,99", image: Image.RemoteImage(url: "http://9straatjes.api.highstreetapp.com/hs-api/1.5/images/media/catalog/product/d/o/don-90_black_ss15.jpg?size=259")),
    Product(id: 60004, name: "Dress Don White", secondaryAttribute: "READY TO FISH", price: "€ 119,99", image: Image.RemoteImage(url: "http://9straatjes.api.highstreetapp.com/hs-api/1.5/images/media/catalog/product/d/e/devon-89_black_ss15_1.jpg?size=259")),
    Product(id: 59992, name: "Jumpsuit Devon Orange", secondaryAttribute: "READY TO FISH", price: "€ 219,00", image: Image.RemoteImage(url: "http://9straatjes.api.highstreetapp.com/hs-api/1.5/images/media/catalog/product/d/e/devon_orange_89.jpg?size=259")),
    Product(id: 59987, name: "Kaftan nadja", secondaryAttribute: "SELECTED FEMME", price: "€ 59,95", image: Image.RemoteImage(url: "http://9straatjes.api.highstreetapp.com/hs-api/1.5/images/media/catalog/product/b/l/blouse-goed-1.jpg?size=259")),
    
    Product(id: 60636, name: "Hey macarena pink", secondaryAttribute: "LE SPECS", price: "€ 59,95", image: Image.RemoteImage(url: "http://9straatjes.api.highstreetapp.com/hs-api/1.5/images/media/catalog/product/b/l/blouse-goed-1.jpg?size=259")),
    Product(id: 60047, name: "Tasje Salvador", secondaryAttribute: "LEON & HARPER", price: "€ 79,95", image: Image.RemoteImage(url: "http://9straatjes.api.highstreetapp.com/hs-api/1.5/images/media/catalog/product/t/a/tasje-salvador-leon_harper.jpg?size=259"))
    
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