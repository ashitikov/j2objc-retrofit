#import "AMHttpSessionManager.h"

#import "AMDefaultUrlResponseSerialization.h"

@implementation AMHttpSessionManager

+ (instancetype)defaultManager {
    static AMHttpSessionManager *manager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (instancetype)init
{
    self = [self initWithDefaultSessionConfiguration];
    
    if (self) {
        [self configureDefault];
    }
    
    return self;
}

- (instancetype)initWithDefaultSessionConfiguration
{
    return [self initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
}

- (void)configureDefault {
    self.responseSerializer = [[AMDefaultUrlResponseSerialization alloc] init];
}

@end
