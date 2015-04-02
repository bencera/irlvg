#import "DeepCopy.h"

@implementation NSDictionary (DeepMutableCopy)

- (id)deepMutableCopy
{
	NSMutableDictionary* rv = [[NSMutableDictionary alloc] initWithCapacity:[self count]];
	NSArray* keys = [self allKeys];
    

	for (id k in keys)
	{
        if ([[self valueForKey:k] isKindOfClass:[NSNull class]]) {
            [rv setObject:@"" forKey:k];
        }
        else{
            [rv setObject:[[self valueForKey:k] deepMutableCopy] forKey:k];
        }
	}
    
	return rv;
}

@end

@implementation NSArray (DeepMutableCopy)

- (id)deepMutableCopy
{
	int n = [self count];
	NSMutableArray* rv = [[NSMutableArray alloc] initWithCapacity:n];
    
	for (int i = 0; i < n; i++)
	{
		[rv insertObject:[[self objectAtIndex:i] deepMutableCopy] atIndex:i];
	}
    
	return rv;
}

@end

@implementation NSString (DeepMutableCopy)

- (id)deepMutableCopy
{
	return [self mutableCopy];
}

@end

@implementation NSDate (DeepMutableCopy)

- (id)deepMutableCopy
{
	return [self copy];
}

@end

@implementation NSData (DeepMutableCopy)

- (id)deepMutableCopy
{
	return [self mutableCopy];
}

@end

@implementation NSNumber (DeepMutableCopy)

- (id)deepMutableCopy
{
	return [self copy];
}

@end