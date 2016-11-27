// From http://zathras.de/angelweb/blog-removing-transparency-from-nsimage.htm
// Slightly modified.

#import <Cocoa/Cocoa.h>

@interface NSImage (UKRemoveTransparentAreas)

- (NSImage *)trimming;

@end
