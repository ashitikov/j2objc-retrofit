#import "AMOkHttpCall.h"
#import "AFNetworking.h"
#import "Okhttp3Request+NSUrlRequestWrapper.h"
#import "Response.h"
#import "okhttp3/ResponseBody.h"
#import "okhttp3/Protocol.h"
#import "AMDefaultUrlResponseSerialization.h"
#import "java/io/IOException.h"
#import "java/lang/IllegalStateException.h"
#import "okhttp3/Callback.h"
#import "retrofit2/okhttp3/Response.h"

#import "AMHttpSessionManager.h"


@interface AMOkHttpCall ()

@property (strong, nonatomic) Okhttp3Request *request;
@property (strong, nonatomic) Okhttp3Response *response;

@property (strong, nonatomic) NSURLSessionDataTask *dataTask;

@property (nonatomic) dispatch_semaphore_t semaphore_token;

@property (assign, nonatomic) BOOL isExecuted;
@property (assign, nonatomic) BOOL isCanceled;

@end

@implementation AMOkHttpCall

- (instancetype)initWithOkHttpRequest:(nonnull Okhttp3Request *)request
{
    self = [super init];
    if (self)
    {
        self.request = request;
        
        [self createSemaphore];
    }
    return self;
}

- (Okhttp3Request *)request
{
    return _request;
}

- (Okhttp3Response *)execute
{
    @synchronized (self) {
        [self configureSyncDataTask];
        
        if (self.isExecuted)
        {
            @throw [[JavaLangIllegalStateException alloc] initWithNSString:@"Already Executed"];
        }
        self.isExecuted = YES;
    }
    
    @try {
        [self.dataTask resume];
        
        dispatch_semaphore_wait(self.semaphore_token, DISPATCH_TIME_FOREVER);
        
        if (self.response == nil)
        {
            
            NSString *canceled =  [[NSBundle mainBundle] localizedStringForKey:@"Internet is not avaliable" value:@"" table:nil];
            @throw [[JavaIoIOException alloc] initWithNSString:canceled];
        }
    } @catch (JavaIoIOException *exception) {
        @throw exception;
    }
    
    return self.response;
}

- (void)enqueueWithOkhttp3Callback:(id<Okhttp3Callback>)responseCallback
{
    [self configureAsyncDataTask:responseCallback];
    
    [self.dataTask resume];
}

- (void)cancel
{
    [self.dataTask cancel];
    
    self.isCanceled = YES;
}

- (jboolean)isExecuted
{
    return _isExecuted;
}

- (jboolean)isCanceled
{
    return _isCanceled;
}

- (id<Okhttp3Call>)clone
{
    return [[AMOkHttpCall alloc] initWithOkHttpRequest:self.request];
}

- (id)copyWithZone:(NSZone *)zone
{
    return nil;
}

- (void)createSemaphore {
    self.semaphore_token = dispatch_semaphore_create(0);
}

- (void)configureDataTaskWithCompletion:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completion
{
    NSURLRequest *request = [self.request getUrlRequest];
    
    self.dataTask = [[AMHttpSessionManager defaultManager] dataTaskWithRequest:request
                                                             completionHandler:completion];
}

- (void)configureSyncDataTask {
    __weak typeof(self) weakSelf = self;
    
    [self configureDataTaskWithCompletion:^(NSURLResponse *response, id responseObject, NSError *error) {
        weakSelf.response = [weakSelf buildResponseFromResponseBuilder:responseObject];
        
        dispatch_semaphore_signal(weakSelf.semaphore_token);
    }];
}

- (void)configureAsyncDataTask:(id<Okhttp3Callback>)responseCallback
{
    __weak typeof(self) weakSelf = self;
    
    [self configureDataTaskWithCompletion:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [responseCallback onFailureWithOkhttp3Call:weakSelf
                                 withJavaIoIOException:[JavaIoIOException new]];
        }
        else
        {
            [responseCallback onResponseWithOkhttp3Call:weakSelf
                                    withOkhttp3Response:[weakSelf buildResponseFromResponseBuilder:responseObject]];
        }
    }];
}

- (Okhttp3Response *)buildResponseFromResponseBuilder:(Okhttp3Response_Builder *)builder {
    [builder requestWithOkhttp3Request:self.request];
    
    return [builder build];
}


@end
