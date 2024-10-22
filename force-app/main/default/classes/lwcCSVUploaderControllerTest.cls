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
        String cdbId = testItem.Id;
        Decimal budgetedTime = 5;
        Decimal actualTime = 2.3;
        String wbs = '1.0';
        String taskName = 'Task Name';
        String notes = 'Test Notes'; // Added notes parameter

        // Start the test context
        Test.startTest();
        try {
            // Call the insertNewElement method with all required parameters including notes
            Checklist_Item__c newTask = lwcCSVUploaderController.insertNewElement(
                wbs, 
                budgetedTime, 
                actualTime, 
                taskName, 
                cdbId,
                notes
            );
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Script-thrown exception'));
        }
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

        // Prepare test data with an intentionally too-long task name
        String cdbId = testItem.Id;
        Decimal budgetedTime = 5.6;
        Decimal actualTime = 2.3;
        String wbs = '1.0';
        String taskName = 'Task NameTask NameTask Name...';
        String notes = 'test note';

        // Start the test context
        Test.startTest();
        try {
            // Call the insertNewElement method with all required parameters including notes
            Checklist_Item__c newTask = lwcCSVUploaderController.insertNewElement(
                wbs,
                budgetedTime,
                actualTime,
                taskName,
                cdbId,
                notes
            );
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Script-thrown exception'));
        }
        Test.stopTest();
    }
}