#import <Foundation/Foundation.h>
#import "BL/am/components/CoreComponents.h"
#import "BL/am/components/RetrofitComponent.h"
#import "okhttp3/Call.h"


@interface AMOkHttpCall : NSObject<Okhttp3Call>

- (instancetype)initWithOkHttpRequest:(nonnull Okhttp3Request *)request;

@end
