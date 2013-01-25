#import "VMNSocialMediaCountrySelectionViewController.h"

@interface VMNSocialMediaCountrySelectionViewController ()

@end

@implementation VMNSocialMediaCountrySelectionViewController

@synthesize countries;
@synthesize delegate = _delegate;
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
    _selectedRow = 1000;
    
    //Navigation Bar
    self.title = @"Select a country";
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleDone target:self
                                                                  action:@selector(closeView)];
    
    self.navigationItem.rightBarButtonItem = doneButton;
    
    self.countries = [[NSMutableArray alloc]initWithObjects:@"Aaland Islands",@"Afghanistan",@"Albania",@"Algeria",@"American Samoa",@"Andorra",@"Angola",@"Anguilla",@"Antarctica",@"Antigua and Barbuda",@"Argentina",@"Armenia",@"Aruba",@"Australia",@"Austria",@"Azerbaijan",@"Bahamas",@"Bahrain",@"Bangladesh",@"Barbados",@"Belarus",@"Belgium",@"Belize",@"Benin",@"Bermuda",@"Bhutan",@"Bolivia",@"Bosnia and Herzegowina",@"Botswana",@"Bouvet Island",@"Brazil",@"British Indian Ocean Territory",@"Brunei Darussalam",@"Bulgaria",@"Burkina Faso",@"Burundi",@"Cambodia",@"Cameroon",@"Canada",@"Cape Verde",@"Cayman Islands",@"Central African Republic",@"Chad",@"Chile",@"China",@"Christmas Island",@"Cocos (Keeling) Islands",@"Colombia",@"Comoros",@"Congo, Democratic Republic of (Zaire)",@"Congo, Republic of",@"Cook Islands",@"Costa Rica",@"Cote d'Ivoire",@"Croatia (Hrvatska)",@"Cuba",@"Cyprus",@"Czech Republic",@"Denmark",@"Djibouti",@"Dominica",@"Dominican Republic",@"Ecuador",@"Egypt",@"El Salvador",@"Equatorial Guinea",@"Eritrea",@"Estonia",@"Ethiopia",@"Falkland Islands (Malvinas)",@"Faroe Islands",@"Fiji",@"Finland",@"France",@"French Guiana",@"French Polynesia",@"French Southern Territories",@"Gabon",@"Gambia",@"Georgia",@"Germany",@"Ghana",@"Gibraltar",@"Greece",@"Greenland",@"Grenada",@"Guadeloupe",@"Guam",@"Guatemala",@"Guinea",@"Guinea-Bissau",@"Guyana",@"Haiti",@"Heard and Mc Donald Islands",@"Honduras",@"Hong Kong",@"Hungary",@"Iceland",@"India",@"Indonesia",@"Iran, Islamic Republic of",@"Iraq",@"Ireland",@"Israel",@"Italy",@"Jamaica",@"Japan",@"Jordan",@"Kazakhstan",@"Kenya",@"Kiribati",@"Korea, Democratic People's Republic of",@"Korea, Republic of",@"Kuwait",@"Kyrgyzstan",@"Lao People's Democratic Republic",@"Latvia",@"Lebanon",@"Lesotho",@"Liberia",@"Libyan Arab Jamahiriya",@"Liechtenstein",@"Lithuania",@"Luxembourg",@"Macau",@"Macedonia, the Former Yugoslav Republic of",@"Madagascar",@"Malawi",@"Malaysia",@"Maldives",@"Mali",@"Malta",@"Marshall Islands",@"Martinique",@"Mauritania",@"Mauritius",@"Mayotte",@"Mexico",@"Micronesia, Federated States of",@"Moldova, Republic of",@"Monaco",@"Mongolia",@"Montserrat",@"Morocco",@"Mozambique",@"Myanmar",@"Namibia",@"Nauru",@"Nepal",@"Netherlands",@"Netherlands Antilles",@"New Caledonia",@"New Zealand",@"Nicaragua",@"Niger",@"Nigeria",@"Niue",@"Norfolk Island",@"Northern Mariana Islands",@"Norway",@"Oman",@"Pakistan",@"Palau",@"Palestinian Territory, Occupied",@"Panama",@"Papua New Guinea",@"Paraguay",@"Peru",@"Philippines",@"Pitcairn",@"Poland",@"Portugal",@"Puerto Rico",@"Qatar",@"Reunion",@"Romania",@"Russian Federation",@"Rwanda",@"Saint Helena",@"Saint Kitts and Nevis",@"Saint Lucia",@"Saint Pierre and Miquelon",@"Saint Vincent and the Grenadines",@"Samoa",@"San Marino",@"Sao Tome and Principe",@"Saudi Arabia",@"Senegal",@"Serbia and Montenegro",@"Seychelles",@"Sierra Leone",@"Singapore",@"Slovakia",@"Slovenia",@"Solomon Islands",@"Somalia",@"South Africa",@"South Georgia and the South Sandwich Islands",@"Spain",@"Sri Lanka",@"Sudan",@"Suriname",@"Svalbard and Jan Mayen Islands",@"Swaziland",@"Sweden",@"Switzerland",@"Syrian Arab Republic",@"Taiwan",@"Tajikistan",@"Tanzania, United Republic of",@"Thailand",@"Timor-Leste",@"Togo",@"Tokelau",@"Tonga",@"Trinidad and Tobago",@"Tunisia",@"Turkey",@"Turkmenistan",@"Turks and Caicos Islands",@"Tuvalu",@"Uganda",@"Ukraine",@"United Arab Emirates",@"United Kingdom",@"United States",@"United States Minor Outlying Islands",@"Uruguay",@"Uzbekistan",@"Vanuatu",@"Vatican City State (Holy See)",@"Venezuela",@"Vietnam",@"Virgin Islands (British)",@"Virgin Islands (U.S.)",@"Wallis and Futuna Islands",@"Western Sahara",@"Yemen",@"Zambia",@"Zimbabwe",nil];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Set default selected row to US
    _selectedRow =  [self.countries indexOfObject:@"United States"];


    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewDidAppear:(BOOL)animated{
    [self performSelector:@selector(methodThatCallsScrollToRow) withObject:nil afterDelay:0.5];

}


-(void)methodThatCallsScrollToRow{
    [self.tableView reloadData];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.countries indexOfObject:@"United States"]
                                                inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1
    ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"countries count %d", [self.countries count]);
    // Return the number of rows in the section.
    return [self.countries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    if (indexPath.row == _selectedRow && _selectedRow != 1000){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Configure the cell...
    NSString *country = [self.countries objectAtIndex:[indexPath row]];

    cell.textLabel.text = country;

    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedRow = [indexPath row];
    NSString *selectedCountry = [countries objectAtIndex:_selectedRow];
    [self.delegate didSelectCountry:selectedCountry];
    [self.tableView reloadData];
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

- (void)closeView{
    NSString *selectedCountry = [countries objectAtIndex:_selectedRow];
    [self.delegate didSelectCountry:selectedCountry];
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (void)dealloc{
    [super dealloc];
    [countries release];
    _delegate = nil;
}

@end
