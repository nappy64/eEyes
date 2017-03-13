//
//  ConfigTableViewCell.m
//  eEyes
//
//  Created by Nap Chen on 2017/3/11.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "ConfigTableViewCell.h"

@implementation ConfigTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.configTextField addTarget:self action:@selector(textfieldTextDidChange:) forControlEvents:UIControlEventEditingDidEnd];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.configTextField becomeFirstResponder];
}

- (void)textfieldTextDidChange:(UITextField *)textField {
    
    self.block(self.configTextField.text);
}



@end
