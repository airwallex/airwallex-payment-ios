//
//  CardViewController.m
//  Examples
//
//  Created by Victor Zhu on 2020/2/1.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "CardViewController.h"
#import "Widgets.h"
#import "CountryListViewController.h"

@interface CardViewController () <CountryListViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBarButtonItem;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *nameField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *cardNoField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *expiresField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *cvcField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *stateField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *cityField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *streetField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *zipcodeField;
@property (weak, nonatomic) IBOutlet FloatLabeledView *countryView;

@property (strong, nonatomic) Country *country;

@end

@implementation CardViewController

- (IBAction)closePressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)savePressed:(id)sender
{
    AWCard *card = [AWCard new];
    card.name = self.nameField.text;
    card.number = [self.cardNoField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    card.expYear = [self.expiresField.text substringFromIndex:3];
    card.expMonth = [self.expiresField.text substringToIndex:2];
    card.cvc = self.cvcField.text;

    if (self.delegate && [self.delegate respondsToSelector:@selector(cardViewController:didSelectCard:)]) {
        [self.delegate cardViewController:self didSelectCard:card];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"selectCountries"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        CountryListViewController *controller = (CountryListViewController *)navigationController.topViewController;
        controller.country = sender;
        controller.delegate = self;
    }
}

- (IBAction)selectCountries:(id)sender
{
    [self performSegueWithIdentifier:@"selectCountries" sender:self.country];
}

- (void)countryListViewController:(CountryListViewController *)controller didSelectCountry:(nonnull Country *)country
{
    self.country = country;
    self.countryView.text = country.countryName;
}

@end
