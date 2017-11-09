/**
 *  Copyright 2017 Nest Labs Inc. All Rights Reserved.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

#import <Foundation/Foundation.h>
#import "NestAuthManager.h"
#import "RESTManager.h"
#import "Constants.h"

@interface RESTManager ()

@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSString *redirectURL;

@end

@implementation RESTManager

/**
 * Creates or retrieves the shared REST manager.
 * @return The singleton shared REST manager
 */
+ (RESTManager *)sharedManager {
    static dispatch_once_t once;
    static RESTManager *instance;
    
    dispatch_once(&once, ^{
        instance = [[RESTManager alloc] init];
    });
    
    return instance;
}

/**
 * Get the endpoint for the Nest API.
 * @return The root endpoint that forms the base of all Nest API requests.
 */
- (NSString *)endpointURL
{
    NSString *endpoint = [[NSUserDefaults standardUserDefaults] valueForKey:@"endpointURL"];
    if (endpoint) {
        return [NSString stringWithFormat:@"%@", endpoint];
    } else {
        NSLog(@"Missing the API Endpoint");
        return nil;
    }
}

/**
 * Set the root endpoint.
 * @param rootURL The root endpoint you wish to write to NSUserdefaults.
 */
- (void)setRootEndpoint:(NSString *)rootURL
{
    [[NSUserDefaults standardUserDefaults] setObject:rootURL forKey:@"rootURL"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark REST methods

/**
 * Create an HTTP request.
 * @param type The type of request, only GET and PUT is supported.
 * @param endpoint The Nest API endpoint to call.
 * @param data The key-value pairs to write to the Nest API for PUT calls, nil if a GET call
 */
- (NSMutableURLRequest *)createRequest:(NSString *)type
                           forEndpoint:(NSString *)endpoint
                              withData:(NSData *)data
{

    NSString *authBearer = [NSString stringWithFormat:@"Bearer %@",
                            [[NestAuthManager sharedManager] accessToken]];
    
    // Use this print out the token if you need it
    //NSLog(@"Token: %@", authBearer);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setHTTPMethod:type];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:authBearer forHTTPHeaderField:@"Authorization"];
    [request setURL:[NSURL URLWithString:endpoint]];
    NSLog(@"endpoint = %@, authBearer = %@", endpoint, authBearer);
    if (data) {
        [request setHTTPBody:data];
    }
    
    return request;
}


/**
 * Perform a GET (read) request.
 * @param endpoint The Nest API endpoint to call.
 * @param success Block to call after a successful response.
 * @param redirect Block to call after a redirect response.
 * @param failure Block to call after a failure response.
 */
- (void)getData:(NSString *)endpoint
        success:(void (^)(NSDictionary *response))success
       redirect:(void (^)(NSHTTPURLResponse *responseURL))redirect
        failure:(void (^)(NSError* error))failure {
    
    // Build the HTTP request
    NSString *targetURL = [NSString stringWithFormat:@"%@/%@", NestAPIEndpoint, endpoint];
    NSLog(@"targetURL = %@",targetURL);
    NSMutableURLRequest *request = [self createRequest:@"GET"
                                           forEndpoint:targetURL
                                              withData:nil];
    
    // Assign the session to the main queue so the call happens immediately
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    
    [[session dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
NSLog(@"data = %@, response = %@, error %@", data, response, error);
          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
          NSLog(@"RESTManager Response Status Code: %ld", (long)[httpResponse statusCode]);
          
          if ((long)[httpResponse statusCode] == 401 || (long)[httpResponse statusCode] == 307) {
              self.redirectURL = [NSString stringWithFormat:@"%@", [httpResponse URL]];
              NSLog(@"self.redirectURL %@", self.redirectURL);
              // Check if a returned 401 is a true 401, sometimes it's a redirect.
              //   See https://developers.nest.com/documentation/cloud/how-to-handle-redirects
              //   for more information.
              NSDictionary *responseHeaders = [httpResponse allHeaderFields];
              if ([[responseHeaders objectForKey:@"Content-Length"] isEqual: @"0"]) {
                  // This is a true 401
                  failure(error);
              }
              else {
                  // It's actually a redirect, so redirect!
                  redirect(httpResponse);
              }
              
          }
          else if (error)
              failure(error);
          else {
              NSDictionary *requestJSON = [NSJSONSerialization JSONObjectWithData:data
                                                                          options:kNilOptions
                                                                            error:nil];
              NSLog(@"redirect requestJSON %@", requestJSON);
              success(requestJSON);
          }

    }] resume];

}

/**
 * Perform a GET (read) request for a redirect (received by a previous GET request).
 * @param endpoint The Nest API endpoint to call.
 * @param success Block to call after a successful response.
 * @param failure Block to call after a failure response.
 */
- (void)getDataRedirect:(NSString *)endpoint
                success:(void (^)(NSDictionary *response))success
                failure:(void (^)(NSError* error))failure {
    
    // Build the HTTP request
    NSMutableURLRequest *request = [self createRequest:@"GET"
                                           forEndpoint:endpoint
                                              withData:nil];
    NSLog(@"endpoint = %@",endpoint);
    // Assign the session to the main queue so the call happens immediately
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
          
          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
          NSLog(@"RESTManager Redirect Response Status Code: %ld", (long)[httpResponse statusCode]);
          NSLog(@"data = %@, response = %@, error %@", data, response, error);
                    if (error)
              failure(error);
          else {
              NSDictionary *requestJSON = [NSJSONSerialization JSONObjectWithData:data
                                                                          options:kNilOptions
                                                                            error:nil];
              NSLog(@"getDataRedirect requestJSON %@", requestJSON);
              success(requestJSON);
          }
          
      }] resume];
    
}

/**
 * Perform a PUT (write) request.
 * @param endpoint The Nest API endpoint to write to.
 * @param values The key-value pairs to update the endpoint with.
 * @param success Block to call after a successful response.
 * @param redirect Block to call after a redirect response.
 * @param failure Block to call after a failure response.
 */
- (void)setData:(NSString *)endpoint
     withValues:(NSData *)putData
        success:(void (^)(NSDictionary *response))success
       redirect:(void (^)(NSHTTPURLResponse *responseURL))redirect
        failure:(void (^)(NSError* error))failure {
    
    // Build the HTTP request
    NSString *targetURL = [NSString stringWithFormat:@"%@/%@", NestAPIEndpoint, endpoint];
    NSLog(@"endpoint = %@",endpoint);
    NSMutableURLRequest *request = [self createRequest:@"PUT"
                                           forEndpoint:targetURL
                                              withData:putData];
    
    // Assign the session to the main queue so the call happens immediately
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
          
          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                    NSLog(@"getDataRedirect response %@", response);
          NSLog(@"RESTManager Response Status Code: %ld", (long)[httpResponse statusCode]);
          NSLog(@"data = %@, response = %@, error %@", data, response, error);
                    if ((long)[httpResponse statusCode] == 401 || (long)[httpResponse statusCode] == 307) {
              self.redirectURL = [NSString stringWithFormat:@"%@", [httpResponse URL]];
              
              // Check if a returned 401 is a true 401, sometimes it's a redirect.
              //   See https://developers.nest.com/documentation/cloud/how-to-handle-redirects
              //   for more information.
              
              NSDictionary *responseHeaders = [httpResponse allHeaderFields];
              if ([[responseHeaders objectForKey:@"Content-Length"] isEqual: @"0"]) {
                  // This is a true 401
                  failure(error);
              }
              else {
                  // It's actually a redirect, so redirect!
                  redirect(httpResponse);
              }

          }
          else if (error)
              failure(error);
          else {
              NSDictionary *requestJSON = [NSJSONSerialization JSONObjectWithData:data
                                                                          options:kNilOptions
                                                                            error:nil];
              success(requestJSON);
          }
          
      }] resume];
    
}

/**
 * Perform a PUT (write) request (received by a previous PUT request).
 * @param endpoint The Nest API endpoint to write to.
 * @param values The key-value pairs to update the endpoint with.
 * @param success Block to call after a successful response.
 * @param failure Block to call after a failure response.
 */
- (void)setDataRedirect:(NSString *)endpoint
             withValues:(NSData *)putData
                success:(void (^)(NSDictionary *response))success
                failure:(void (^)(NSError* error))failure {

    // Build the HTTP request
    NSMutableURLRequest *request = [self createRequest:@"PUT"
                                           forEndpoint:endpoint
                                              withData:putData];
    NSLog(@"endpoint = %@",endpoint);
    // Assign the session to the main queue so the call happens immediately
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
          
          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
          NSLog(@"RESTManager Redirect Response Status Code set: %ld", (long)[httpResponse statusCode]);
                    NSLog(@"data = %@, response = %@, error %@", data, response, error);
          if (error)
              failure(error);
          else {
              NSDictionary *requestJSON = [NSJSONSerialization JSONObjectWithData:data
                                                                          options:kNilOptions
                                                                            error:nil];
              NSLog(@"setDataRedirect response %@", response);
              success(requestJSON);
          }
          
      }] resume];
    
}


@end
