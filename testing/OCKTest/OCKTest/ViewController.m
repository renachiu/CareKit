//
//  ViewController.m
//  OCKTest
//
//  Created by Yuan Zhu on 1/19/16.
//  Copyright © 2016 carekit.org. All rights reserved.
//


#import "ViewController.h"
#import <CareKit/CareKit.h>
#import <ResearchKit/ResearchKit.h>


#define DefineStringKey(x) static NSString *const x = @#x

static const BOOL resetStoreOnLaunch = YES;

@interface ViewController () <OCKEvaluationTableViewDelegate, OCKCarePlanStoreDelegate, ORKTaskViewControllerDelegate>

@end


@implementation ViewController {
    UITabBarController *_tabBarController;
    OCKDashboardViewController *_dashboardViewController;
    OCKCareCardViewController *_careCardViewController;
    OCKEvaluationViewController *_evaluationViewController;
    OCKConnectViewController *_connectViewController;
    
    OCKCarePlanStore *_store;
    NSArray<OCKCarePlanActivity *> *_evaluations;
    NSArray<OCKCarePlanActivity *> *_treatments;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self performSelectorOnMainThread:@selector(setUpCarePlanStore) withObject:nil waitUntilDone:YES];
    
    _dashboardViewController = [self dashboardViewController];
    _dashboardViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Insights"
                                                                        image:[UIImage imageNamed:@"insights"]
                                                                selectedImage:[UIImage imageNamed:@"insights-filled"]];
    
    _careCardViewController = [self careCardViewController];
    _careCardViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Care Card"
                                                                       image:[UIImage imageNamed:@"carecard"]
                                                               selectedImage:[UIImage imageNamed:@"carecard-filled"]];
    
    _evaluationViewController = [self evaluationViewController];
    _evaluationViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Progress Card"
                                                                         image:[UIImage imageNamed:@"checkups"]
                                                                 selectedImage:[UIImage imageNamed:@"checkups-filled"]];
    
    _connectViewController = [self connectViewController];
    _connectViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Connect"
                                                                      image:[UIImage imageNamed:@"connect"]
                                                              selectedImage:[UIImage imageNamed:@"connect-filled"]];
    
    _tabBarController = [UITabBarController new];
    _tabBarController.tabBar.tintColor = OCKRedColor();
    _tabBarController.viewControllers = @[_dashboardViewController, _careCardViewController, _evaluationViewController, _connectViewController];
    _tabBarController.selectedIndex = 1;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self presentViewController:_tabBarController animated:YES completion:nil];
}

#pragma mark - CareKit View Controllers

- (OCKDashboardViewController *)dashboardViewController {
    NSMutableArray *charts = [NSMutableArray new];
    
    NSArray *axisTitles = @[@"S", @"M", @"T", @"W", @"T", @"F", @"S"];
    NSArray *axisSubtitles = @[@"2/21", @"", @"", @"", @"", @"", @"2/27"];
    
    {
        UIColor *color = OCKBlueColor();
        UIColor *lightColor = [color colorWithAlphaComponent:0.5];
        
        OCKBarGroup *group1 = [OCKBarGroup barGroupWithTitle:@"Pain"
                                                      values:@[@9, @8, @7, @7, @5, @4, @2]
                                                 valueLabels:@[@"9", @"8", @"7", @"7", @"5", @"4", @"2"]
                                                   tintColor:color];
        
        OCKBarGroup *group2 = [OCKBarGroup barGroupWithTitle:@"Ibuprofen"
                                                      values:@[@3, @4, @5, @7, @8, @9, @9]
                                                 valueLabels:@[@"30%", @"40%", @"50%", @"70%", @"80%", @"90%", @"90%"]
                                                   tintColor:lightColor];
        
        OCKBarChart *chart = [OCKBarChart barChartWithTitle:@"Pain Scores"
                                                       text:@"with Ibuprofen"
                                                 axisTitles:axisTitles
                                              axisSubtitles:axisSubtitles
                                                     groups:@[group1, group2]];
        chart.tintColor = color;
        [charts addObject:chart];
    }
    
    {
        UIColor *color = OCKPurpleColor();
        UIColor *lightColor = [color colorWithAlphaComponent:0.5];
        
        OCKBarGroup *group1 = [OCKBarGroup barGroupWithTitle:@"Weight"
                                                      values:@[@1, @4, @5, @5, @7, @9, @10]
                                                 valueLabels:@[@"165 lbs", @"169 lbs", @"170 lbs", @"170 lbs", @"172 lbs", @"174 lbs", @"175 lbs"]
                                                   tintColor:color];
        
        OCKBarGroup *group2 = [OCKBarGroup barGroupWithTitle:@"Metformin"
                                                      values:@[@8.5, @7, @5, @4, @3, @3, @2]
                                                 valueLabels:@[@"85%", @"75%", @"50%", @"54%", @"30%", @"30%", @"20%"]
                                                   tintColor:lightColor];
        
        OCKBarChart *chart = [OCKBarChart barChartWithTitle:@"Weight Measurements"
                                                       text:@"with Metformin"
                                                 axisTitles:axisTitles
                                              axisSubtitles:axisSubtitles
                                                     groups:@[group1, group2]];
        chart.tintColor = color;
        [charts addObject:chart];
    }
    
    OCKDashboardViewController *dashboard = [OCKDashboardViewController dashboardWithCharts:charts];
    dashboard.headerTitle = @"Weekly Charts";
    dashboard.headerText = @"2/21 - 2/27";
    
    return dashboard;
}

- (OCKCareCardViewController *)careCardViewController {
    return [OCKCareCardViewController careCardViewControllerWithCarePlanStore:_store];
}

- (OCKEvaluationViewController *)evaluationViewController {
    return [OCKEvaluationViewController evaluationViewControllerWithCarePlanStore:_store
                                                                         delegate:self];
}

- (OCKConnectViewController *)connectViewController {
    NSMutableArray *contacts = [NSMutableArray new];
    
    {
        OCKContact *contact = [OCKContact contactWithContactType:OCKContactTypeClinician
                                                            name:@"Dr. Giselle Guerrero"
                                                        relation:@"Physician"
                                                     phoneNumber:@"123-456-7890"
                                                   messageNumber:nil
                                                    emailAddress:@"g_guerrero@hospital.edu"
                                                           image:[UIImage imageNamed:@"doctor"]];
        contact.tintColor = OCKBlueColor();
        [contacts addObject:contact];
    }
    
    {
        OCKContact *contact = [OCKContact contactWithContactType:OCKContactTypeClinician
                                                            name:@"Tom Clark"
                                                        relation:@"Nurse"
                                                     phoneNumber:@"123-456-7890"
                                                   messageNumber:nil
                                                    emailAddress:@"nbrooks@researchkit.org"
                                                           image:nil];
        contact.tintColor = OCKGreenColor();
        [contacts addObject:contact];
    }
    
    {
        
        OCKContact *contact = [OCKContact contactWithContactType:OCKContactTypeEmergencyContact
                                                            name:@"John Appleseed"
                                                        relation:@"Father"
                                                     phoneNumber:@"123-456-7890"
                                                   messageNumber:@"123-456-7890"
                                                    emailAddress:nil
                                                           image:nil];
        contact.tintColor = OCKYellowColor();
        [contacts addObject:contact];
    }
    
    return [OCKConnectViewController connectViewControllerWithContacts:contacts];
}


#pragma mark - CarePlan Store

- (NSString *)storeDirectoryPath {
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [searchPaths objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:@"carePlanStore"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}

- (NSURL *)storeDirectoryURL {
    return [NSURL fileURLWithPath:[self storeDirectoryPath]];
}

- (void)setUpCarePlanStore {
    // Reset the store.
    if (resetStoreOnLaunch) {
        [[NSFileManager defaultManager] removeItemAtPath:[self storeDirectoryPath] error:nil];
    }
    
    // Set up store.
    _store = [[OCKCarePlanStore alloc] initWithPersistenceDirectoryURL:[self storeDirectoryURL]];
    _store.delegate = self;
    
    // Add new treatments to store.
    [self generateTreatments];
    for (OCKCarePlanActivity *treatment in _treatments) {
        [_store addActivity:treatment completion:^(BOOL success, NSError * _Nonnull error) {
            if (!success) {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
    
    // Add new evaluations to store.
    [self generateEvaluations];
    for (OCKCarePlanActivity *evaluation in _evaluations) {
        [_store addActivity:evaluation completion:^(BOOL success, NSError * _Nonnull error) {
            if (!success) {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}


#pragma mark - CareCard

DefineStringKey(MeditationTreatment);
DefineStringKey(IbuprofenTreatment);
DefineStringKey(OutdoorWalkTreatment);
DefineStringKey(PhysicalTherapyTreatment);

- (void)generateTreatments {
    NSMutableArray *treatments = [NSMutableArray new];

    NSDateComponents *startDate = [[NSDateComponents alloc] initWithYear:2016 month:01 day:01];
    
    {
        OCKCareSchedule *schedule = [OCKCareSchedule weeklyScheduleWithStartDay:startDate occurrencesOnEachDay:@[@2,@2,@2,@1,@2,@3,@3]];
        UIColor *color = OCKBlueColor();
        OCKCarePlanActivity *treatment = [[OCKCarePlanActivity alloc] initWithIdentifier:MeditationTreatment
                                                                                    type:OCKCarePlanActivityTypeIntervention
                                                                                   title:@"Hamstring Stretch"
                                                                                    text:@"5 mins"
                                                                               tintColor:color
                                                                                schedule:schedule];
        [treatments addObject:treatment];
    }
    
    {
        OCKCareSchedule *schedule = [OCKCareSchedule weeklyScheduleWithStartDay:startDate occurrencesOnEachDay:@[@4,@4,@4,@4,@4,@4,@4]];
        UIColor *color = OCKGreenColor();
        OCKCarePlanActivity *treatment = [[OCKCarePlanActivity alloc] initWithIdentifier:IbuprofenTreatment
                                                                                    type:OCKCarePlanActivityTypeIntervention
                                                                                   title:@"Ibuprofen"
                                                                                    text:@"200mg"
                                                                               tintColor:color
                                                                                schedule:schedule];
        [treatments addObject:treatment];
    }
    
    {
        OCKCareSchedule *schedule = [OCKCareSchedule weeklyScheduleWithStartDay:startDate occurrencesOnEachDay:@[@2,@1,@2,@1,@2,@1,@2]];
        UIColor *color = OCKPurpleColor();
        OCKCarePlanActivity *treatment = [[OCKCarePlanActivity alloc] initWithIdentifier:OutdoorWalkTreatment
                                                                                    type:OCKCarePlanActivityTypeIntervention
                                                                                   title:@"Outdoor Walk"
                                                                                    text:@"15 mins"
                                                                               tintColor:color
                                                                                schedule:schedule];
        [treatments addObject:treatment];
    }
    
    {
        OCKCareSchedule *schedule = [OCKCareSchedule weeklyScheduleWithStartDay:startDate occurrencesOnEachDay:@[@1,@1,@1,@0,@1,@1,@1]];
        UIColor *color = OCKYellowColor();
        OCKCarePlanActivity *treatment = [[OCKCarePlanActivity alloc] initWithIdentifier:PhysicalTherapyTreatment
                                                                                    type:OCKCarePlanActivityTypeIntervention
                                                                                   title:@"Physical Therapy"
                                                                                    text:@"Lower back"
                                                                               tintColor:color
                                                                                schedule:schedule];
        [treatments addObject:treatment];
    }
    
    _treatments = [treatments copy];
}


#pragma mark - Evaluations

DefineStringKey(PainEvaluation);
DefineStringKey(MoodEvaluation);
DefineStringKey(SleepQualityEvaluation);
DefineStringKey(BloodPressureEvaluation);
DefineStringKey(WeightEvaluation);

- (void)generateEvaluations {
    NSMutableArray *evaluations = [NSMutableArray new];

    NSDateComponents *startDate = [[NSDateComponents alloc] initWithYear:2016 month:01 day:01];

    {
        OCKCareSchedule *schedule = [OCKCareSchedule weeklyScheduleWithStartDay:startDate occurrencesOnEachDay:@[@1,@1,@1,@0,@1,@1,@1]];
        UIColor *color = OCKBlueColor();
        OCKCarePlanActivity *evaluation = [[OCKCarePlanActivity alloc] initWithIdentifier:PainEvaluation
                                                                                     type:OCKCarePlanActivityTypeAssessment
                                                                                    title:@"Pain"
                                                                                     text:@"Lower back"
                                                                                tintColor:color
                                                                                 schedule:schedule];
        [evaluations addObject:evaluation];
    }
    
    {
        OCKCareSchedule *schedule = [OCKCareSchedule weeklyScheduleWithStartDay:startDate occurrencesOnEachDay:@[@1,@1,@1,@1,@1,@1,@1]];
        UIColor *color = OCKGreenColor();
        OCKCarePlanActivity *evaluation = [[OCKCarePlanActivity alloc] initWithIdentifier:MoodEvaluation
                                                                                     type:OCKCarePlanActivityTypeAssessment
                                                                                    title:@"Mood"
                                                                                     text:@"Survey"
                                                                                tintColor:color
                                                                                 schedule:schedule];
        [evaluations addObject:evaluation];
    }
    
    {
        OCKCareSchedule *schedule = [OCKCareSchedule weeklyScheduleWithStartDay:startDate occurrencesOnEachDay:@[@1,@0,@0,@1,@1,@0,@0]];
        UIColor *color = OCKRedColor();
        OCKCarePlanActivity *evaluation = [[OCKCarePlanActivity alloc] initWithIdentifier:SleepQualityEvaluation
                                                                                     type:OCKCarePlanActivityTypeAssessment
                                                                                    title:@"Sleep Quality"
                                                                                     text:@"Last night"
                                                                                tintColor:color
                                                                                 schedule:schedule];
        [evaluations addObject:evaluation];
    }
    
    {
        OCKCareSchedule *schedule = [OCKCareSchedule weeklyScheduleWithStartDay:startDate occurrencesOnEachDay:@[@0,@1,@0,@1,@0,@1,@0]];
        UIColor *color = OCKPurpleColor();
        OCKCarePlanActivity *evaluation = [[OCKCarePlanActivity alloc] initWithIdentifier:BloodPressureEvaluation
                                                                                     type:OCKCarePlanActivityTypeAssessment
                                                                                    title:@"Blood Pressure"
                                                                                     text:@"After dinner"
                                                                                tintColor:color
                                                                                 schedule:schedule];
        [evaluations addObject:evaluation];
    }
    
    {
        OCKCareSchedule *schedule = [OCKCareSchedule weeklyScheduleWithStartDay:startDate occurrencesOnEachDay:@[@1,@1,@1,@1,@1,@1,@1]];
        UIColor *color = OCKYellowColor();
        OCKCarePlanActivity *evaluation = [[OCKCarePlanActivity alloc] initWithIdentifier:WeightEvaluation
                                                                                     type:OCKCarePlanActivityTypeAssessment
                                                                                    title:@"Weight"
                                                                                     text:@"Before breakfast"
                                                                                tintColor:color
                                                                                 schedule:schedule];
        [evaluations addObject:evaluation];
    }
    
    _evaluations = [evaluations copy];
}

- (void)presentViewControllerForEvaluationIdentifier:(NSString *)identifer {
    ORKOrderedTask *task;
    
    if ([identifer isEqualToString:PainEvaluation]) {
        ORKScaleAnswerFormat *format = [ORKScaleAnswerFormat scaleAnswerFormatWithMaximumValue:10
                                                                                  minimumValue:1
                                                                                  defaultValue:NSIntegerMax
                                                                                          step:1
                                                                                      vertical:NO
                                                                       maximumValueDescription:@"Good"
                                                                       minimumValueDescription:@"Bad"];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"pain"
                                                                      title:@"How was your lower back pain today?"
                                                                     answer:format];
        step.optional = NO;
    
        task = [[ORKOrderedTask alloc] initWithIdentifier:@"pain" steps:@[step]];
    } else if ([identifer isEqualToString:MoodEvaluation]) {
        ORKScaleAnswerFormat *format = [ORKScaleAnswerFormat scaleAnswerFormatWithMaximumValue:10
                                                                                  minimumValue:1
                                                                                  defaultValue:NSIntegerMax
                                                                                          step:1
                                                                                      vertical:NO
                                                                       maximumValueDescription:@"Good"
                                                                       minimumValueDescription:@"Bad"];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"mood"
                                                                      title:@"How was your mood today?"
                                                                     answer:format];
        step.optional = NO;
        
        task = [[ORKOrderedTask alloc] initWithIdentifier:@"mood" steps:@[step]];
        
    } else if ([identifer isEqualToString:SleepQualityEvaluation]) {
        ORKScaleAnswerFormat *format = [ORKScaleAnswerFormat scaleAnswerFormatWithMaximumValue:10
                                                                                  minimumValue:1
                                                                                  defaultValue:NSIntegerMax
                                                                                          step:1
                                                                                      vertical:NO
                                                                       maximumValueDescription:@"Good"
                                                                       minimumValueDescription:@"Bad"];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"sleepQuality"
                                                                      title:@"How was your sleep quality?"
                                                                     answer:format];
        step.optional = NO;
        
        task = [[ORKOrderedTask alloc] initWithIdentifier:@"sleepQuality" steps:@[step]];
    } else if ([identifer isEqualToString:BloodPressureEvaluation]) {
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:@"bloodPressure" title:@"Input your blood pressure" text:nil];
       
        NSMutableArray *items = [NSMutableArray new];
        
        {
            HKQuantityType *healthKitType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];
            ORKHealthKitQuantityTypeAnswerFormat *format = [ORKHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:healthKitType
                                                                                                                         unit:[HKUnit millimeterOfMercuryUnit]
                                                                                                                        style:ORKNumericAnswerStyleInteger];
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"systolicBloodPressure"
                                                                   text:@"Systolic"
                                                           answerFormat:format
                                                               optional:NO];
            [items addObject:item];
        }
        
        {
            HKQuantityType *healthKitType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic];
            ORKHealthKitQuantityTypeAnswerFormat *format = [ORKHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:healthKitType
                                                                                                                         unit:[HKUnit millimeterOfMercuryUnit]
                                                                                                                        style:ORKNumericAnswerStyleInteger];
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"diastolicBloodPressure"
                                                                   text:@"Diastolic"
                                                           answerFormat:format
                                                               optional:NO];
            [items addObject:item];
        }
        
        step.formItems = items;
        step.optional = NO;
        
        task = [[ORKOrderedTask alloc] initWithIdentifier:@"bloodPressure" steps:@[step]];
    } else if ([identifer isEqualToString:WeightEvaluation]) {
        HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
        ORKHealthKitQuantityTypeAnswerFormat *format = [ORKHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:quantityType
                                                                                                                     unit:[HKUnit poundUnit]
                                                                                                                    style:ORKNumericAnswerStyleDecimal];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"weight"
                                                                      title:@"Input your weight"
                                                                     answer:format];
        step.optional = NO;
        
        task = [[ORKOrderedTask alloc] initWithIdentifier:@"bloodPressure" steps:@[step]];
    }
    
    ORKTaskViewController *taskViewController = [[ORKTaskViewController alloc] initWithTask:task taskRunUUID:nil];
    taskViewController.delegate = self;
    
    [_tabBarController presentViewController:taskViewController animated:YES completion:nil];
}

- (void)updateEvaluationEvent:(OCKCarePlanEvent *)event withTaskResult:(ORKTaskResult *)result {
    NSString *identifier = event.activity.identifier;
    
    if ([identifier isEqualToString:PainEvaluation] ||
        [identifier isEqualToString:MoodEvaluation] ||
        [identifier isEqualToString:SleepQualityEvaluation]) {
        // Fetch the result value.
        ORKStepResult *stepResult = (ORKStepResult*)[result firstResult];
        ORKScaleQuestionResult *questionResult = (ORKScaleQuestionResult*)[stepResult firstResult];
        NSNumber *value = questionResult.scaleAnswer;
        
        OCKCarePlanEventResult *result = [[OCKCarePlanEventResult alloc] initWithValueString:value.stringValue
                                                                                  unitString:@"out of 10"
                                                                                    userInfo:nil];
        
        [_store updateEvent:event
                 withResult:result
                      state:OCKCarePlanEventStateCompleted
                 completion:^(BOOL success, OCKCarePlanEvent * _Nonnull event, NSError * _Nonnull error) {
                     NSAssert(success, error.localizedDescription);
                 }];
    
    } else if ([identifier isEqualToString:BloodPressureEvaluation]) {
        // Fetch the result value.
        ORKStepResult *stepResult = (ORKStepResult*)[result firstResult];
        NSArray <ORKResult *> *results = stepResult.results;
        
        ORKNumericQuestionResult *result1 = (ORKNumericQuestionResult *)results[0];
        NSNumber *systolicValue = result1.numericAnswer;
        ORKNumericQuestionResult *result2 = (ORKNumericQuestionResult *)results[1];
        NSNumber *diastolicValue = result2.numericAnswer;
        
        OCKCarePlanEventResult *result = [[OCKCarePlanEventResult alloc] initWithValueString:[NSString stringWithFormat:@"%@/%@", systolicValue.stringValue, diastolicValue.stringValue]
                                                                                  unitString:@"mmHg"
                                                                                    userInfo:nil];
        
        [_store updateEvent:event
                 withResult:result
                      state:OCKCarePlanEventStateCompleted
                 completion:^(BOOL success, OCKCarePlanEvent * _Nonnull event, NSError * _Nonnull error) {
                     NSAssert(success, error.localizedDescription);
                 }];
        
    } else if ([identifier isEqualToString:WeightEvaluation]) {
        // Fetch the result value.
        ORKStepResult *stepResult = (ORKStepResult*)[result firstResult];
        NSArray <ORKResult *> *results = stepResult.results;

        ORKNumericQuestionResult *numericResult = (ORKNumericQuestionResult *)results[0];
        NSNumber *weightValue = numericResult.numericAnswer;
        
        OCKCarePlanEventResult *result = [[OCKCarePlanEventResult alloc] initWithValueString:weightValue.stringValue
                                                                                  unitString:@"lbs"
                                                                                    userInfo:nil];
        
        [_store updateEvent:event
                 withResult:result
                      state:OCKCarePlanEventStateCompleted
                 completion:^(BOOL success, OCKCarePlanEvent * _Nonnull event, NSError * _Nonnull error) {
                     NSAssert(success, error.localizedDescription);
                 }];
    }
}


#pragma mark - Evaluation Table View Delegate (OCKEvaluationTableViewDelegate)

- (void)tableViewDidSelectRowWithEvaluationEvent:(OCKCarePlanEvent *)evaluationEvent {
    NSInteger validState = (evaluationEvent.state == OCKCarePlanEventStateInitial || evaluationEvent.state == OCKCarePlanEventStateNotCompleted) ||
    (evaluationEvent.state == OCKCarePlanEventStateCompleted && evaluationEvent.activity.resultResettable);

    if (validState) {
        NSString *identifier = evaluationEvent.activity.identifier;
        [self presentViewControllerForEvaluationIdentifier:identifier];
    }
}


#pragma mark - Task View Controller Delegate (ORKTaskViewControllerDelegate)

- (void)taskViewController:(ORKTaskViewController *)taskViewController didFinishWithReason:(ORKTaskViewControllerFinishReason)reason error:(NSError *)error {
    if (reason == ORKTaskViewControllerFinishReasonCompleted) {
        OCKCarePlanEvent *evaluationEvent = _evaluationViewController.lastSelectedEvaluationEvent;
        ORKTaskResult *taskResult = taskViewController.result;
        [self updateEvaluationEvent:evaluationEvent withTaskResult:taskResult];
    }
    
    [taskViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
