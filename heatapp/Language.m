//
//  Language.m
//  Heat Tool
//
//  Created by mkeefe on 9/10/11.
//  
//

#import "Language.h"

@implementation Language

static NSBundle *bundle = nil;

+ (void)initialize {
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString *current = [[languages objectAtIndex:0] retain];
    [self setLanguage:current];
}

+ (NSString *)getLanguage {
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    return [[languages objectAtIndex:0] retain];
}

+ (void)setLanguage:(NSString *)l {
    NSLog(@"preferredLang: %@", l);
    NSString *path = [[ NSBundle mainBundle] pathForResource:l ofType:@"lproj"];
    bundle = [[NSBundle bundleWithPath:path] retain];
}

+ (NSString *)getLocalizedString:(NSString *)key {
    return [bundle localizedStringForKey:key value:@"" table:nil];
}

@end