@isTest
public with sharing class checklistTimeEntryControllerTest {
    public checklistTimeEntryControllerTest() {

    }

    @isTest
    public static void checklistTimeEntryControllerTest () {

        // Create and insert a test Checklist record
        Checklist__c testList = new Checklist__c();
        testList.Name = 'Test List';
        insert testList;

        // Create and insert a test Checklist_Item record associated with the test Checklist
        Checklist_Item__c item = new Checklist_Item__c();
        item.Name = 'Test Item';
        item.Status__c = false;
        item.Checklist__c = testList.Id;
        insert item;

        Checklist_Item__c item2 = new Checklist_Item__c();
        item2.Name = 'returned Item';
        item2.Status__c = true;
        item2.WBS__c = 1.0;
        item2.Actual_Hours__c = 1.5;
        item2.Checklist__c = testList.Id;
        insert item2;

        Case testCase =  new Case();
        testCase.Checklist__c = testList.Id;
        insert testCase;

        list<Checklist_Item__c> itemRecieved = new list<Checklist_Item__c>();
        list<Checklist_Item__c> failedItem = new list<Checklist_Item__c>();

        Test.startTest();
        itemRecieved = checklistTimeEntryController.checklistTimeEntryController(testList.id);

        try{
            failedItem = checklistTimeEntryController.checklistTimeEntryController(null);  //returns error due to no CheckLists Items
            
        }catch (AuraHandledException ex){
            System.assertEquals('Script-thrown excepti', ex.getMessage());
        }
        Test.stopTest();

        System.debug(itemRecieved);

    }

    @isTest 
    public static void timeEntryUpdateTest () {
        // Create and insert a test Checklist record
        Checklist__c testList = new Checklist__c();
        testList.Name = 'Test List';
        insert testList;

        Checklist_Item__c item = new Checklist_Item__c();
        item.Name = 'Test Item';
        item.Status__c = false;
        item.Checklist__c = testList.Id;
        insert item;

        Checklist_Item__c item2 = new Checklist_Item__c();
        item2.Name = 'returned Item';
        item2.Status__c = true;
        item2.WBS__c = 1.0;
        item2.Actual_Hours__c = 0;
        item2.Checklist__c = testList.Id;
        insert item2;

        Decimal totalHours = 1.5;

        string passedId = item2.id;


        Test.startTest();
        checklistTimeEntryController.updateCheckListEntry(passedId, totalHours);

        try{
            checklistTimeEntryController.updateCheckListEntry(null, null);  //returns error due to no CheckLists Items
        }catch (AuraHandledException ex){
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
        Test.stopTest();
    }
}