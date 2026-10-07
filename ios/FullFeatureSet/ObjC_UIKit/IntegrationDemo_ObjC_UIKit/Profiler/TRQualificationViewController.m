#import "TRQualificationViewController.h"

// Replace YourSDKModule with the PRODUCT_MODULE_NAME of the framework/target
// that contains TRProfileResponse, TRProfileQuestion and TRProfileAnswer.
//#import "YourSDKModule-Swift.h"
#import <TapResearchSDK/TapResearchSDK.h>

#pragma mark - Long option list

@class TRQualificationOptionsViewController;

typedef void (^TRSingleOptionSelection)(TRProfileAnswerOption *option);

@interface TRQualificationOptionsViewController : UITableViewController
@property (nonatomic, copy) NSArray<TRProfileAnswerOption *> *options;
@property (nonatomic, copy, nullable) NSString *selectedPreCode;
@property (nonatomic, copy) TRSingleOptionSelection selection;
@end

@implementation TRQualificationOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Select an answer";
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"OptionCell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OptionCell" forIndexPath:indexPath];
    TRProfileAnswerOption *option = self.options[indexPath.row];
    cell.textLabel.text = option.optionText;
    cell.textLabel.numberOfLines = 0;
    cell.accessoryType = [option.preCode isEqualToString:self.selectedPreCode]
        ? UITableViewCellAccessoryCheckmark
        : UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TRProfileAnswerOption *option = self.options[indexPath.row];
    if (self.selection) self.selection(option);
    [self.navigationController popViewControllerAnimated:YES];
}

@end

#pragma mark - Questionnaire

@interface TRQualificationViewController () <UITextFieldDelegate>
@property (nonatomic, strong, readwrite) TRProfileResponse *response;
@property (nonatomic, copy) TRQualificationSubmitHandler submitHandler;
@property (nonatomic, copy, nullable) void (^exitHandler)(void);
@property (nonatomic, copy, nullable) void (^completionHandler)(TRProfileResponse *response);

@property (nonatomic) NSInteger currentIndex;
@property (nonatomic, getter=isSubmitting) BOOL submitting;

/// NSNumber(questionId) -> NSDate, NSString, or NSMutableSet<NSString *>.
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, id> *draftAnswers;
@property (nonatomic, strong) NSDictionary<NSNumber *, NSString *> *questionErrors;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIButton *exitButton;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *contentStack;

@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *continueButton;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@end

@implementation TRQualificationViewController

- (instancetype)initWithResponse:(TRProfileResponse *)response
                    submitHandler:(TRQualificationSubmitHandler)submitHandler
                           onExit:(void (^)(void))onExit
                       onComplete:(void (^)(TRProfileResponse *))onComplete {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _response = response;
        _submitHandler = [submitHandler copy];
        _exitHandler = [onExit copy];
        _completionHandler = [onComplete copy];
        _draftAnswers = [NSMutableDictionary dictionary];
        _currentIndex = 0;
        _questionErrors = [self.class errorsFromResponse:response];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    [self buildChrome];
    [self render];
}

#pragma mark Layout

- (void)buildChrome {
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.titleLabel.text = @"About You";

    self.exitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.exitButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.exitButton setTitle:@"Exit" forState:UIControlStateNormal];
    [self.exitButton addTarget:self action:@selector(exitTapped) forControlEvents:UIControlEventTouchUpInside];

    self.progressLabel = [[UILabel alloc] init];
    self.progressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.progressLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    self.progressLabel.textColor = UIColor.secondaryLabelColor;

    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.translatesAutoresizingMaskIntoConstraints = NO;

    UIView *separatorTop = [[UIView alloc] init];
    separatorTop.translatesAutoresizingMaskIntoConstraints = NO;
    separatorTop.backgroundColor = UIColor.separatorColor;

    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;

    self.contentStack = [[UIStackView alloc] init];
    self.contentStack.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentStack.axis = UILayoutConstraintAxisVertical;
    self.contentStack.spacing = 20.0;
    self.contentStack.alignment = UIStackViewAlignmentFill;
    [self.scrollView addSubview:self.contentStack];

    self.bottomBar = [[UIView alloc] init];
    self.bottomBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.bottomBar.backgroundColor = UIColor.systemBackgroundColor;

    UIView *separatorBottom = [[UIView alloc] init];
    separatorBottom.translatesAutoresizingMaskIntoConstraints = NO;
    separatorBottom.backgroundColor = UIColor.separatorColor;
    [self.bottomBar addSubview:separatorBottom];

    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backButton setTitle:@"Back" forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:self.backButton];

    self.continueButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.continueButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.continueButton setTitle:@"Continue" forState:UIControlStateNormal];
    self.continueButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [self.continueButton addTarget:self action:@selector(continueTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:self.continueButton];

    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.spinner.translatesAutoresizingMaskIntoConstraints = NO;
    self.spinner.hidesWhenStopped = YES;
    [self.bottomBar addSubview:self.spinner];

    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.exitButton];
    [self.view addSubview:self.progressLabel];
    [self.view addSubview:self.progressView];
    [self.view addSubview:separatorTop];
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.bottomBar];

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.titleLabel.topAnchor constraintEqualToAnchor:safe.topAnchor constant:16.0],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:20.0],
        [self.exitButton.centerYAnchor constraintEqualToAnchor:self.titleLabel.centerYAnchor],
        [self.exitButton.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-20.0],

        [self.progressLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:10.0],
        [self.progressLabel.leadingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor],
        [self.progressLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.exitButton.trailingAnchor],

        [self.progressView.topAnchor constraintEqualToAnchor:self.progressLabel.bottomAnchor constant:8.0],
        [self.progressView.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:20.0],
        [self.progressView.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-20.0],

        [separatorTop.topAnchor constraintEqualToAnchor:self.progressView.bottomAnchor constant:14.0],
        [separatorTop.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [separatorTop.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [separatorTop.heightAnchor constraintEqualToConstant:1.0 / UIScreen.mainScreen.scale],

        [self.scrollView.topAnchor constraintEqualToAnchor:separatorTop.bottomAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.bottomBar.topAnchor],

        [self.contentStack.topAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.topAnchor constant:24.0],
        [self.contentStack.leadingAnchor constraintEqualToAnchor:self.scrollView.frameLayoutGuide.leadingAnchor constant:24.0],
        [self.contentStack.trailingAnchor constraintEqualToAnchor:self.scrollView.frameLayoutGuide.trailingAnchor constant:-24.0],
        [self.contentStack.bottomAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.bottomAnchor constant:-24.0],

        [self.bottomBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.bottomBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.bottomBar.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.bottomBar.heightAnchor constraintEqualToConstant:76.0 + self.view.safeAreaInsets.bottom],

        [separatorBottom.topAnchor constraintEqualToAnchor:self.bottomBar.topAnchor],
        [separatorBottom.leadingAnchor constraintEqualToAnchor:self.bottomBar.leadingAnchor],
        [separatorBottom.trailingAnchor constraintEqualToAnchor:self.bottomBar.trailingAnchor],
        [separatorBottom.heightAnchor constraintEqualToConstant:1.0 / UIScreen.mainScreen.scale],

        [self.backButton.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:20.0],
        [self.backButton.centerYAnchor constraintEqualToAnchor:self.bottomBar.topAnchor constant:38.0],

        [self.continueButton.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-20.0],
        [self.continueButton.centerYAnchor constraintEqualToAnchor:self.backButton.centerYAnchor],

        [self.spinner.trailingAnchor constraintEqualToAnchor:self.continueButton.leadingAnchor constant:-12.0],
        [self.spinner.centerYAnchor constraintEqualToAnchor:self.continueButton.centerYAnchor],
    ]];
}

#pragma mark Rendering

- (NSArray<TRProfileQuestion *> *)questions {
    return self.response.qualifications;
}

- (TRProfileQuestion * _Nullable)currentQuestion {
    NSArray *questions = [self questions];
    if (self.currentIndex < 0 || self.currentIndex >= (NSInteger)questions.count) return nil;
    return questions[self.currentIndex];
}

- (BOOL)isComplete {
    return self.response.isProfiled || self.response.qualifications.count == 0;
}

- (void)render {
    for (UIView *view in self.contentStack.arrangedSubviews.copy) {
        [self.contentStack removeArrangedSubview:view];
        [view removeFromSuperview];
    }

    if ([self isComplete]) {
        [self renderComplete];
        return;
    }

    TRProfileQuestion *question = [self currentQuestion];
    if (!question) {
        [self renderComplete];
        return;
    }

    NSUInteger count = self.response.qualifications.count;
    self.progressLabel.text = [NSString stringWithFormat:@"Question %ld of %lu",
                               (long)self.currentIndex + 1, (unsigned long)count];
    self.progressView.progress = count ? ((float)self.currentIndex + 1.0f) / (float)count : 0;
    self.progressLabel.hidden = NO;
    self.progressView.hidden = NO;
    self.bottomBar.hidden = NO;

    UILabel *questionLabel = [self labelWithText:question.questionText
                                            font:[UIFont preferredFontForTextStyle:UIFontTextStyleTitle2]
                                           color:UIColor.labelColor];
    questionLabel.font = [UIFont systemFontOfSize:questionLabel.font.pointSize weight:UIFontWeightSemibold];
    [self.contentStack addArrangedSubview:questionLabel];

    if (question.questionSubtext.length > 0) {
        UILabel *subtext = [self labelWithText:question.questionSubtext
                                          font:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
                                         color:UIColor.secondaryLabelColor];
        [self.contentStack addArrangedSubview:subtext];
    }

    NSString *error = self.questionErrors[@(question.questionId)];
    if (error.length > 0) {
        [self.contentStack addArrangedSubview:[self errorView:error]];
    }

    NSString *type = question.answerType ?: @"";
    if ([type isEqualToString:@"date"]) {
        [self renderDateQuestion:question];
    } else if ([type isEqualToString:@"zip_code"]) {
        [self renderZipQuestion:question];
    } else if ([type isEqualToString:@"single_select"]) {
        if (question.qualificationAnswers.count > 10) {
            [self renderLongSingleSelectQuestion:question];
        } else {
            [self renderSingleSelectQuestion:question];
        }
    } else if ([type isEqualToString:@"multi_select"]) {
        [self renderMultiSelectQuestion:question];
    } else {
        UILabel *unsupported = [self labelWithText:[NSString stringWithFormat:@"Unsupported question type: %@", type]
                                               font:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]
                                              color:UIColor.secondaryLabelColor];
        [self.contentStack addArrangedSubview:unsupported];
    }

    BOOL last = self.currentIndex == (NSInteger)count - 1;
    [self.continueButton setTitle:last ? @"Submit" : @"Continue" forState:UIControlStateNormal];
    self.backButton.enabled = self.currentIndex > 0 && !self.isSubmitting;
    self.continueButton.enabled = [self hasAnswerForQuestion:question] && !self.isSubmitting;
}

- (void)renderComplete {
    self.progressLabel.hidden = YES;
    self.progressView.hidden = YES;
    self.bottomBar.hidden = YES;

    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"checkmark.circle.fill"]];
    image.translatesAutoresizingMaskIntoConstraints = NO;
    image.contentMode = UIViewContentModeScaleAspectFit;
    image.tintColor = UIColor.systemGreenColor;
    [image.heightAnchor constraintEqualToConstant:52].active = YES;
    [self.contentStack addArrangedSubview:image];

    UILabel *title = [self labelWithText:@"You're all set"
                                    font:[UIFont preferredFontForTextStyle:UIFontTextStyleTitle2]
                                   color:UIColor.labelColor];
    title.textAlignment = NSTextAlignmentCenter;
    [self.contentStack addArrangedSubview:title];

    UILabel *message = [self labelWithText:@"Your profiling answers have been accepted."
                                      font:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]
                                     color:UIColor.secondaryLabelColor];
    message.textAlignment = NSTextAlignmentCenter;
    [self.contentStack addArrangedSubview:message];

    UIButton *done = [UIButton buttonWithType:UIButtonTypeSystem];
    [done setTitle:@"Done" forState:UIControlStateNormal];
    done.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [done addTarget:self action:@selector(doneTapped) forControlEvents:UIControlEventTouchUpInside];
    [done.heightAnchor constraintGreaterThanOrEqualToConstant:44].active = YES;
    [self.contentStack addArrangedSubview:done];
}

- (void)renderDateQuestion:(TRProfileQuestion *)question {
    UIDatePicker *picker = [[UIDatePicker alloc] init];
    picker.datePickerMode = UIDatePickerModeDate;
    picker.maximumDate = [NSDate date];
    if (@available(iOS 14.0, *)) picker.preferredDatePickerStyle = UIDatePickerStyleInline;

    NSDate *draft = [self.draftAnswers[@(question.questionId)] isKindOfClass:NSDate.class]
        ? self.draftAnswers[@(question.questionId)] : nil;
    if (draft) {
        picker.date = draft;
    } else {
        NSDateComponents *components = [[NSDateComponents alloc] init];
        components.year = -30;
        picker.date = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:[NSDate date] options:0] ?: [NSDate date];
    }

    picker.tag = question.questionId;
    [picker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [self.contentStack addArrangedSubview:picker];

    if (!draft) {
        UILabel *hint = [self labelWithText:@"Choose your date of birth to continue."
                                       font:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]
                                      color:UIColor.secondaryLabelColor];
        [self.contentStack addArrangedSubview:hint];
    }
}

- (void)renderZipQuestion:(TRProfileQuestion *)question {
    UITextField *field = [[UITextField alloc] init];
    field.borderStyle = UITextBorderStyleRoundedRect;
    field.placeholder = @"ZIP or postal code";
    field.textContentType = UITextContentTypePostalCode;
    field.autocorrectionType = UITextAutocorrectionTypeNo;
    field.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    field.returnKeyType = UIReturnKeyDone;
    field.delegate = self;
    field.tag = question.questionId;
    id draft = self.draftAnswers[@(question.questionId)];
    if ([draft isKindOfClass:NSString.class]) field.text = draft;
    [field addTarget:self action:@selector(zipChanged:) forControlEvents:UIControlEventEditingChanged];
    [field.heightAnchor constraintEqualToConstant:44].active = YES;
    [self.contentStack addArrangedSubview:field];
}

- (void)renderSingleSelectQuestion:(TRProfileQuestion *)question {
    NSString *selected = [self singleSelectionForQuestion:question];
    for (TRProfileAnswerOption *option in question.qualificationAnswers) {
        UIButton *button = [self optionButtonWithText:option.optionText
                                             selected:[selected isEqualToString:option.preCode]
                                                multi:NO];
        button.tag = question.questionId;
        button.accessibilityIdentifier = option.preCode;
        [button addTarget:self action:@selector(singleOptionTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentStack addArrangedSubview:button];
    }
}

- (void)renderLongSingleSelectQuestion:(TRProfileQuestion *)question {
    NSString *selectedCode = [self singleSelectionForQuestion:question];
    NSString *selectedText = nil;
    for (TRProfileAnswerOption *option in question.qualificationAnswers) {
        if ([option.preCode isEqualToString:selectedCode]) {
            selectedText = option.optionText;
            break;
        }
    }

    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.tag = question.questionId;
    [button setTitle:selectedText ?: @"Select an answer" forState:UIControlStateNormal];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.titleLabel.numberOfLines = 0;
    button.layer.cornerRadius = 10.0;
    button.layer.borderWidth = 1.0;
    button.layer.borderColor = UIColor.separatorColor.CGColor;
    button.contentEdgeInsets = UIEdgeInsetsMake(12, 14, 12, 14);
    [button.heightAnchor constraintGreaterThanOrEqualToConstant:48].active = YES;
    [button addTarget:self action:@selector(longSingleTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentStack addArrangedSubview:button];
}

- (void)renderMultiSelectQuestion:(TRProfileQuestion *)question {
    NSSet<NSString *> *selected = [self multipleSelectionForQuestion:question];
    for (TRProfileAnswerOption *option in question.qualificationAnswers) {
        UIButton *button = [self optionButtonWithText:option.optionText
                                             selected:[selected containsObject:option.preCode]
                                                multi:YES];
        button.tag = question.questionId;
        button.accessibilityIdentifier = option.preCode;
        [button addTarget:self action:@selector(multiOptionTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentStack addArrangedSubview:button];
    }
}

#pragma mark Actions

- (void)exitTapped {
    if (self.exitHandler) self.exitHandler();
}

- (void)doneTapped {
    if (self.completionHandler) self.completionHandler(self.response);
}

- (void)backTapped {
    if (self.currentIndex > 0 && !self.isSubmitting) {
        self.currentIndex--;
        [self render];
    }
}

- (void)continueTapped {
    TRProfileQuestion *question = [self currentQuestion];
    if (!question || ![self hasAnswerForQuestion:question] || self.isSubmitting) return;

    BOOL last = self.currentIndex == (NSInteger)self.response.qualifications.count - 1;
    if (!last) {
        self.currentIndex++;
        [self render];
        [self.scrollView setContentOffset:CGPointZero animated:NO];
        return;
    }

    [self submitAnswers];
}

- (void)dateChanged:(UIDatePicker *)sender {
    self.draftAnswers[@(sender.tag)] = sender.date;
    [self updateNavigationState];
}

- (void)zipChanged:(UITextField *)sender {
    self.draftAnswers[@(sender.tag)] = sender.text ?: @"";
    [self updateNavigationState];
}

- (void)singleOptionTapped:(UIButton *)sender {
    if (!sender.accessibilityIdentifier) return;
    self.draftAnswers[@(sender.tag)] = sender.accessibilityIdentifier;
    [self render];
}

- (void)multiOptionTapped:(UIButton *)sender {
    if (!sender.accessibilityIdentifier) return;
    NSNumber *key = @(sender.tag);
    NSMutableSet<NSString *> *values = [[self multipleSelectionForQuestion:[self currentQuestion]] mutableCopy];
    if ([values containsObject:sender.accessibilityIdentifier]) {
        [values removeObject:sender.accessibilityIdentifier];
    } else {
        [values addObject:sender.accessibilityIdentifier];
    }
    self.draftAnswers[key] = values;
    [self render];
}

- (void)longSingleTapped:(UIButton *)sender {
    TRProfileQuestion *question = [self currentQuestion];
    if (!question) return;

    TRQualificationOptionsViewController *options = [[TRQualificationOptionsViewController alloc] initWithStyle:UITableViewStyleInsetGrouped];
    options.options = question.qualificationAnswers;
    options.selectedPreCode = [self singleSelectionForQuestion:question];

    __weak typeof(self) weakSelf = self;
    options.selection = ^(TRProfileAnswerOption *option) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        self.draftAnswers[@(question.questionId)] = option.preCode;
        [self render];
    };

    if (self.navigationController) {
        [self.navigationController pushViewController:options animated:YES];
    } else {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:options];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark Submission

- (void)submitAnswers {
    NSMutableArray<TRProfileAnswer *> *apiAnswers = [NSMutableArray array];

    for (TRProfileQuestion *question in self.response.qualifications) {
        id draft = self.draftAnswers[@(question.questionId)];
        if (!draft) continue;

        TRProfileAnswer *answer = [self apiAnswerForQuestion:question draft:draft];
        if (answer) [apiAnswers addObject:answer];
    }

    if (apiAnswers.count == 0) return;

    self.submitting = YES;
    [self.spinner startAnimating];
    [self updateNavigationState];

    __weak typeof(self) weakSelf = self;
    self.submitHandler(apiAnswers, ^(TRProfileResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;

            self.submitting = NO;
            [self.spinner stopAnimating];

            if (error) {
                [self presentError:error.localizedDescription ?: @"An unknown error occurred."];
                [self updateNavigationState];
                return;
            }

            if (!response) {
                [self presentError:@"The profiling service returned no response."];
                [self updateNavigationState];
                return;
            }

            [self applyUpdatedResponse:response];
        });
    });
}

- (TRProfileAnswer * _Nullable)apiAnswerForQuestion:(TRProfileQuestion *)question draft:(id)draft {
    NSString *type = question.answerType ?: @"";

    if ([type isEqualToString:@"date"] && [draft isKindOfClass:NSDate.class]) {
        return [TRProfileAnswer answerWithQuestionId:question.questionId
                                             answer:[self.class apiDateStringFromDate:draft]];
    }

    if ([type isEqualToString:@"zip_code"] && [draft isKindOfClass:NSString.class]) {
        NSString *value = [(NSString *)draft stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        if (value.length == 0) return nil;
        // ZIP/postal answers no longer require country_code.
        return [TRProfileAnswer answerWithQuestionId:question.questionId answer:value];
    }

    if ([type isEqualToString:@"single_select"] && [draft isKindOfClass:NSString.class]) {
        if ([(NSString *)draft length] == 0) return nil;
        return [TRProfileAnswer answerWithQuestionId:question.questionId answer:draft];
    }

    if ([type isEqualToString:@"multi_select"] && [draft isKindOfClass:NSSet.class]) {
        NSArray<NSString *> *values = [[(NSSet<NSString *> *)draft allObjects] sortedArrayUsingSelector:@selector(compare:)];
        if (values.count == 0) return nil;
        return [TRProfileAnswer answerWithQuestionId:question.questionId answers:values];
    }

    return nil;
}

- (void)applyUpdatedResponse:(TRProfileResponse *)updatedResponse {
    NSMutableSet<NSNumber *> *returnedIDs = [NSMutableSet set];
    for (TRProfileQuestion *question in updatedResponse.qualifications) {
        [returnedIDs addObject:@(question.questionId)];
    }

    for (NSNumber *questionID in self.draftAnswers.allKeys.copy) {
        if (![returnedIDs containsObject:questionID]) {
            [self.draftAnswers removeObjectForKey:questionID];
        }
    }

    self.response = updatedResponse;
    self.questionErrors = [self.class errorsFromResponse:updatedResponse];
    self.currentIndex = 0;

    for (NSInteger index = 0; index < (NSInteger)updatedResponse.qualifications.count; index++) {
        TRProfileQuestion *question = updatedResponse.qualifications[index];
        if (self.questionErrors[@(question.questionId)] != nil) {
            self.currentIndex = index;
            break;
        }
    }

    [self render];
    [self.scrollView setContentOffset:CGPointZero animated:NO];

    if ([self isComplete] && self.completionHandler) {
        // Mirror the SwiftUI version: show completion UI; callback occurs on Done.
    }
}

#pragma mark State helpers

- (BOOL)hasAnswerForQuestion:(TRProfileQuestion *)question {
    id answer = self.draftAnswers[@(question.questionId)];
    if (!answer) return NO;

    if ([answer isKindOfClass:NSDate.class]) return YES;
    if ([answer isKindOfClass:NSString.class]) {
        return [[(NSString *)answer stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] length] > 0;
    }
    if ([answer isKindOfClass:NSSet.class]) return [(NSSet *)answer count] > 0;
    return NO;
}

- (NSString * _Nullable)singleSelectionForQuestion:(TRProfileQuestion *)question {
    id value = self.draftAnswers[@(question.questionId)];
    return [value isKindOfClass:NSString.class] ? value : nil;
}

- (NSSet<NSString *> *)multipleSelectionForQuestion:(TRProfileQuestion *)question {
    id value = self.draftAnswers[@(question.questionId)];
    return [value isKindOfClass:NSSet.class] ? value : [NSSet set];
}

- (void)updateNavigationState {
    TRProfileQuestion *question = [self currentQuestion];
    self.backButton.enabled = self.currentIndex > 0 && !self.isSubmitting;
    self.continueButton.enabled = question && [self hasAnswerForQuestion:question] && !self.isSubmitting;
}

+ (NSDictionary<NSNumber *, NSString *> *)errorsFromResponse:(TRProfileResponse *)response {
    NSMutableDictionary<NSNumber *, NSString *> *errors = [NSMutableDictionary dictionary];

    for (TRProfileQuestion *question in response.qualifications) {
        if (question.previousError.length > 0) {
            errors[@(question.questionId)] = question.previousError;
        }
    }

    // result.errors wins when both are present.
	for (TRProfileAnswerResultError *err in response.result.errors) {
		if (err.questionId > 0 && err.error.length > 0) {
            errors[@(err.questionId)] = err.error;
        }
	}

    return errors;
}

#pragma mark UI helpers

- (UILabel *)labelWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = font;
    label.textColor = color;
    label.numberOfLines = 0;
    return label;
}

- (UIView *)errorView:(NSString *)message {
    UIView *container = [[UIView alloc] init];
    container.backgroundColor = [UIColor.systemRedColor colorWithAlphaComponent:0.08];
    container.layer.cornerRadius = 10.0;

    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"exclamationmark.triangle.fill"]];
    icon.translatesAutoresizingMaskIntoConstraints = NO;
    icon.tintColor = UIColor.systemRedColor;
    [container addSubview:icon];

    UILabel *label = [self labelWithText:message
                                    font:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
                                   color:UIColor.systemRedColor];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:label];

    [NSLayoutConstraint activateConstraints:@[
        [icon.leadingAnchor constraintEqualToAnchor:container.leadingAnchor constant:12],
        [icon.topAnchor constraintEqualToAnchor:container.topAnchor constant:13],
        [icon.widthAnchor constraintEqualToConstant:18],
        [icon.heightAnchor constraintEqualToConstant:18],
        [label.leadingAnchor constraintEqualToAnchor:icon.trailingAnchor constant:10],
        [label.trailingAnchor constraintEqualToAnchor:container.trailingAnchor constant:-12],
        [label.topAnchor constraintEqualToAnchor:container.topAnchor constant:12],
        [label.bottomAnchor constraintEqualToAnchor:container.bottomAnchor constant:-12],
    ]];

    return container;
}

- (UIButton *)optionButtonWithText:(NSString *)text selected:(BOOL)selected multi:(BOOL)multi {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    NSString *symbol = multi
        ? (selected ? @"checkmark.square.fill" : @"square")
        : (selected ? @"checkmark.circle.fill" : @"circle");

    [button setImage:[UIImage systemImageNamed:symbol] forState:UIControlStateNormal];
    [button setTitle:text forState:UIControlStateNormal];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.titleLabel.numberOfLines = 0;
    button.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    button.tintColor = UIColor.systemBlueColor;
    button.backgroundColor = selected
        ? [UIColor.systemBlueColor colorWithAlphaComponent:0.10]
        : [UIColor.secondarySystemBackgroundColor colorWithAlphaComponent:0.8];
    button.layer.cornerRadius = 12.0;
    button.contentEdgeInsets = UIEdgeInsetsMake(14, 14, 14, 14);
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    [button.heightAnchor constraintGreaterThanOrEqualToConstant:48].active = YES;
    return button;
}

- (void)presentError:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Unable to submit answers"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

+ (NSString *)apiDateStringFromDate:(NSDate *)date {
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        formatter.dateFormat = @"yyyy-MM-dd";
    });
    return [formatter stringFromDate:date];
}

@end
