//
//  RMMarker.m
//  MapView
//
//  Created by David Bainbridge on 2/17/13.
//
//

#import "RMMarker.h"
#import "RMConfiguration.h"

@implementation RMMarker

@synthesize label;
@synthesize textForegroundColor;
@synthesize textBackgroundColor;

#define defaultMarkerAnchorPoint CGPointMake(0.5, 0.5)

#define kCachesPath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

+ (NSFont *)defaultFont
{
    return [NSFont systemFontOfSize:15];
}

// init
- (id)init
{
    if (!(self = [super init]))
        return nil;
    
    label = nil;
    textForegroundColor = [NSColor blackColor];
    textBackgroundColor = [NSColor clearColor];
    
    return self;
}

- (id)initWithNSImage:(NSImage *)image
{
    return [self initWithNSImage:image anchorPoint:defaultMarkerAnchorPoint];
}

- (id)initWithNSImage:(NSImage *)image anchorPoint:(CGPoint)_anchorPoint
{
    if (!(self = [self init]))
        return nil;
    
    self.contents = (id)[image CGImage];
//    self.contentsScale = image.scale;
    self.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    self.anchorPoint = _anchorPoint;
    
    self.masksToBounds = NO;
    self.label = nil;
    
    return self;
}

- (id)initWithMapBoxMarkerImage
{
    return [self initWithMapBoxMarkerImage:nil tintColor:nil size:RMMarkerMapBoxImageSizeMedium];
}

- (id)initWithMapBoxMarkerImage:(NSString *)symbolName
{
    return [self initWithMapBoxMarkerImage:symbolName tintColor:nil size:RMMarkerMapBoxImageSizeMedium];
}

- (id)initWithMapBoxMarkerImage:(NSString *)symbolName tintColor:(NSColor *)color
{
    return [self initWithMapBoxMarkerImage:symbolName tintColor:color size:RMMarkerMapBoxImageSizeMedium];
}

- (id)initWithMapBoxMarkerImage:(NSString *)symbolName tintColor:(NSColor *)color size:(RMMarkerMapBoxImageSize)size
{
    NSString *sizeString = nil;
    
    switch (size)
    {
        case RMMarkerMapBoxImageSizeSmall:
            sizeString = @"small";
            break;
            
        case RMMarkerMapBoxImageSizeMedium:
        default:
            sizeString = @"medium";
            break;
            
        case RMMarkerMapBoxImageSizeLarge:
            sizeString = @"large";
            break;
    }
    
    NSString *colorHex = nil;
    
    if (color)
    {
        CGFloat red, green, blue, alpha;
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
        colorHex = [NSString stringWithFormat:@"%02lx%02lx%02lx", (NSUInteger)(red * 255), (NSUInteger)(green * 255), (NSUInteger)(blue * 255)];
    }
    
    return [self initWithMapBoxMarkerImage:symbolName tintColorHex:colorHex sizeString:sizeString];
}

- (id)initWithMapBoxMarkerImage:(NSString *)symbolName tintColorHex:(NSString *)colorHex
{
    return [self initWithMapBoxMarkerImage:symbolName tintColorHex:colorHex sizeString:@"medium"];
}

- (id)initWithMapBoxMarkerImage:(NSString *)symbolName tintColorHex:(NSString *)colorHex sizeString:(NSString *)sizeString
{
    BOOL useRetina = ([[UIScreen mainScreen] scale] > 1.0);
    
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://a.tiles.mapbox.com/v3/marker/pin-%@%@%@%@.png",
                                            (sizeString ? [sizeString substringToIndex:1] : @"m"),
                                            (symbolName ? [@"-" stringByAppendingString:symbolName] : @"-star"),
                                            (colorHex   ? [@"+" stringByAppendingString:[colorHex stringByReplacingOccurrencesOfString:@"#" withString:@""]] : @"+ff0000"),
                                            (useRetina  ? @"@2x" : @"")]];
    
    NSImage *image = nil;
    
    NSString *cachePath = [NSString stringWithFormat:@"%@/%@", kCachesPath, [imageURL lastPathComponent]];
    
    if ((image = [NSImage imageWithData:[NSData dataWithContentsOfFile:cachePath]]) && image)
        return [self initWithNSImage:image];
    
    [[NSFileManager defaultManager] createFileAtPath:cachePath contents:[NSData brandedDataWithContentsOfURL:imageURL] attributes:nil];
    
    return [self initWithNSImage:[NSImage imageWithData:[NSData dataWithContentsOfFile:cachePath]]];
}

+ (void)clearCachedMapBoxMarkers
{
    for (NSString *filePath in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:kCachesPath error:nil])
        if ([[filePath lastPathComponent] hasPrefix:@"pin-"] && [[filePath lastPathComponent] hasSuffix:@".png"])
            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", kCachesPath, filePath] error:nil];
}

#pragma mark -

- (void)replaceNSImage:(NSImage *)image
{
    [self replaceNSImage:image anchorPoint:defaultMarkerAnchorPoint];
}

- (void)replaceNSImage:(NSImage *)image anchorPoint:(CGPoint)_anchorPoint
{
    self.contents = (id)[image CGImage];
    self.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    self.anchorPoint = _anchorPoint;
    
    self.masksToBounds = NO;
}

- (void)setLabel:(NSView *)aView
{
    if (label == aView)
        return;
    
    if (label != nil)
        [[label layer] removeFromSuperlayer];
    
    if (aView != nil)
    {
        label = aView;
        [self addSublayer:[label layer]];
    }
}

- (void)setTextBackgroundColor:(NSColor *)newTextBackgroundColor
{
    textBackgroundColor = newTextBackgroundColor;
#warning
//    self.label.backgroundColor = textBackgroundColor;
}

- (void)setTextForegroundColor:(NSColor *)newTextForegroundColor
{
    textForegroundColor = newTextForegroundColor;
    
    if ([self.label respondsToSelector:@selector(setTextColor:)])
        ((NSTextField *)self.label).textColor = textForegroundColor;
}

- (void)changeLabelUsingText:(NSString *)text
{
    CGPoint position = CGPointMake([self bounds].size.width / 2 - [text sizeWithFont:[RMMarker defaultFont]].width / 2, 4);
    [self changeLabelUsingText:text position:position font:[RMMarker defaultFont] foregroundColor:[self textForegroundColor] backgroundColor:[self textBackgroundColor]];
}

- (void)changeLabelUsingText:(NSString*)text position:(CGPoint)position
{
    [self changeLabelUsingText:text position:position font:[RMMarker defaultFont] foregroundColor:[self textForegroundColor] backgroundColor:[self textBackgroundColor]];
}

- (void)changeLabelUsingText:(NSString *)text font:(NSFont *)font foregroundColor:(NSColor *)textColor backgroundColor:(NSColor *)backgroundColor
{
    CGPoint position = CGPointMake([self bounds].size.width / 2 - [text sizeWithFont:font].width / 2, 4);
    [self setTextForegroundColor:textColor];
    [self setTextBackgroundColor:backgroundColor];
    [self changeLabelUsingText:text  position:position font:font foregroundColor:textColor backgroundColor:backgroundColor];
}

- (void)changeLabelUsingText:(NSString *)text position:(CGPoint)position font:(NSFont *)font foregroundColor:(NSColor *)textColor backgroundColor:(NSColor *)backgroundColor
{
    CGSize textSize = [text sizeWithFont:font];
    CGRect frame = CGRectMake(position.x, position.y, textSize.width+4, textSize.height+4);
    
    NSTextField *aLabel = [[NSTextField alloc] initWithFrame:frame];
    [self setTextForegroundColor:textColor];
    [self setTextBackgroundColor:backgroundColor];
//    [aLabel setNumberOfLines:0];
    [aLabel setAutoresizingMask:NSViewWidthSizable];
    [aLabel setBackgroundColor:backgroundColor];
    [aLabel setTextColor:textColor];
    [aLabel setFont:font];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [aLabel setAlignment:NSCenterTextAlignment];
#pragma clang diagnostic pop
    [aLabel setStringValue:text];
    
    [self setLabel:aLabel];
}

- (void)toggleLabel
{
    if (self.label == nil)
        return;
    
    if ([self.label isHidden])
        [self showLabel];
    else
        [self hideLabel];
}

- (void)showLabel
{
    if ([self.label isHidden])
    {
        // Using addSublayer will animate showing the label, whereas setHidden is not animated
        [self addSublayer:[self.label layer]];
        [self.label setHidden:NO];
    }
}

- (void)hideLabel
{
    if (![self.label isHidden])
    {
        // Using removeFromSuperlayer will animate hiding the label, whereas setHidden is not animated
        [[self.label layer] removeFromSuperlayer];
        [self.label setHidden:YES];
    }
}

@end
