//
//  ViewController.m
//  Ex.3.FB
//
//  Created by SDT-1 on 2014. 1. 21..
//  Copyright (c) 2014년 T. All rights reserved.
//

#import "ViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

#define FACEBOOK_APPID @"629766377060157"


@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(strong,nonatomic)ACAccount *facebookAccount;
@property(strong,nonatomic)NSArray *data;

@property (weak, nonatomic) IBOutlet UITableView *table;
@end

@implementation ViewController


-(void)showFriend{
    
    ACAccountStore *store = [[ACAccountStore alloc]init];
    ACAccountType *accountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSDictionary*options = @{ACFacebookAppIdKey:FACEBOOK_APPID,ACFacebookPermissionsKey:@[@"read_friendlists"],
                             ACFacebookAudienceKey:ACFacebookAudienceFriends};
    
    [store requestAccessToAccountsWithType:accountType options:options completion:^(BOOL granted,NSError *error){
        
        if(error){
            
            NSLog(@"Error:%@",error);
        }
        
        if(granted){
            
            NSLog(@"권한 승인성공");
            NSArray *accountList = [store accountsWithAccountType:accountType];
            self.facebookAccount = [accountList lastObject];
            
            
            [self requestFriend];
        }
        
        else{
            NSLog(@"권한 승인 실패");
        }
    }];
}

-(void)requestFriend{
    
    NSString *urlStr =@"https://graph.facebook.com/me/friends";
    NSURL *url = [NSURL URLWithString:urlStr];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"picture,id,name,link,gender,last_name,first_name,username",@"fields", nil];
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:url parameters:params];
    request.account =self.facebookAccount;
    
    
    [request performRequestWithHandler:^(NSData *responseData,NSHTTPURLResponse*urlResponse,NSError *error){
        
        
        if(nil != error){
            NSLog(@"Error:%@",error);
            return ;
        }
        
        __autoreleasing NSError *parseError;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&parseError];
        
        
        self.data = result[@"data"];
        
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            
            [self.table reloadData];
        }];
        
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.data count];
}

    
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FRIEND_CELL"];
    NSDictionary *one = self.data[indexPath.row];
    
    
    
    NSString *contents;
    
    if(one[@"name"]){
        
        NSDictionary *korean= one[@"korean"];
        NSArray *data = korean[@"data"];
        
        contents = [NSString stringWithFormat:@"%@....(%d)",one[@"name"],[data count]];
    }
    
    
    else{
        
        contents = one[@"foriegner"];
        cell.indentationLevel =2;
    }
  
    cell.textLabel.text =contents ;
    return cell;
}


-(void)viewWillAppear:(BOOL)animated{
    [self showFriend];
}
    
    

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
