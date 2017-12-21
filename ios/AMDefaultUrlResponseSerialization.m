#import "AMDefaultUrlResponseSerialization.h"
#import "okhttp3/ResponseBody.h"
#import "okhttp3/Request.h"
#import "okhttp3/Protocol.h"
#import "okhttp3/MediaType.h"

#import "retrofit2/okhttp3/Response.h"

#import "J2ObjC_source.h"


@interface AMDefaultUrlResponseSerialization ()

@end

@implementation AMDefaultUrlResponseSerialization

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Accept all content types by default
        self.acceptableContentTypes = nil;
    }
    return self;
}

- (Okhttp3Response_Builder *)responseObjectForResponse:(nullable NSURLResponse *)response
                                    data:(nullable NSData *)data
                                   error:(NSError * _Nullable __autoreleasing *)error NS_SWIFT_NOTHROW
{
    
    if (data) {
        NSURL *url = [response URL];
        NSLog(@"response data [%@]- %@", url.absoluteString, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }
    
    NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
    NSDictionary *headers = urlResponse.allHeaderFields;
    NSInteger code = urlResponse.statusCode;
    
    Okhttp3Response_Builder *builder = [[Okhttp3Response_Builder alloc] init];
    
    [builder codeWithInt:(int)code];

    // TODO FIXME Get protocol from connection
    [builder protocolWithOkhttp3Protocol:Okhttp3Protocol_get_HTTP_1_1()];
    
    [headers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [builder addHeaderWithNSString:key withNSString:obj];
    }];
    
    @try {
    IOSByteArray *bodyByteArray = [IOSByteArray arrayWithNSData:data];
    
        Okhttp3ResponseBody *body = [Okhttp3ResponseBody createWithOkhttp3MediaType:[Okhttp3MediaType parseWithNSString:headers[@"Content-Type"] == nil ? @"" : headers[@"Content-Type"]]
                                                                  withByteArray:bodyByteArray];
        
        
    
    [builder bodyWithOkhttp3ResponseBody:body];
    } @catch (NSException *e) {
        *error = [NSError errorWithDomain:NSURLErrorDomain
                                     code:NSURLErrorCannotParseResponse userInfo:nil];
        
        return nil;
    }
    
    return builder;
}

@end
