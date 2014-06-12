//
//  CHDraggableView.m
//  ChatHeads
//
//  Created by Matthias Hochgatterer on 4/19/13.
//  Copyright (c) 2013 Matthias Hochgatterer. All rights reserved.
//

#import "CHDraggableView.h"
#import <QuartzCore/QuartzCore.h>
#import "FXLabel.h"
#import "SKBounceAnimation.h"

@interface CHDraggableView ()

@property (nonatomic, assign) BOOL moved;
@property (nonatomic, assign) BOOL scaledDown;
@property (nonatomic, assign) CGPoint startTouchPoint;
@property (nonatomic, strong) FXLabel *activity;

@end

@implementation CHDraggableView

typedef enum {
    NotTouching = 0,
    MessingAround = 1,
    AddingAFriend = 2,
    HidingFromAFriend = 3
} UserTouchState;

double thumbSize;
double vspacer = 10.0;
CABasicAnimation *scaleAnim;


UserTouchState touchState;



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// ADDED METHOD
- (id)initWithFrame:(CGRect)frame
      andAnnotation:(id<MKAnnotation>)thisAnnotation withReuseId:(NSString *)string
{
    self = [super initWithAnnotation:thisAnnotation reuseIdentifier:string];
    if (self) {
        
        [self setFrame:frame];
        self.annotation = (Friend *)thisAnnotation;
        self.friend = self.annotation;
        // Initialization code
        self.coordinate = self.friend.coordinate;
        touchState = NotTouching;
        
        
        
        /*self.name = [[UILabel alloc] init];
         self.name.text = [self.annotation title];
         self.name.textAlignment=NSTextAlignmentCenter;
         [self.name sizeToFit];*/
    
        
        
    }
    return self;
}


- (void)snapViewCenterToPoint:(CGPoint)point 
{
    [self _snapViewCenterToPoint:point ];
}

#pragma mark - Override Touches

- (void)touchesBegan:(NSSet *)touches
{
    [self.superview bringSubviewToFront:self];
    self.mapView.zoomEnabled = NO;
    self.mapView.scrollEnabled =  NO;
    self.mapView.userInteractionEnabled = NO;
    
    //[super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    _startTouchPoint = [touch locationInView:self];
    
    // Simulate a touch with the scale animation
    [self _beginHoldAnimation];
    _scaledDown = YES;
    
    [_delegate draggableViewHold:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint movedPoint = [touch locationInView:self];
    
    CGFloat deltaX = movedPoint.x - _startTouchPoint.x;
    CGFloat deltaY = movedPoint.y - _startTouchPoint.y;
    [self _moveByDeltaX:deltaX deltaY:deltaY];
    if (_scaledDown) {
        [self _beginReleaseAnimation];
    }
    _scaledDown = NO;
    _moved = YES;
    
    [_delegate draggableView:self didMoveToPoint:movedPoint];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endUpTouch];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // When user for example accidentally drag notifications bar
    // with ChatHead we need to cancel touch
    [self endUpTouch];
    
}

- (void)endUpTouch
{
    if (_scaledDown) {
        [self _beginReleaseAnimation];
    }
    if (!_moved) {
        
        [_delegate draggableViewTouched:self];
    } else {
//        [_delegate draggableViewReleased:self];
        [_delegate draggableViewTouched:self];
    }
    
    _moved = NO;
}

#pragma mark - Animations
#define CGPointIntegral(point) CGPointMake((int)point.x, (int)point.y)

- (CGFloat)_distanceFromPoint:(CGPoint)point1 toPoint:(CGPoint)point2
{
    return hypotf(point1.x - point2.x, point1.y - point2.y);
}

- (CGFloat)_angleFromPoint:(CGPoint)point1 toPoint:(CGPoint)point2
{
    CGFloat x = point2.x - point1.x;
    CGFloat y = point2.y - point1.y;
    
    return atan2f(x,y);
}

- (void)_moveByDeltaX:(CGFloat)x deltaY:(CGFloat)y
{
    [UIView animateWithDuration:0.2f animations:^{
        CGPoint center = self.center;
        center.x += x;
        center.y += y;
        self.center = CGPointIntegral(center);
    }];
}

- (void)_beginHoldAnimation
{
    SKBounceAnimation *animation = [SKBounceAnimation animationWithKeyPath:@"transform"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95f, 0.95f, 1)];
    animation.duration = 0.01f;
    
    self.layer.transform = [animation.toValue CATransform3DValue];
    [self.layer addAnimation:animation forKey:nil];
}

- (void)_beginReleaseAnimation
{
    SKBounceAnimation *animation = [SKBounceAnimation animationWithKeyPath:@"transform"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = [NSValue valueWithCATransform3D:self.layer.transform];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)];
    animation.duration = 0.2f;
    
    self.layer.transform = [animation.toValue CATransform3DValue];
    [self.layer addAnimation:animation forKey:nil];
    
}

- (void)_snapViewCenterToPoint:(CGPoint)point
{
    CGPoint currentCenter = self.center;
    
    SKBounceAnimation *animation = [SKBounceAnimation animationWithKeyPath:@"position"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = [NSValue valueWithCGPoint:currentCenter];
    animation.toValue = [NSValue valueWithCGPoint:point];
    animation.duration = 0.9f;
    self.layer.position = point;
    [self.layer addAnimation:animation forKey:nil];
    
    
}

- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)annotationView
didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding)
    {
    
    }
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_delegate draggableViewNeedsAlignment:self];
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
