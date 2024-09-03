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
        
        // You can add assertions here to verify that the item was deleted as expected
    }
}
