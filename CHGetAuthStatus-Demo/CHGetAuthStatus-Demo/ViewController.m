//
//  ViewController.m
//  CHGetAuthStatus-Demo
//
//  Created by 张晨晖 on 2018/7/16.
//  Copyright © 2018年 张晨晖. All rights reserved.
//

#import "ViewController.h"
#import "CHPermission.h"

@interface ViewController () <UIPickerViewDataSource ,UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *LabelTitle;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (nonatomic ,strong) NSArray <NSDictionary *> *pickerArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;


    NSString *path = [[NSBundle mainBundle] pathForResource:@"Permission.plist" ofType:nil];
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    self.pickerArray = array;
    [self.pickerView reloadAllComponents];

}

#pragma mark UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.pickerArray.count;
}

#pragma mark UIPickerViewDelegate
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"Permission:%@---RowID:%@",[self.pickerArray[row] objectForKey:@"TypeName"],[self.pickerArray[row] objectForKey:@"Type"]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [[CHPermission sharedClass] requestAuthWithPermissionRequestType:[[self.pickerArray[row] objectForKey:@"Type"] intValue] andCompleteHandle:^(CHPermissionRequestResultType resultType) {
        switch (resultType) {
            case CHPermissionRequestResultType_Granted:
            {
                self.LabelTitle.text = @"Granted";
            }
                break;
            case CHPermissionRequestResultType_NotExplicit:
            {
                self.LabelTitle.text = @"NotExplicit";
            }
                break;
            case CHPermissionRequestResultType_ParentallyRestricted:
            {
                self.LabelTitle.text = @"Restricted";
            }
                break;
            case CHPermissionRequestResultType_Reject:
            {
                self.LabelTitle.text = @"Reject";
            }
                break;
            default:
                break;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
