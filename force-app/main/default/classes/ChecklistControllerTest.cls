@isTest
private class ChecklistControllerTest {

    // Test method to verify the creation of a new checklist task
    @isTest
    static void testNewTask() {
        // Create and insert a test Checklist record
        Checklist__c testList = new Checklist__c();
        testList.Name = 'Test List';
        insert testList;

        // Start the test context to measure the execution of the code
        Test.startTest();
        // Call the newTask method from ChecklistController with the test Checklist ID
        Object result = ChecklistController.newTask(testList.Id);
        Test.stopTest();  // End the test context
        
        // You can add assertions here to verify the expected outcome of the result
    }

    // Test method to verify the deletion of checklist items
    @isTest
    static void testdeleteTask() {
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
        
        // Prepare a list of item IDs to delete
        List<Id> items = new List<Id>();
        items.add(item.Id);        

        // Start the test context to measure the execution of the code
        Test.startTest();
        // Call the deleteTasks method from ChecklistController with the list of item IDs
        ChecklistController.deleteTasks(items);
        Test.stopTest();  // End the test context
        
    }

    @isTest
    static void testupdateTaks(){
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
        item2.Name = 'CHANGED';
        item2.Status__c = false;
        item2.Checklist__c = testList.Id;
        insert item2;

        string data = json.serialize(item2);
        
    
        ChecklistController.updateTasks(data);

    }

    @isTest
    static void testgetTypeOfObject() {

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

        // Create and insert a test Case record
        Case testCase = new Case();
        testCase.Checklist__c = testList.Id;
        insert testCase;


        // Start the test context to measure the execution of the code
        Test.startTest();
        // Call the deleteTasks method from ChecklistController with the list of item IDs
        string resultCase = ChecklistController.getTypeOfObject(testCase.Id);
        string resultNotCase = ChecklistController.getTypeOfObject(testList.Id);
        Test.stopTest();  // End the test context

    }

    @isTest
    static void testGetUser() {
        // Create and insert a test Role record
        UserRole testRole = new UserRole();
        testRole.Name = 'Test Role';
        insert testRole;

        // Create and insert a test User record
        User testUser = new User();
        testUser.FirstName = 'Test22';
        testUser.LastName = 'User22';
        testUser.UserRoleId = testRole.Id;
        testUser.Username='test22@test.ca'; 
        testUser.Email='test@test.ca'; 
        testUser.Alias='test';
        testUser.TimeZoneSidKey='America/New_York'; 
        testUser.LocaleSidKey='en_CA';
        testUser.EmailEncodingKey='UTF-8';
        testUser.ProfileId='00e32000001NtC9AAK';
        testUser.LanguageLocaleKey='en_US';
        insert testUser;

        // Start the test context to measure the execution of the code
        Test.startTest();
        // Call the newTask method from ChecklistController with the test Checklist ID
        ChecklistController.getUserInfo(testUser.Id);
        Test.stopTest();  // End the test context
        
        // You can add assertions here to verify the expected outcome of the result
    }
}
