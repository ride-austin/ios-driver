#import "UIImage+valueData.h"

@implementation UIImage (valueData)

-(id)valueData {
    if ([self isKindOfClass:[UIImage class]]) {
        return self;
    }
    return nil;
}
@end
