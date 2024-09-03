@isTest
public class lwcCSVUploaderControllerTest {

    // Test method to verify the successful insertion of a new Checklist_Item__c record
    @isTest
    static void testinsertNewElement() {

        // Create and insert a temporary Checklist__c record for testing
        Checklist__c testItem = new Checklist__c();
        testItem.Name = 'Test Item';
        insert testItem;

        // Prepare test data
        String cdbId = testItem.Id; // ID of the Checklist__c record
        Decimal budgetedTime = 5;
        Decimal actualTime = 2.3;
        Decimal wbs = 1.0;
        String taskName = 'Task Name';

        // Start the test context
        Test.startTest();
        try {
            // Call the insertNewElement method from lwcCSVUploaderController with test data
            Checklist_Item__c newTask = lwcCSVUploaderController.insertNewElement(wbs, budgetedTime, actualTime, taskName, cdbId);
        } catch (Exception e) {
            // Verify that no exception is thrown; if an exception is caught, it should contain a specific message
            System.assert(e.getMessage().contains('Script-thrown exception'));
        }
        // End the test context
        Test.stopTest();

        // Query to verify that exactly 1 Checklist_Item__c record has been inserted
        List<Checklist_Item__c> tasks = [SELECT Id FROM Checklist_Item__c WHERE Checklist__c = :cdbId];
        System.assertEquals(1, tasks.size(), 'Expected one Checklist_Item__c record to be inserted.');
    }

    // Test method to verify that an exception is thrown when inserting a Checklist_Item__c record with invalid data
    @isTest
    static void testinsertNewElemenWithBadData() {

        // Create and insert a temporary Checklist__c record for testing
        Checklist__c testItem = new Checklist__c();
        testItem.Name = 'Test Item';
        insert testItem;

        // Prepare test data with an intentionally too-long task name to simulate bad data
        String cdbId = testItem.Id; // ID of the Checklist__c record
        Decimal budgetedTime = 5.6;
        Decimal actualTime = 2.3;
        String taskName = 'Task NameTask NameTask Name...'; // Task name is excessively long

        // Start the test context
        Test.startTest();
        try {
            // Call the insertNewElement method from lwcCSVUploaderController with bad data
            Checklist_Item__c newTask = lwcCSVUploaderController.insertNewElement(wbs, budgetedTime, actualTime, taskName, cdbId);
        } catch (Exception e) {
            // Verify that the exception is thrown due to bad data
            System.assert(e.getMessage().contains('Script-thrown exception'));
        }
        // End the test context
        Test.stopTest();

        // Query to verify that no Checklist_Item__c record was inserted due to the bad data
        List<Checklist_Item__c> tasks = [SELECT Id FROM Checklist_Item__c WHERE Checklist__c = :cdbId];
        System.assertEquals(0, tasks.size(), 'Expected no Checklist_Item__c records to be inserted due to bad data.');
    }
}
