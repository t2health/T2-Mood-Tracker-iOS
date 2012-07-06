//
//  Error.h
//  VAS002
//
//  Created by Hasan Edain on 1/21/11.
//  Copyright 2011 GDIT. All rights reserved.
//

@interface Error : NSObject {

}

+ (void)showErrorWithString:(NSString *)message withError:(NSError *)error;
+ (void)showErrorByAppendingString:(NSString *)message withError:(NSError *)error;

@end
