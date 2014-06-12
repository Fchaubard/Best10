//
//  WolfListCDTVC.m
//  WolfPack
//
//  Created by Francois Chaubard on 3/1/13.
//  Copyright (c) 2013 Francois Chaubard. All rights reserved.
//

#import "BestFriendListCDTVC.h"
#import "AppDelegate.h"
#import "Friend+MKAnnotation.h"

@interface BestFriendListCDTVC ()


@end

@implementation BestFriendListCDTVC


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}




- (void)viewDidLoad
{
    
    [self.refreshControl addTarget:self
                            action:@selector(loadLatestFriendsData)
                  forControlEvents:UIControlEventValueChanged];
    [super viewDidLoad];
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 55, 0);
    self.tableView.contentInset = inset;
    [self setManagedObjectContext:[(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataModelChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:self.managedObjectContext];
    
    
    [self reload];
    
    
}

-(void)handleDataModelChange:(id)__unused sender
{
    [self reload];
}


-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
}





// original
/*
- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if (managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Friend"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = nil; // all Photographers
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}
*/
- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext

{
    
    _managedObjectContext = managedObjectContext;
    
    if (managedObjectContext) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Friend"];
        
        NSSortDescriptor *statusDescriptor = [[NSSortDescriptor alloc] initWithKey:@"userID" ascending:NO];
    
        [request setSortDescriptors:@[statusDescriptor]];
        
        request.predicate = nil;
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
    } else {
        
        self.fetchedResultsController = nil;
        
    }
    
}


- (void)reload
{
    
    /*NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Friend"];
    request.predicate = [NSPredicate predicateWithFormat:@"eventID"];
    NSArray *friends = [self.managedObjectContext executeFetchRequest:request error:NULL];
    */
    [self.tableView reloadData];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.managedObjectContext)
    {
        
        if (!self.managedObjectContext)
        {
            self.managedObjectContext = [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
         
        }
    }
}



-(IBAction)loadLatestFriendsData
{
    
    
    // start the animation if it's not already going
    [self.refreshControl beginRefreshing];
    
    [(AppDelegate *)[UIApplication sharedApplication].delegate refreshUserData];
    
    [self.refreshControl endRefreshing];  // stop the animation
    [self.tableView reloadData];
    
}


#pragma mark - UITableViewDataSource

// Uses NSFetchedResultsController's objectAtIndexPath: to find the Photographer for this row in the table.
// Then uses that Photographer to set the cell up.

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    Friend *friend = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
   
    cell.textLabel.text = [friend.userID stringValue];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", friend.status];
    
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    Friend *friend = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        dispatch_queue_t loaderQ = dispatch_queue_create("delete friend from WP", NULL);
        dispatch_async(loaderQ, ^{
            
            NSString *sessionid =[(AppDelegate *)[UIApplication sharedApplication].delegate getUserToken];
            
            NSString *str = [NSString stringWithFormat:@"http://busbookie.com/serverlets/unfriendjson.php?session=%@&phone=%@",sessionid,friend.userID];
            
            NSURL *URL = [NSURL URLWithString:str];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
            
            NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            
            
            NSArray *jsonArray;
             jsonArray = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
            
            // when we have the results, use main queue to display them
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setManagedObjectContext:self.managedObjectContext];
                [self.tableView reloadData];
                
            });
        });

        
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return 0;//(interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
