//
//  CHDraggingCoordinator.m
//  ChatHeads
//
//  Created by Matthias Hochgatterer on 4/19/13.
//  Copyright (c) 2013 Matthias Hochgatterer. All rights reserved.
//

#import "CHDraggingCoordinator.h"
#import <QuartzCore/QuartzCore.h>
#import "CHDraggableView.h"



@interface CHDraggingCoordinator ()

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) NSMutableDictionary *edgePointDictionary;;
@property (nonatomic, assign) CGRect draggableViewBounds;
@property (nonatomic, strong) UINavigationController *presentedNavigationController;
@property (nonatomic, assign) CHDraggableView *selectedFaceView;

@end

@implementation CHDraggingCoordinator

- (id)initWithWindow:(UIWindow *)window draggableViewBounds:(CGRect)bounds
{
    self = [super init];
    if (self) {
        _window = window;
        _draggableViewBounds = bounds;
        _state = CHInteractionStateNormal;
        _edgePointDictionary = [NSMutableDictionary dictionary];
        self.backgroundView = [[UIView alloc] initWithFrame:[self.window bounds]];
        [self backgroundViewToNormalStyle];
    }
    return self;
}

-(void)backgroundViewToNormalStyle{
    
    self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.5f];
    self.backgroundView.alpha = 0.0f;
    [self.backgroundView setUserInteractionEnabled:YES];
}

#pragma mark - Geometry

- (CGRect)_dropArea
{
    return CGRectInset([self.window.screen applicationFrame], -(int)(CGRectGetWidth(_draggableViewBounds)/6), 0);
}

- (CGRect)_conversationArea
{
    CGRect slice;
    CGRect remainder;
    CGRectDivide([self.window.screen applicationFrame], &slice, &remainder, CGRectGetHeight(CGRectInset(_draggableViewBounds, 0, -30)), CGRectMinYEdge);
    
    return slice;
}
- (CGRect)_navigationControllerFrame
{
    CGRect slice;
    CGRect remainder;
    CGRectDivide([self.window.screen applicationFrame], &slice, &remainder, CGRectGetMaxY([self _conversationArea]), CGRectMinYEdge);
    return remainder;
}


- (CGPoint)_destinationEdgeForReleasePointInCurrentState:(CGPoint)releasePoint
{
    /*if (_state == CHInteractionStateConversation) {
        return CGRectMinYEdge;
    } else if(_state == CHInteractionStateNormal) {
        return releasePoint.x < CGRectGetMidX([self _dropArea]) ? CGRectMinXEdge : CGRectMaxXEdge;
    }*/
    CGPoint location =[self.selectedFaceView.mapView  convertCoordinate:[self.selectedFaceView.friend coordinate] toPointToView:self.selectedFaceView.mapView];
    
    if (CGPointEqualToPoint(location, CGPointZero)) {
        return location;
    }
    NSAssert(false, @"no coordinate for this view");
    return location; // dont know why this needs to be here..
}

- (CGPoint)_destinationPointForReleasePoint:(CGPoint)releasePoint
{
    //CGRect dropArea = [self _dropArea];
    
    //CGFloat midXDragView = CGRectGetMidX(_draggableViewBounds);
    CGPoint destinationEdge = [self _destinationEdgeForReleasePointInCurrentState:releasePoint];
    /*CGFloat destinationY;
    CGFloat destinationX;
 
    CGFloat topYConstraint = CGRectGetMinY(dropArea) + CGRectGetMidY(_draggableViewBounds);
    CGFloat bottomYConstraint = CGRectGetMaxY(dropArea) - CGRectGetMidY(_draggableViewBounds);
    if (releasePoint.y < topYConstraint) { // Align ChatHead vertically
        destinationY = topYConstraint;
    }else if (releasePoint.y > bottomYConstraint) {
        destinationY = bottomYConstraint;
    }else {
        destinationY = releasePoint.y;
    }

    if (self.snappingEdge == CHSnappingEdgeBoth){   //ChatHead will snap to both edges
        if (destinationEdge == CGRectMinXEdge) {
            destinationX = CGRectGetMinX(dropArea) + midXDragView;
        } else {
            destinationX = CGRectGetMaxX(dropArea) - midXDragView;
        }
        
    }else if(self.snappingEdge == CHSnappingEdgeLeft){  //ChatHead will snap only to left edge
        destinationX = CGRectGetMinX(dropArea) + midXDragView;
        
    }else{  //ChatHead will snap only to right edge
        destinationX = CGRectGetMaxX(dropArea) - midXDragView;
    }
    */
    return destinationEdge;
}

#pragma mark - Dragging

- (void)draggableViewHold:(CHDraggableView *)view
{
    //if (!self.selectedFaceView) {
        self.selectedFaceView = view;
    //}
}

- (void)draggableView:(CHDraggableView *)view didMoveToPoint:(CGPoint)point
{
    if (_state == CHInteractionStateConversation) {
        if (_presentedNavigationController) {
            [self _dismissPresentedNavigationController];
        }
    }
}

- (void)draggableViewReleased:(CHDraggableView *)view
{
    if (_state == CHInteractionStateNormal) {
        self.selectedFaceView = view;
        [self _animateViewToEdges:view];
        self.selectedFaceView = nil;
    } else if(_state == CHInteractionStateConversation) {
        self.selectedFaceView = view;
        
        [self _animateViewToConversationArea:view];
        [self _presentViewControllerForDraggableView:view];
        
    }
}

- (void)draggableViewTouched:(CHDraggableView *)view
{
    self.selectedFaceView=view;
    if (_state == CHInteractionStateNormal) {
        _state = CHInteractionStateConversation;
        self.selectedFaceView.mapView.zoomEnabled = NO;
        self.selectedFaceView.mapView.scrollEnabled = NO;
        self.selectedFaceView.mapView.userInteractionEnabled = NO;
        [self _animateViewToConversationArea:view];
        
        [self _presentViewControllerForDraggableView:view];
        
    } else if(_state == CHInteractionStateConversation) {
        _state = CHInteractionStateNormal;
        //NSValue *knownEdgePoint = [_edgePointDictionary objectForKey:@(view.tag)];
        self.selectedFaceView.mapView.zoomEnabled = YES;
        self.selectedFaceView.mapView.scrollEnabled = YES;
        self.selectedFaceView.mapView.userInteractionEnabled = YES;
        CGPoint location =[self.selectedFaceView.mapView  convertCoordinate:[self.selectedFaceView.friend coordinate] toPointToView:self.selectedFaceView.mapView];
        NSValue *knownEdgePoint = [NSValue valueWithCGPoint:location];
    
        
        if (knownEdgePoint) {
            [self _animateView:view toEdgePoint:[knownEdgePoint CGPointValue]];
        } else {
            [self _animateViewToEdges:view];
        }
        [self _dismissPresentedNavigationController];
        self.selectedFaceView = nil;
    }
}

#pragma mark - Alignment

- (void)draggableViewNeedsAlignment:(CHDraggableView *)view
{
    NSLog(@"Align view");
    [self _animateViewToEdges:view];
}

#pragma mark Dragging Helper

- (void)_animateViewToEdges:(CHDraggableView *)view
{
    CGPoint destinationPoint =[view.mapView  convertCoordinate:[view.friend coordinate] toPointToView:view.mapView];
    
    [self _animateView:view toEdgePoint:destinationPoint];
}

- (void)_animateView:(CHDraggableView *)view toEdgePoint:(CGPoint)point
{
    [_edgePointDictionary setObject:[NSValue valueWithCGPoint:point] forKey:@(view.tag)];
    

    [view snapViewCenterToPoint:point ];
 
}

- (void)_animateViewToConversationArea:(CHDraggableView *)view
{
    CGRect conversationArea = [self _conversationArea];
    //CGPoint center = CGPointMake(CGRectGetMidX(conversationArea), CGRectGetMidY(conversationArea));
    CGPoint center = CGPointMake(CGRectGetMidX(conversationArea), CGRectGetMaxY(conversationArea)-view.frame.size.height/2);
    int64_t delayInSeconds = 0.6;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.placeholderCoordinate = self.selectedFaceView.friend.coordinate;
         self.selectedFaceView.friend.coordinate = [self.selectedFaceView.mapView convertPoint:center toCoordinateFromView:self.selectedFaceView.mapView];
            });
   
    
    [view snapViewCenterToPoint:center ];
}

#pragma mark - View Controller Handling


- (CGRect)_navigationControllerHiddenFrame
{
    return CGRectMake(CGRectGetMidX([self _conversationArea]), CGRectGetMaxY([self _conversationArea]), 0, 0);
}

- (void)_presentViewControllerForDraggableView:(CHDraggableView *)draggableView
{
    UIViewController *viewController = [_delegate draggingCoordinator:self viewControllerForDraggableView:draggableView];
    
    self.selectedFaceView = draggableView;
    
    _presentedNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    _presentedNavigationController.view.layer.cornerRadius = 3;
    _presentedNavigationController.view.layer.masksToBounds = YES;
    _presentedNavigationController.view.layer.anchorPoint = CGPointMake(0.5f, 0);
    _presentedNavigationController.view.frame = [self _navigationControllerFrame];
    _presentedNavigationController.view.transform = CGAffineTransformMakeScale(0, 0);
    
    [self.window insertSubview:_presentedNavigationController.view belowSubview:draggableView];
    [self _unhidePresentedNavigationControllerCompletion:^{}];
}

- (void)_dismissPresentedNavigationController
{
    UINavigationController *reference = _presentedNavigationController;
    [self _hidePresentedNavigationControllerCompletion:^{
        [reference.view removeFromSuperview];
        [self.selectedFaceView setDragState:MKAnnotationViewDragStateEnding animated:NO];
    }];
    _presentedNavigationController = nil;
}

- (void)dismissPresentedNavigationController
{
    
   // NSValue *knownEdgePoint = [_edgePointDictionary objectForKey:@(self.selectedFaceView.tag)];
   _state = CHInteractionStateNormal;
    
    
   
    NSValue *knownEdgePoint;
    
    CGPoint location =[self.selectedFaceView.mapView  convertCoordinate:self.placeholderCoordinate toPointToView:self.selectedFaceView.mapView];
    
    knownEdgePoint = [NSValue valueWithCGPoint:location];
    
    
    
    
    
    if (knownEdgePoint) {
        [self _animateView:self.selectedFaceView toEdgePoint:[knownEdgePoint CGPointValue]];
    } else {
        [self _animateViewToEdges:self.selectedFaceView];
    }

    [self _dismissPresentedNavigationController];
    
    if (self.placeholderCoordinate.latitude !=0.0) {
        self.selectedFaceView.friend.coordinate = self.placeholderCoordinate;
    }
    
    self.selectedFaceView = nil;
}

- (void)_unhidePresentedNavigationControllerCompletion:(void(^)())completionBlock
{
    CGAffineTransform transformStep1 = CGAffineTransformMakeScale(1.1f, 1.1f);
    CGAffineTransform transformStep2 = CGAffineTransformMakeScale(1, 1);
    
    
    [self backgroundViewToNormalStyle];
    [self.window insertSubview:self.backgroundView belowSubview:_presentedNavigationController.view];
    
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _presentedNavigationController.view.layer.affineTransform = transformStep1;
        self.backgroundView.alpha = 1.0f;
    }completion:^(BOOL finished){
        if (finished) {
            [UIView animateWithDuration:0.3f animations:^{
                _presentedNavigationController.view.layer.affineTransform = transformStep2;
            }];
        }
    }];
}

- (void)_hidePresentedNavigationControllerCompletion:(void(^)())completionBlock
{
    UIView *viewToDisplay = self.backgroundView;
    [UIView animateWithDuration:0.3f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _presentedNavigationController.view.transform = CGAffineTransformMakeScale(0, 0);
        _presentedNavigationController.view.alpha = 0.0f;
        self.backgroundView.alpha = 0.0f;
    } completion:^(BOOL finished){
        if (finished) {
            [viewToDisplay removeFromSuperview];
            if (viewToDisplay == self.backgroundView) {
                [self backgroundViewToNormalStyle];
            }
            completionBlock();
        }
    }];
}

@end
