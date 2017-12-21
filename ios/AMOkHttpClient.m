#import "AMOkHttpClient.h"

#import "okhttp3/Request.h"

@implementation AMOkHttpClient

- (id<Okhttp3Call>)newCallWithOkhttp3Request:(Okhttp3Request *)request {
    return [[AMOkHttpCall alloc] initWithOkHttpRequest:request];
}



@end
