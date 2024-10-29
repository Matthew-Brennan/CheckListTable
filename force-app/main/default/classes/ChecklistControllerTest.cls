@isTest
private class ChecklistControllerTest {

    //two instances are needed to test, 1 with a case 1 with a checklist
    @isTest
    static void testgetChecklistItems(){
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

        Case testCase = new Case();
        testCase.Subject = 'test case';
        testCase.Checklist__c = testList.Id;
        insert testCase;


        Test.startTest();
            ChecklistController.getChecklistItems(testList.Id);   //passes
            ChecklistController.getChecklistItems(testCase.Id);   //Passes

            try{
                ChecklistController.getChecklistItems('50000000');  //returns error due to no CheckLists Items
            }catch (AuraHandledException ex){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
        Test.stopTest();  // End the test context
    }

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
        try{
            ChecklistController.deleteTasks(null);  //returns error 
        }catch (AuraHandledException ex){
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
        Test.stopTest();  // End the test context
        
    }

    // @isTest
    // static void testupdateTaks(){
    //     // Create and insert a test Checklist record
    //     Checklist__c testList = new Checklist__c();
    //     testList.Name = 'Test List';
    //     insert testList;

    //     // Create and insert a test Checklist_Item record associated with the test Checklist
    //     Checklist_Item__c item = new Checklist_Item__c();
    //     item.Name = 'Test Item';
    //     item.Status__c = false;
    //     item.Checklist__c = testList.Id;
    //     insert item;
    //     item.Name = 'CHANGED NAME Item';

    //     // Checklist_Item__c item2 = new Checklist_Item__c();
    //     // item2.Name = 'CHANGED';
    //     // item2.Status__c = false;
    //     // item2.Checklist__c = testList.Id;
    //     // insert item2;

    //     string data = json.serialize(item);
        
    // // Start the test context to measure the execution of the code
    //     Test.startTest();
    //     ChecklistController.updateTasks(data);
    //     Test.stopTest();  // End the test context

    // }

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

        try{
            ChecklistController.getTypeOfObject(null);  //returns error 
        }catch (AuraHandledException ex){
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
        Test.stopTest();  // End the test context

    }

    @isTest
    static void testGetUser() {
        // Get a standard profile instead of using hardcoded ID
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        
        // Create test role
        UserRole testRole = new UserRole(
            DeveloperName = 'TestRole',
            Name = 'Test Role'
        );
        insert testRole;
    
        // Create test user with the profile
        User testUser = new User(
            FirstName = 'Test22',
            LastName = 'User22',
            UserRoleId = testRole.Id,
            Username = 'test22' + DateTime.now().getTime() + '@test.ca', // Make unique
            Email = 'test@test.ca',
            Alias = 'test',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_CA',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
    
        System.runAs(testUser) {
            Test.startTest();
            
            // Test valid user ID scenario
            String result = ChecklistController.getUserInfo(testUser.Id);
            System.assertNotEquals(null, result, 'User info should not be null');
            
            // Test null user ID scenario
            try {
                ChecklistController.getUserInfo(null);
                System.assert(false, 'Expected exception was not thrown');
            } catch (AuraHandledException ex) {
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            
            Test.stopTest();
        }
    }
    @isTest
    static void testUpdateTasksSuccess() {

         // Create and insert a test Checklist record
        Checklist__c testList = new Checklist__c();
        testList.Name = 'Test List';
        insert testList;
        
        List<Checklist_Item__c> testItems = new List<Checklist_Item__c>();
        for (Integer i = 0; i < 3; i++) {
            testItems.add(new Checklist_Item__c(
                Name = 'Test Item ' + i,
                Status__c = false,
                Checklist__c = testList.Id
            ));
        }
        insert testItems;

        // Prepare update data
        List<Checklist_Item__c> updatedItems = new List<Checklist_Item__c>();
        for (Checklist_Item__c item : testItems) {
            updatedItems.add(new Checklist_Item__c(
                Id = item.Id,
                Status__c = true,
                Checklist__c = testList.Id
            ));
        }

        // Convert to JSON
        String jsonData = JSON.serialize(updatedItems);

        // Call the method
        Test.startTest();
        String result = ChecklistController.updateTasks(JSON.deserializeUntyped(jsonData));

        try{
            ChecklistController.updateTasks(null);  //returns error 
        }catch (AuraHandledException ex){
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
        Test.stopTest();

        // Assert the result
        System.assertEquals('Success: tasks updated successfully', result, 'Update should be successful');

        // Verify the updates
        List<Checklist_Item__c> verifyItems = [SELECT Id, Status__c FROM Checklist_Item__c WHERE Id IN :testItems];
        for (Checklist_Item__c item : verifyItems) {
            System.assertEquals(true, item.Status__c, 'Status should be updated to In Progress');
        }
    }

    
    @isTest
    static void testGetCaseInfo() {
        // Create and insert a test Case record
        Case testCase = new Case();
        testCase.Billing_Company__c = 'Edge';
        insert testCase;

        // Start the test context to measure the execution of the code
        Test.startTest();
        ChecklistController.getCaseInfo(testCase.Id);
        try{
            ChecklistController.getCaseInfo(null);  //returns error 
        }catch (AuraHandledException ex){
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
        Test.stopTest();  // End the test context
    }

    @isTest
    static void testGetCaseTOS() {
        // Create and insert a test Case record
        Case testCase = new Case();
        testCase.Type_of_Support__c = 'Sales';
        insert testCase;

        // Start the test context to measure the execution of the code
        Test.startTest();
        ChecklistController.getTOS(testCase.Id);
        try{
            ChecklistController.getTOS(null);  //returns error 
        }catch (AuraHandledException ex){
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
        Test.stopTest();  // End the test context
    }

}
