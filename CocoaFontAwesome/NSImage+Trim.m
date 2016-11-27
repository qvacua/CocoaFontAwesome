// From http://zathras.de/angelweb/blog-removing-transparency-from-nsimage.htm
// Slightly modified.

#import "NSImage+Trim.h"

@implementation NSImage (UKRemoveTransparentAreas)

- (NSImage *)trimming {
  NSRect oldRect = NSZeroRect;
  oldRect.size = [self size];
  NSRect outBoxValue;
  NSRect *outBox = &outBoxValue;

  *outBox = oldRect;

  [self lockFocus];

  // Cut off any empty rows at the bottom:
  for( int y = 0; y < oldRect.size.height; y++ )
  {
    for( int x = 0; x < oldRect.size.width; x++ )
    {
      NSColor*	theCol = NSReadPixel( NSMakePoint( x, y ) );
      if( [theCol alphaComponent] > 0.01 )
        goto bottomDone;
    }

    outBox->origin.y += 1;
    outBox->size.height -= 1;
  }

bottomDone:
  // Cut off any empty rows at the top:
  for( int y = oldRect.size.height -1; y >= 0; y-- )
  {
    for( int x = 0; x < oldRect.size.width; x++ )
    {
      NSColor*	theCol = NSReadPixel( NSMakePoint( x, y ) );
      if( [theCol alphaComponent] > 0.01 )
        goto topDone;
    }

    outBox->size.height -= 1;
  }

topDone:
  // Cut off any empty rows at the left:
  for( int x = 0; x < oldRect.size.width; x++ )
  {
    for( int y = 0; y < oldRect.size.height; y++ )
    {
      NSColor*	theCol = NSReadPixel( NSMakePoint( x, y ) );
      if( [theCol alphaComponent] > 0.01 )
        goto leftDone;
    }

    outBox->origin.x += 1;
    outBox->size.width -= 1;
  }

leftDone:
  // Cut off any empty rows at the right:
  for( int x = oldRect.size.width -1; x >= 0; x-- )
  {
    for( int y = 0; y < oldRect.size.height; y++ )
    {
      NSColor*	theCol = NSReadPixel( NSMakePoint( x, y ) );
      if( [theCol alphaComponent] > 0.01 )
        goto rightDone;
    }

    outBox->size.width -= 1;
  }

rightDone:
  [self unlockFocus];

  // Now create new image with that subsection:
  NSImage*	returnImg = [[NSImage alloc] initWithSize: outBox->size];
  NSRect		destBox = *outBox;
  destBox.origin = NSZeroPoint;

  [returnImg lockFocus];
  [self drawInRect: destBox fromRect: *outBox operation: NSCompositeCopy fraction: 1.0];
  [returnImg unlockFocus];

  return returnImg;
}

@end
