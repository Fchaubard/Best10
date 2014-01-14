//
//  MyGerundListTVC.m
//  Best10
//
//  Created by Francois Chaubard on 12/26/13.
//  Copyright (c) 2013 Chaubard. All rights reserved.
//

#import "MyGerundListTVC.h"
#import "AppDelegate.h"

@interface MyGerundListTVC ()

@property (strong, nonatomic) UIRefreshControl IBOutlet     *refreshControl;
@property (strong,nonatomic) UIBarButtonItem *addButton;
@property (strong,nonatomic) UITextView *messageBox;

@end

@implementation MyGerundListTVC


@synthesize refreshControl;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.gerundList=[(AppDelegate *)[UIApplication sharedApplication].delegate getGerunds];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    
    self.addButton.enabled = false;
    
    //UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    [self.navigationItem setRightBarButtonItems:@[self.addButton] animated:YES];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)__unused sender
{
    self.gerundList = [(AppDelegate *)[UIApplication sharedApplication].delegate getGerunds];
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:self.gerundList];
    
    self.gerundList = nil;
    [self.tableView reloadData];
    
    [temp addObject:self.messageBox.text];
    //ensure temp is a valid string
    
    
    [[NSUserDefaults standardUserDefaults] setObject:temp  forKey:@"gerunds"];
    self.gerundList=[(AppDelegate *)[UIApplication sharedApplication].delegate getGerunds];
    self.messageBox = nil;
    self.addButton.enabled = NO;
    [self.tableView reloadData];
    
    [self.tableView setNeedsDisplay];
    [CATransaction flush];
}

- (void) save:(id)__unused sender {
    
    
}



#pragma mark - Table View


- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.gerundList count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row ==[self.gerundList count]  ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessageBox Cell"];
       
        UITextView *messageBox= [[UITextView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 100)];
        
        cell.userInteractionEnabled=YES;
        messageBox.delegate=self;
        [messageBox setEditable:YES];
        [messageBox setUserInteractionEnabled:YES];
        messageBox.editable=YES;
        messageBox.font = cell.textLabel.font;
        messageBox.textAlignment = NSTextAlignmentCenter;
        messageBox.textColor = [UIColor grayColor];
        messageBox.text = @"insert new activity";
        self.messageBox = messageBox;
        [cell addSubview: messageBox];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
        [self configureCell:cell atIndexPath:indexPath];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)__unused tableView canEditRowAtIndexPath:(NSIndexPath *)__unused indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)__unused tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((editingStyle == UITableViewCellEditingStyleDelete)&&([self.gerundList count]>indexPath.row)) {
        
        NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:self.gerundList];
        [temp removeObjectAtIndex:indexPath.row];
        [[NSUserDefaults standardUserDefaults] setObject:temp  forKey:@"gerunds"];
        self.gerundList=[(AppDelegate *)[UIApplication sharedApplication].delegate getGerunds];
        [self resignFirstResponder];
        
        [self.tableView reloadData];
    }
}

- (BOOL)tableView:(UITableView *)__unused tableView canMoveRowAtIndexPath:(NSIndexPath *)__unused indexPath
{
    // The table view should not be re-orderable.
    return YES;
}




- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([self.gerundList count] > 0){
        
        cell.textLabel.text = [self.gerundList objectAtIndex:indexPath.row];
        
    }
}

#pragma mark - UITextViewDelegate
-(void)beginEditing:(UITextView*)textView {
    textView.text = @"ing";
    //[self.messageBox setSelectedRange:NSMakeRange(2,0)];
    
    textView.selectedRange = NSMakeRange(0, 0);
    textView.scrollEnabled = NO;
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self performSelector:@selector(beginEditing:) withObject:textView afterDelay:0.1];

}
-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 3) {
        self.addButton.enabled=YES;
    }else{
        self.addButton.enabled=NO;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.row ==[self.gerundList count] ) ) {
        return UITableViewCellEditingStyleNone;
    }else{
        return UITableViewCellEditingStyleDelete;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        
        if (textView.text.length > 3) {
            [self insertNewObject:textView.text];
        }
        self.addButton.enabled=NO;
        [textView resignFirstResponder];
        textView.text = @"insert new activity";
        return NO; // or true, whetever you's like
        
    }else if((textView.text.length-range.location)<3){
        return NO;
    }
    
    if (textView.text.length > 3) {
        self.addButton.enabled=YES;
    }else{
         self.addButton.enabled=NO;
    }
    return YES;
}

@end
