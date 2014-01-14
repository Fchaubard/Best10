//
//  AvatarView.m
//
//  Created by Matthias Hochgatterer on 21.11.12.
//  Copyright (c) 2012 Matthias Hochgatterer. All rights reserved.
//


#import "CHAvatarView1.h"
#import <QuartzCore/QuartzCore.h>

@implementation CHAvatarView1

double defaultTouchSize;
bool animating;
double thumbSize;
double vspacer = 10.0;
CABasicAnimation *scaleAnim;

typedef enum {
    NotTouching = 0,
    MessingAround = 1,
    AddingAFriend = 2,
    HidingFromAFriend = 3
} UserTouchState;


UserTouchState touchState;

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0,2);
        self.layer.shadowRadius = 2;
        self.layer.shadowOpacity = 0.7f;
        self.backgroundColor = [UIColor clearColor];
        
        
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
      andAnnotation:(id<MKAnnotation>)thisAnnotation withReuseId:(NSString *)string
{
    self = [super initWithAnnotation:thisAnnotation reuseIdentifier:string];
    if (self) {
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0,2);
        self.layer.shadowRadius = 2;
        self.layer.shadowOpacity = 0.7f;
        self.backgroundColor = [UIColor clearColor];
        
        [self setFrame:frame];
        self.annotation = (Friend *)thisAnnotation;
        // Initialization code
        _recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(handleGesture)];
        defaultTouchSize = 0.5;
        
        
        
        
       
        [_recognizer setDelegate:self];
        
        
        /*self.name = [[UILabel alloc] init];
        self.name.text = [self.annotation title];
        self.name.textAlignment=NSTextAlignmentCenter;
        [self.name sizeToFit];*/
        
        self.activity = [[UILabel alloc] init];
        self.activity.text = [NSString stringWithFormat:@"%@: aads",[(Friend *)self.annotation status]];
        
        self.activity.textAlignment=NSTextAlignmentCenter;
        self.activity.backgroundColor = [UIColor colorWithWhite:0.95 alpha:0.9];
        self.activity.layer.cornerRadius = 0.5;
        //self.status.shadowOffset = CGSizeMake(0,3);
        //self.status.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        //[self.status sizeToFit];
        
        
        
        [self setImage:[UIImage imageNamed:@"avatar.png"]];
        self.frame = CGRectMake(0, 0, 30, 30);
        [self addGestureRecognizer:_recognizer];
        thumbSize = 20;
        touchState = NotTouching;
        animating = false;
        self.activity.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y + 3*vspacer,self.activity.frame.size.width*5,20 );
        
        [self addSubview:self.activity];
        
        
    }
    return self;
}


- (IBAction)handleGesture{
    NSLog(@"asdfasdfa");
}




// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGRect b = self.bounds;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);

    CGPathRef circlePath = CGPathCreateWithEllipseInRect(b, 0);
    CGMutablePathRef inverseCirclePath = CGPathCreateMutableCopy(circlePath);
    CGPathAddRect(inverseCirclePath, nil, CGRectInfinite);
    
    CGContextSaveGState(ctx); {
        CGContextBeginPath(ctx);
        CGContextAddPath(ctx, circlePath);
        CGContextClip(ctx);
        [_avatarImage drawInRect:b];
    } CGContextRestoreGState(ctx);
    
    CGContextSaveGState(ctx); {
        CGContextBeginPath(ctx);
        CGContextAddPath(ctx, circlePath);
        CGContextClip(ctx);
        
        CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 3.0f, [UIColor colorWithRed:0.994 green:0.989 blue:1.000 alpha:1.0f].CGColor);
        
        CGContextBeginPath(ctx);
        CGContextAddPath(ctx, inverseCirclePath);
        CGContextEOFillPath(ctx);
    } CGContextRestoreGState(ctx);
    
    CGPathRelease(circlePath);
    CGPathRelease(inverseCirclePath);
    
    CGContextRestoreGState(ctx);
}

// mapView resizing stuff

typedef struct {
    CLLocationDegrees top;
    CLLocationDegrees bottom;
} MKLatitudeEdgedSpan;

typedef struct {
    CLLocationDegrees left;
    CLLocationDegrees right;
} MKLongitudeEdgedSpan;

typedef struct {
    MKLatitudeEdgedSpan latitude;
    MKLongitudeEdgedSpan longitude;
} MKEdgedRegion;

MKEdgedRegion MKEdgedRegionFromCoordinateRegion(MKCoordinateRegion region) {
    MKEdgedRegion edgedRegion;
    
    float latitude = region.center.latitude;
    float longitude = region.center.longitude;
    float latitudeDelta = region.span.latitudeDelta;
    float longitudeDelta = region.span.longitudeDelta;
    
    edgedRegion.longitude.left = longitude - longitudeDelta / 2;
    edgedRegion.longitude.right = longitude + longitudeDelta / 2;
    edgedRegion.latitude.top = latitude + latitudeDelta / 2;
    edgedRegion.latitude.bottom = latitude - latitudeDelta / 2;
    
    return edgedRegion;
}
@end
