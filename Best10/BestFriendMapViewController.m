//
//  WolfMapViewController.m
//  WolfPack
//
//  Created by Francois Chaubard on 3/1/13.
//  Copyright (c) 2013 Francois Chaubard. All rights reserved.
//

#import "BestFriendMapViewController.h"
#import "Friend+MKAnnotation.h"
#import "SVProgressHUD.h"
#import "PopoverTVC.h"
#import "DHSidebarViewController.h"
#import "AppDelegate.h"


@interface BestFriendMapViewController ()



@end


@implementation BestFriendMapViewController




// if we are visible and our Model is (re)set, refetch from Core Data

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    if (!self.managedObjectContext)
    {
        self.managedObjectContext = [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyMapViewThatMOCChanged) name:NSManagedObjectContextObjectsDidChangeNotification object:self.managedObjectContext];

        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(glowChatButton)
                                                 name:@"MessageNotification"
                                               object:nil];
    [self viewCurrentLocation:self.viewCurrentLocationButton];
    [self notifyMapViewThatMOCChanged];
}



- (IBAction)refreshButtonClicked
{
    
    //[SVProgressHUD showWithStatus:@"Fetching your Hungry Wolves..."];
    
    //[self refreshWithoutHUD];
    [self performSelectorOnMainThread:@selector(reloadTheData) withObject:nil waitUntilDone:true];
    
}


- (void)reloadTheData
{
    
    [(AppDelegate *)[UIApplication sharedApplication].delegate refreshUserData];
   
}




#pragma mark - MSMapViewController

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    if (managedObjectContext) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Friend"];
        
        NSSortDescriptor *statusDescriptor = [[NSSortDescriptor alloc] initWithKey:@"userID" ascending:NO];
        
        [request setSortDescriptors:@[statusDescriptor]];
        
        request.predicate = nil;
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        [self performFetch];
    } else {
        
        self.fetchedResultsController = nil;
        
    }
    if (self.view.window) [self notifyMapViewThatMOCChanged];
    [self updateRegion:@1]; // always update region
    //  if (self.needUpdateRegion) [self updateRegion];
}


- (void)performFetch
{
    if (self.fetchedResultsController) {
        
        NSError *error;
        [self.fetchedResultsController performFetch:&error];
        if (error)
            NSLog(@"[%@ %@] %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription], [error localizedFailureReason]);
    }
    
    
}




- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
   // [self performSegueWithIdentifier:@"setPhoto:" sender:view];
    
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"setPhoto:"]) {
        if ([sender isKindOfClass:[MKAnnotationView class]]) {
            MKAnnotationView *aView = sender;
            if ([aView.annotation isKindOfClass:[Friend class]]) {
                Friend *friend = aView.annotation;
                if ([segue.destinationViewController respondsToSelector:@selector(setFriend:)]) {
                    [segue.destinationViewController performSelector:@selector(setPhoto:) withObject:photo];
                }
            }
        }
    }
}
*/

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    //[self refreshWithoutHUD];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.isFinishedLoading = true;
    //[self refreshWithoutHUD];
}


//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender


- (IBAction)viewWolfPack{
    [self updateRegion:@1];
}

- (IBAction)viewCurrentLocation:(UIButton *)sender{
    if (sender.tag==0) {
        sender.tag=1;
        [UIView animateWithDuration:0.5 animations:^{

            sender.backgroundColor = [UIColor colorWithRed:26.f/255.f green:188.f/255.f blue:156.f/255.f alpha:0.7];

        }];
        [self updateRegion:@1];
        
    }else if (sender.tag==1){
        sender.tag=0;

        [UIView animateWithDuration:0.5 animations:^{
            
            sender.backgroundColor = [UIColor colorWithRed:1.f/255.f green:88.f/255.f blue:206.f/255.f alpha:0.7];
            
        }];
        [self updateRegion:@2];
        
    }else{
        [NSException raise:@"can only be 1 or 2" format:@"string"];
    }
    
    
    
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


#pragma mark - popover
// this is selected on return from popover
-(void)selectedTableRow:(NSUInteger)rowNum
{
    
    /*[MyManagedObjectContext setCurrentAdjective:[self.possibleAdjectives objectAtIndex:(rowNum-1)]];
    [MyManagedObjectContext setCurrentAdjectiveNumber:rowNum];
    
    if (![MyManagedObjectContext isThisUserHungry]) {
        
        [self.adjectiveButton setTitle:[NSString stringWithFormat:@"Not %@",[MyManagedObjectContext currentAdjective]] forState:UIControlStateNormal];
    }else{
        [self.adjectiveButton setTitle:[NSString stringWithFormat:@"%@",[MyManagedObjectContext currentAdjective]] forState:UIControlStateNormal];
    }
    
    
    //update the input question
    if ([[MyManagedObjectContext currentAdjective] isEqualToString:[self.possibleAdjectives objectAtIndex:0]]) {
        self.questionForInput.text = @"What are you hungry for?";
        [self.statusTextField setPlaceholder:@"I want Mexican!"];
    }else if ([[MyManagedObjectContext currentAdjective] isEqualToString:[self.possibleAdjectives objectAtIndex:1]])
    {
        self.questionForInput.text = @"How you gna excercise?";
        [self.statusTextField setPlaceholder:@"Lets play Soccer!"];
    }else if ([[MyManagedObjectContext currentAdjective] isEqualToString:[self.possibleAdjectives objectAtIndex:2]])
    {
        self.questionForInput.text = @"What are you studying?";
        [self.statusTextField setPlaceholder:@"Math sucks!"];
    }else if ([[MyManagedObjectContext currentAdjective] isEqualToString:[self.possibleAdjectives objectAtIndex:3]])
    {
        self.questionForInput.text = @"Where you raging bra?";
        [self.statusTextField setPlaceholder:@"TOGA PARTYY!"];
    }else if ([[MyManagedObjectContext currentAdjective] isEqualToString:[self.possibleAdjectives objectAtIndex:4]])
    {
        self.questionForInput.text = @"Where are you shopping?";
        [self.statusTextField setPlaceholder:@"Palisades Mall!"];
    }else if ([[MyManagedObjectContext currentAdjective] isEqualToString:[self.possibleAdjectives objectAtIndex:5]])
    {
        self.questionForInput.text = @"Where do you want to coffee?";
        [self.statusTextField setPlaceholder:@"Starbucks!"];
    }else if ([[MyManagedObjectContext currentAdjective] isEqualToString:[self.possibleAdjectives objectAtIndex:6]])
    {
        self.questionForInput.text = @"What do you wanna do?";
        [self.statusTextField setPlaceholder:@"KITE FLYINGG!"];
    }
    [self.questionForInput sizeToFit];
    [self.adjectiveButton.titleLabel sizeToFit];
    [self.popover dismissPopoverAnimated:YES];
    
    if (self.statusInputView.hidden && [[self hungrySlider] value]>0.5)
    {
        [self.mapViewController hideMode];
        [self userTappedToChangeStatus:@1]; // the sender in this isnt used so no worries with the @1...
    }
    
    */
    [self.adjectiveButton setTitle:[[(AppDelegate *)[UIApplication sharedApplication].delegate getGerunds] objectAtIndex:rowNum] forState:UIControlStateNormal];
    [self.popover dismissPopoverAnimated:YES];
    [(AppDelegate *)[UIApplication sharedApplication].delegate updateUserStatus:rowNum];
    
}

- (IBAction)adjectiveButtonClicked:(UIButton*)button
{
    if(![(DHSidebarViewController *)[(AppDelegate *)[UIApplication sharedApplication].delegate getSidebarVC] isOpen] && self.isFinishedLoading)
    {
       
        PopoverTVC *controller = [[PopoverTVC alloc] initWithStyle:UITableViewStylePlain];
        controller.delegate = self;
        [controller setTitle:@"What are you up to?"];
        //[controller  setAdjectives:self.possibleAdjectives];
        
        [controller setAdjectives:[(AppDelegate *)[UIApplication sharedApplication].delegate getGerunds]];
        
        self.popover = [[WYPopoverController alloc] initWithContentViewController:controller];
        
        self.popover.popoverContentSize = CGSizeMake(self.headerUIView.frame.size.width, MIN((self.view.frame.size.height - self.headerUIView.frame.origin.y), [[(AppDelegate *)[UIApplication sharedApplication].delegate getGerunds] count]*44) );
        
        UIColor* greenColor = [UIColor colorWithRed:26.f/255.f green:188.f/255.f blue:156.f/255.f alpha:1];
        
        WYPopoverBackgroundView* popoverAppearance = [WYPopoverBackgroundView appearance];
        
        [popoverAppearance setOuterCornerRadius:4];
        [popoverAppearance setOuterShadowBlurRadius:0];
        [popoverAppearance setOuterShadowColor:[UIColor clearColor]];
        [popoverAppearance setOuterShadowOffset:CGSizeMake(0, 0)];
        
        [popoverAppearance setGlossShadowColor:[UIColor clearColor]];
        [popoverAppearance setGlossShadowOffset:CGSizeMake(0, 0)];
        
        [popoverAppearance setBorderWidth:8];
        [popoverAppearance setArrowHeight:10];
        [popoverAppearance setArrowBase:20];
        
        [popoverAppearance setInnerCornerRadius:4];
        [popoverAppearance setInnerShadowBlurRadius:0];
        [popoverAppearance setInnerShadowColor:[UIColor clearColor]];
        [popoverAppearance setInnerShadowOffset:CGSizeMake(0, 0)];
        
        [popoverAppearance setFillTopColor:greenColor];
        [popoverAppearance setFillBottomColor:greenColor];
        [popoverAppearance setOuterStrokeColor:greenColor];
        [popoverAppearance setInnerStrokeColor:greenColor];
      
        self.popover.delegate = self;
        [self.popover presentPopoverFromRect:button.bounds inView:button permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
        
    }
    
}
- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    self.popover.delegate = nil;
    self.popover = nil;
}


-(IBAction)menuButtonClicked:(id)sender
{
    DHSidebarViewController *sbvc=[(AppDelegate *)[UIApplication sharedApplication].delegate getSidebarVC];
    [sbvc openSidebar];
    
}



#pragma mark - segue
-(IBAction)chatButtonClicked:(id)sender
{
    DHSidebarViewController *sbvc=[(AppDelegate *)[UIApplication sharedApplication].delegate getSidebarVC];
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController *newRootVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"Chat"];
    [sbvc setRootViewController:newRootVC];
    
}


#pragma mark - chat button
-(void)glowChatButton{
    
    [UIView animateWithDuration:0.7f delay:0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationCurveEaseInOut | UIViewAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction  animations:^{
        
        [UIView setAnimationRepeatCount:3];
        
        //self.chatButton.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
        
        
        [self.chatButton setBackgroundColor:[UIColor blueColor]];
        
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.7f delay:0 options: UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction  animations:^{
            [self.chatButton setBackgroundColor:[UIColor clearColor]];
            self.chatButton.layer.shadowRadius = 0.0f;
            self.chatButton.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        } completion:^(BOOL finished) {
            
        }];
    }];
    
    
}


@end
