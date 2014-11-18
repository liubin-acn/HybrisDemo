//
// HYOCCProtocol.h
// [y] hybris Platform
//
// Copyright (c) 2000-2013 hybris AG
// All rights reserved.
//
// This software is the confidential and proprietary information of hybris
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with hybris.
//

#import <Foundation/Foundation.h>

@class HYQuery;


/**
 *  This protocol describes the API calls communicate with the OCC layer of Hybris. Use these methods to interact with the store.
 *
 *
 *  All methods are asynchronous unless otherwise stated.
 *
 */
@protocol HYOCCProtocol<NSObject>

/** @name Product Methods */


/**
 *  Requests products with parameters encapsulated in a query object.
 *
 *  Relates to: {site}/products
 *
 *  @param query A query object
 */
- (void)products:(HYQuery *)query completionBlock:(NSDictionaryNSErrorBlock)completionBlock;


/**
 *  Request product details for a product with a given code.
 *
 *  Relates to: {site}/products/{product_code}
 *
 *  @param productCode The product's code. This can be obtained by calling products:(HYQuery *)query completionBlock:(NSArrayNSErrorBlock)completionBlock;
 *  @param options. An array of identifiers describing the level of information required. Each is a constant defined in Constants.h and begins HYProductOption.
 * Can be nil.
 *
 */
- (void)productWithCode:(NSString *)productCode options:(NSArray *)options completionBlock:(NSArrayNSErrorBlock)completionBlock;

/** @name Cart Methods */


/**
 *  Get the session cart
 *
 *  Relates to: {site}/cart
 */
- (void)cartWithCompletionBlock:(NSArrayNSErrorBlock)completionBlock;


/**
 *  Add item to cart
 *
 *  Relates to: {site}/cart/entry
 *
 *  @param code The item code
 */
- (void)addProductToCartWithCode:(NSString *)code completionBlock:(NSDictionaryNSErrorBlock)completionBlock;


/**
 *  Add item to cart (with quantity)
 *
 *  Relates to: {site}/cart/entry
 *
 *  @param code The item code
 *  @param quantity
 */
- (void)addProductToCartWithCode:(NSString *)code quantity:(NSInteger) quantity completionBlock:(NSDictionaryNSErrorBlock)completionBlock;


/**
 *  Update Quantity
 *
 *  Relates to:{site}/cart/entry/{entryNumber}
 *
 *  Update the quantity of an item in the cart
 *
 *  @param entry The entry (i.e. the index) of the item in the cart
 *  @param quantity The new quantity
 */
- (void)updateProductInCartAtEntry:(NSInteger) entry quantity:(NSInteger) quantity completionBlock:(NSDictionaryNSErrorBlock)completionBlock;


/**
 *  Delete a cart entry
 *
 *  Relates to: {site}/cart/entry/{entryNumber}
 *
 *  @param entry The entry (i.e. index) in the cart of the item to be deleted
 */
- (void)deleteProductInCartAtEntry:(NSInteger) entry completionBlock:(NSDictionaryNSErrorBlock)completionBlock;


/**
 *  Set delivery address
 *
 *  Relates to: {site}/cart/address/delivery/{id}
 *
 *  @param addressID The ID of the address being set as the delivery address
 */
- (void)setCartDeliveryAddressWithID:(NSString *)addressID completionBlock:(NSDictionaryNSErrorBlock)completionBlock;


/**
 *  Delete cart delovery address
 *
 *  Relates to: {site}/cart/address/delivery/
 */
- (void)deleteCartDeliveryAddressWithCompletionBlock:(NSDictionaryNSErrorBlock)completionBlock;


/**
 *  Get delivery modes.
 *
 *  Returns the possible delivery modes given the current cart delivery addresss.
 *
 *  Relates to: {site}/cart/deliverymodes/
 */
- (void)cartDeliveryModesWithCompletionBlock:(NSArrayNSErrorBlock)completionBlock;


/**
 *  Set delivery mode
 *
 *  Relates to: {site}/cart/deliverymodes/{code}}
 *
 *  @param code The code for the delivery mode. A list of codes is available by calling cartDeliveryModesWithCompletionBlock:
 */
- (void)setCartDeliveryModeWithCode:(NSString *)code completionBlock:(NSDictionaryNSErrorBlock)completionBlock;


/**
 *  Delete the delivery mode
 *
 *  Relates to: {site}/cart/deliverymodes/
 */
- (void)deleteCartDeliveryModesWithCompletionBlock:(NSDictionaryNSErrorBlock)completionBlock;


/**
 *  Add customer payment information
 *
 *  Relates to: {site}/cart/paymentinfo/
 *
 *  @param accountHolderName
 *  @param cardNumber
 *  @param cardType
 *  @param expiryMonth
 *  @param expiryYear
 *  @param shouldSave
 *  @param isDefaultPaymentInfo
 *  @param titleCode
 *  @param firstName
 *  @param lastName
 *  @param addressLine1
 *  @param addressLine2
 *  @param postCode
 *  @param town
 *  @param countryCode
 */
- (void)createCustomerPaymentInfoWithAccountHolderName:(NSString *)accountHolderName
                                            cardNumber:(NSString *)cardNumber
                                              cardType:(NSString *)cardType
                                           expiryMonth:(NSString *)expiryMonth
                                            expiryYear:(NSString *)expiryYear
                                                 saved:(BOOL) shouldSave
                                    defaultPaymentInfo:(BOOL) isDefaultPaymentInfo
                               billingAddressTitleCode:(NSString *)titleCode
                                             firstName:(NSString *)firstName
                                              lastName:(NSString *)lastName
                                          addressLine1:(NSString *)addressLine1
                                          addressLine2:(NSString *)addressLine2
                                              postCode:(NSString *)postCode
                                                  town:(NSString *)town
                                        countryISOCode:(NSString *)countryCode
                                       completionBlock:(NSDictionaryNSErrorBlock)completionBlock;


/**
 *  Method adds the credit card payment info (by id) with the current user's cart
 *
 *  Relates to: {site}/cart/paymentinfo/{id}
 */
- (void)setCartPaymentInfoWithID:(NSString *)paymentInfoID completionBlock:(NSDictionaryNSErrorBlock)completionBlock;


/**
 *  Method authorizes the credit card payment with the CCV security code
 *
 *  Relates to: {site}/cart/authorize
 *
 *  @param securityCode The CCV security code
 */
- (void)authorizeCreditCardPaymentWithSecurityCode:(NSString *)securityCode completionBlock:(NSDictionaryNSErrorBlock)completionBlock;


/**
 *  Method places an order based on the session cart
 *
 *  Relates to: {site}/cart/placeorder
 */
- (void)placeOrderForCartWithCompletionBlock:(NSDictionaryNSErrorBlock)completionBlock;


/**
 *  Returns order history data for all orders placed by the current user for the current base store. Response contains a pagable orders search result.
 *
 *  Relates to: {site}/orders
 *
 *  @param options This is a optional parameter. Takes in a dictionary with the following KEYS
 *   statuses (Required: false) filters only certain order statuses.. I.e : statuses=CANCELLED,CHECKED_VALID would return only orders with status CANCELLED or
 * CHECKED_VALID.
 *   currentPage (Required: false) Pagination attribute - which page is requested
 *   pageSize (Required: false) Pagination attribute - what is the requested page size
 *   sort (Required: false) Pagination attribute - what is sort preference
 */
- (void)ordersWithOptions:(NSDictionary *)options completionBlock:(NSDictionaryNSErrorBlock)completionBlock;


/**
 *  Returns specific order details
 *
 *  Relates to: {site}/orders/{code}
 *
 *  @param orderID The order ID
 */
- (void)orderDetailsWithID:(NSString *)orderID completionBlock:(NSDictionaryNSErrorBlock)completionBlock;

/** @name Customer Methods */


/**
 *  User login.
 *
 *  @param userName Username (email)
 *  @param password Password
 */
- (void)loginWithUsername:(NSString *)userName password:(NSString *)password completionBlock:(NSErrorBlock)completionBlock;


/**
 *  Log out
 *
 *  Relates to: customers/current/logout
 */
- (void)logoutWithCompletionBlock:(NSErrorBlock)completionBlock;


/**
 *  Register a new customer.
 *
 *  Relates to: {site}/customers
 *
 *  @param firstName
 *  @param lastName
 *  @param titleCode
 *  @param login (Should be an email address)
 *  @param password
 */
- (void)registerCustomerWithFirstName:(NSString *)firstName
                             lastName:(NSString *)lastName
                            titleCode:(NSString *)titleCode
                                login:(NSString *)login
                             password:(NSString *)password
                      completionBlock:(NSErrorBlock)completionBlock;


/**
 *  Set the default customer address.
 *
 *  Relates to: {site}/customers/current/addresses/default/{id}
 *
 *  @param addressID The ID of the address to be set as default (returned when craeting an address).
 */
- (void)setDefaultCustomerAddressWithID:(NSString *)addressID completionBlock:(NSErrorBlock)completionBlock;


/**
 *  Updates a customer profile.
 *
 *  Relates to: {site}/customers/current/profile
 *
 *  @param firstName
 *  @param lastName
 *  @param titleCode Options obtained by calling titlesWithCompletionBlock:(NSArrayNSErrorBlock)completionBlock;
 *  @param language Options obtained by calling languagesWithCompletionBlock:(NSArrayNSErrorBlock)completionBlock;
 *  @param currency Options obtained by calling currenciesWithCompletionBlock:(NSArrayNSErrorBlock)completionBlock;
 */
- (void)updateCustomerProfileWithFirstName:(NSString *)firstName
                                  lastName:(NSString *)lastName
                                 titleCode:(NSString *)titleCode
                                  language:(NSString *)language
                                  currency:(NSString *)currency
                           completionBlock:(NSDictionaryNSErrorBlock)completionBlock;


/**
 *  Create new address for customer.
 *
 *  Relates to: {site}/customers/current/addresses
 *
 *  @param firstName
 *  @param lastName
 *  @param titleCode
 *  @param addressLine1
 *  @param addressLine2
 *  @param town
 *  @param postCode
 *  @param countryISOCode
 */
- (void)createCustomerAddressWithFirstName:(NSString *)firstName
                                  lastName:(NSString *)lastName
                                 titleCode:(NSString *)titleCode
                              addressLine1:(NSString *)addressLine1
                              addressLine2:(NSString *)addressLine2
                                      town:(NSString *)town
                                  postCode:(NSString *)postCode
                            countryISOCode:(NSString *)countryISOCode
                           completionBlock:(NSDictionaryNSErrorBlock)completionBlock;


/**
 *  Gets the addresses of the customer.
 *
 *  Relates to: {site}/customers/current/addresses
 */
- (void)customerAddressesWithCompletionBlock:(NSArrayNSErrorBlock)completionBlock;


/**
 *  Update a customer address.
 *
 *  Relates to: {site}/customers/current/addresses/{id}
 *
 *  @param firstName
 *  @param lastName
 *  @param titleCode
 *  @param addressLine1
 *  @param addressLine2
 *  @param town
 *  @param postCode
 *  @param countryISOCode
 *  @param addressID The ID of the address to be updated (returned when craeting an address).
 */
- (void)updateCustomerAddressWithFirstName:(NSString *)firstName
                                  lastName:(NSString *)lastName
                                 titleCode:(NSString *)titleCode
                              addressLine1:(NSString *)addressLine1
                              addressLine2:(NSString *)addressLine2
                                      town:(NSString *)town
                                  postCode:(NSString *)postCode
                            countryISOCode:(NSString *)countryISOCode
                                 addressID:(NSString *)addressID
                           completionBlock:(NSDictionaryNSErrorBlock)completionBlock;


/**
 *  Delete a customer address given an ID.
 *
 *  Relates to: {site}/customers/current/addresses/{id}
 *
 *  @param addressID An address ID. This can be obtained by calling customerAddressesWithCompletionBlock:(NSArrayNSErrorBlock)completionBlock;
 */
- (void)deleteCustomerAddressWithID:(NSString *)addressID completionBlock:(NSErrorBlock)completionBlock;


/**
 *  Get a customer profile
 *
 *  Relates to:{site}/customers/current
 */
- (void)customerProfileWithCompletionBlock:(NSDictionaryNSErrorBlock)completionBlock;


/**
 *  Updates customer password.
 *
 *  Relates to: {site}/customers/current/password
 *
 *  @param newPassword
 *  @param oldPassword
 */
- (void)updateCustomerPasswordWithNewPassword:(NSString *)newPassword oldPassword:(NSString *)oldPassword completionBlock:(NSErrorBlock)completionBlock;

/**
 *  Updates customer login.
 *
 *  Relates to: {site}/customers/current/login
 *
 *  @param newLogin
 *  @param password
 */

- (void)updateCustomerLoginWithNewLogin:(NSString *)newLogin password:(NSString *)password completionBlock:(NSErrorBlock)completionBlock;


/**
 *  Get All Customer Payment Information
 *
 *  Relates to: {site}/customers/current/paymentinfos
 */
- (void)customerPaymentInfosWithCompletionBlock:(NSArrayNSErrorBlock)completionBlock;


/**
 *  Get a particular set of payment information
 *
 *  Relates to: {site}/customers/current/paymentinfos/{id}
 *
 *  @param paymentInfoID the ID of the payment information required
 */
- (void)customerPaymentInfoWithID:(NSString *)paymentInfoID completionBlock:(NSDictionaryNSErrorBlock)completionBlock;


/**
 *  Delete payment information
 *
 *  Relates to: {site}/customers/current/paymentinfos/{id}
 *
 *  @param paymentInfoID the ID of the payment information to delete
 */
- (void)deleteCustomerPaymentInfoWithID:(NSString *)paymentInfoID completionBlock:(NSErrorBlock)completionBlock;


/**
 *  Update payment information
 *
 *  Relates to:{site}/customers/current/paymentinfos/{id}
 *
 *  @param accountHolderName
 *  @param cardNumber
 *  @param cardType
 *  @param expiryMonth
 *  @param expiryYear
 *  @param shouldSave Set YES to save this information on the server
 *  @param isDefaultPaymentInfo Set YES to set as default payment information
 */
- (void)updateCustomerPaymentInfoWithAccountHolderName:(NSString *)accountHolderName
                                            cardNumber:(NSString *)cardNumber
                                              cardType:(NSString *)cardType
                                           expiryMonth:(NSString *)expiryMonth
                                            expiryYear:(NSString *)expiryYear
                                                 saved:(BOOL) shouldSave
                                    defaultPaymentInfo:(BOOL) isDefaultPaymentInfo
                                         paymentInfoID:(NSString *)paymentInfoID
                                       completionBlock:(NSErrorBlock)completionBlock;


/**
 *  Update a customer payment/billing address using a paymentInfoID
 *
 *  Relates to: {site}/customers/current/paymentinfos/{id}/address
 *
 *  @param firstName
 *  @param lastName
 *  @param titleCode
 *  @param addressLine1
 *  @param addressLine2
 *  @param town
 *  @param postCode
 *  @param countryISOCode
 *  @param isDefaultPaymentInfo Set this address as thed default
 *  @param paymentInfoID The payment info ID this relates to.
 */
- (void)updateCustomerPaymentInfoBillingAddresssWithFirstName:(NSString *)firstName
                                                     lastName:(NSString *)lastName
                                                    titleCode:(NSString *)titleCode
                                                 addressLine1:(NSString *)addressLine1
                                                 addressLine2:(NSString *)addressLine2
                                                         town:(NSString *)town
                                                     postCode:(NSString *)postCode
                                               countryISOCode:(NSString *)countryISOCode
                                           defaultPaymentInfo:(BOOL) isDefaultPaymentInfo
                                                paymentInfoID:(NSString *)paymentInfoID
                                              completionBlock:(NSErrorBlock)completionBlock;

/** @name Getting Other Data */


/**
 *  Get supported languages.
 *
 *  Relates to: {site}/languages
 */
- (void)languagesWithCompletionBlock:(NSArrayNSErrorBlock)completionBlock;


/**
 *  Get supported currencies.
 *
 *  Relates to:{site}/currencies
 */
- (void)currenciesWithCompletionBlock:(NSArrayNSErrorBlock)completionBlock;


/**
 *  Get support country codes.
 *
 *  Relates to:{site}/deliverycountries
 */
- (void)countriesWithCompletionBlock:(NSArrayNSErrorBlock)completionBlock;


/**
 *  Get supported card types.
 *
 *  Relates to:{site}/cardtypes
 */
- (void)cardTypesWithCompletionBlock:(NSArrayNSErrorBlock)completionBlock;


/**
 *  Get supported titles.
 *
 *  Relates to: {site}/titles
 */
- (void)titlesWithCompletionBlock:(NSArrayNSErrorBlock)completionBlock;

/** Store Locator **/


/**
 * Get the stores at a specific location.
 * Relates to: {site}/stores/
 * @param location latitiude, longitude and accuracy
 * @param radius in meters
 */
- (void)storesAtLocation:(CLLocation *)location withCurrentPage:(NSInteger) currentPage  radius:(float)radius completionBlock:(NSDictionaryNSErrorBlock)completionBlock;


/**
 * Get the stores using a free text search
 * Relates to: {site}/stores/
 * @param query query string
 */
- (void)storesWithQueryString:(NSString *)query withCurrentPage:(NSInteger) currentPage completionBlock:(NSDictionaryNSErrorBlock)completionBlock;


/**
 * Link to for forgotten password
 * No param
 */
- (void)forgotPasswordWithLogin:(NSString *)login completionBlock:(NSErrorBlock)completionBlock;


@end
