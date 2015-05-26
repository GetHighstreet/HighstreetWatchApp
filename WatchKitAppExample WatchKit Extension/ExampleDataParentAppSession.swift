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
                products = categoryProducts[id]!.map { indexedProducts[$0]! }.map(favoritize)
            case .Favorites:
                products = favorites.map { indexedProducts[$0]! }.map(favoritize)
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
        } else if let warmUpRequest = request as? WarmUpRequest {
            return Future.succeeded(NSDate() as! R.ResponseType)
        } else if let productDetailsRequest = request as? ProductDetailsRequest {
            return Future.succeeded(
                ProductDetails(
                    product: favoritize(indexedProducts[productDetailsRequest.productId]!),
                    description: productDetails[productDetailsRequest.productId]
                ) as! R.ResponseType
            )
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

func groupBy<E, K>(source: [E], keyForElement: (E) -> (K)) -> [K:E] {
    var res = [K:E]()
    for elem in source {
        res[keyForElement(elem)] = elem
    }
    return res
}

let indexedProducts = groupBy(products) { $0.id }

let productDetails = [
    60689: "Aleja tanktop with a pretty round neckline. Simple and easy to combine!\n\nMaterial: 100% Lyocell\n\nSelected Femme represents a strong, open and metropolitan woman. She is fashion forward with an edge. Her wardrobe is a contrast between seductive and sophisticated items. Exclusive qualities as well as textured and eye-catching details enhance the unique and luxurious feel of the Selected Femme universe. The feminine creations are a fashionable mix between cool and chic. Selected Femme creations give the women a feminine way of life, full of confidence and freedom.",
    60059: "A pretty ' little black dress' from minus!",
    60053: "A pretty indigo dress with a small print on the top! Wear it to the office or on your lunch date.",
    60020: "This top in a soft fabric has a comfortable feel.\n\n-Short sleeved\n-Lined\n-Semi sheer mesh material\n\nMaterial: 69% Polyester, 30% Viscose, 1% Elastane\n\nCenter back length size 36: 92 cm",
    60019: "A pretty White with black print dress from Minus! Wear it to the office or on your lunch date.",
    60010: "The little black dress by Minus. Superfine dress in a simple design that is wearable for everyone. The dress has short sleeves, a round neck and a beautiful neckline behind. The dress has a beautiful figure, with a cut that accentuates the waist and is made from stretch material.\n\n50% Polyester, 45% Cotton, 5% Elastane\n\nAt Rum Amsterdam you will find the perfect timeless fashion classics, like the Little Black Dress and the must have leather pants. The carefully selected blend of brands, like Scandinavian labels, offers a solution for women who are looking for the most stylish wardrobe essentials.",
    60004: "This dress in a soft fabric has a comfortable feel. Perfect to mix with jewelry and a showy bag!\n\n-Short sleeved\n-Lined\n-Semi sheer mesh material\n\nMaterial: 69% Polyester, 30% Viscose, 1% Elastane\n\nCenter back length size 36: 131 cm",
    59992: "This unique piece provides a soft, comfortable feel.\n- Short play-suit\n- Zip front with drawstring waist\n- Side pockets\n\nMaterial: 80% Cotton, 20% Polyamide/Nylon\n\nCenter back to waistband length size 36: 52 cm; Inseam length size 36: 16 cm",
    59987: "Great kaftan, perfect for the summer and easy to match!\n\nSelected Femme represents a strong, open and metropolitan woman. She is fashion forward with an edge. Her wardrobe is a contrast between seductive and sophisticated items. Exclusive qualities as well as textured and eye-catching details enhance the unique and luxurious feel of the Selected Femme universe. The feminine creations are a fashionable mix between cool and chic. Selected Femme creations give the women a feminine way of life, full of confidence and freedom.",
    60636: "Super cute kimono brand Hippy Chick! The soft fabric ensures that the kimono beautifully falls on your body. Perfect to create the ultimate festival look!\n\nMaterial: 100% rayon",
    60047: "Super cute boho bag by Leon&Harper.\n\nKnitted bag by 23x25cm.\n\nThe Leon & Harper collection is feminine with an edgy touch. Designer Philippe Corbin is inspired by design, art, music and travel. The prints of Leon & Harper that are incorporated into tops, tunics, dresses and trousers are therefore unique and colourful. From cute printed knits to the perfect leather jacket, Leon & Harper has it all."
]

let categoryProducts = [
    68: [60689, 60059, 60053, 60020, 60019, 60010, 60004, 59992, 59987],
    1213: [60636, 60047],
    365: [60636, 60047, 60689, 60059, 60053, 60020, 60019, 60010, 60004, 59992, 59987],
    69: [60689, 60636, 60059, 60047, 60053, 60020, 60019, 60010, 60004, 59992, 59987],
    71: [60047]
]

var favorites = [60004]

/// Checks if the product is a favorite and returns a copy that reflects that
func favoritize(var product: Product) -> Product
{
    product.isFavorite = find(favorites, product.id) != nil
    return product
}
