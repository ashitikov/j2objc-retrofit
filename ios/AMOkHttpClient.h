#import "OkHttpClient.h"
#include "J2ObjC_header.h"
#import "AMOkHttpCall.h"

@interface AMOkHttpClient : Okhttp3OkHttpClient

- (id<Okhttp3Call>)newCallWithOkhttp3Request:(Okhttp3Request *)request;

@end
