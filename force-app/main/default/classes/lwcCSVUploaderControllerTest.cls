@isTest
public class lwcCSVUploaderControllerTest {

    @isTest
    static void testSaveFile() {
        // Prepare test data
        String cdbId = 'someCdbId';
        
        // Create a sample 2D array and convert it to a JSON string
        List<List<Object>> array2D = new List<List<Object>> {
            new List<Object> { 1, 'Task 1', '', 5.0, 2.0 },
            new List<Object> { 2, 'Task 2', '', 8.0, 6.0 }
        }; 
        String jsonArray = JSON.serialize(array2D);

        // Start test context
        Test.startTest();

        // Call the saveFile method
        List<Checklist_Item__c> result = lwcCSVUploaderController.saveFile(jsonArray, cdbId);

        // End test context
        Test.stopTest();

        // Verify the results
        System.assertEquals(2, result.size(), 'There should be 2 checklist items created.');

        // Verify the values of the first checklist item
        Checklist_Item__c item1 = result[0];
        System.assertEquals(1, item1.WBS__c, 'WBS of the first item should be 1.');
        System.assertEquals('Task 1', item1.Name, 'Name of the first item should be "Task 1".');
        System.assertEquals(5.0, item1.Budgeted_Time__c, 'Budgeted time of the first item should be 5.0.');
        System.assertEquals(2.0, item1.Actual_Hours__c, 'Actual hours of the first item should be 2.0.');
        System.assertEquals(cdbId, item1.Checklist__c, 'Checklist ID of the first item should match.');

        // Verify the values of the second checklist item
        Checklist_Item__c item2 = result[1];
        System.assertEquals(2, item2.WBS__c, 'WBS of the second item should be 2.');
        System.assertEquals('Task 2', item2.Name, 'Name of the second item should be "Task 2".');
        System.assertEquals(8.0, item2.Budgeted_Time__c, 'Budgeted time of the second item should be 8.0.');
        System.assertEquals(6.0, item2.Actual_Hours__c, 'Actual hours of the second item should be 6.0.');
        System.assertEquals(cdbId, item2.Checklist__c, 'Checklist ID of the second item should match.');
    }

    @isTest
    static void testSaveFileWithInvalidData() {
        // Prepare test data
        String cdbId = 'someCdbId';

        // Create a sample invalid 2D array (e.g., missing some required fields) and convert it to a JSON string
        List<List<Object>> array2D = new List<List<Object>> {
            new List<Object> { null, null, 5.0, 2.0 }  // Invalid row with null values for required fields
        };
        String jsonArray = JSON.serialize(array2D);

        // Start test context
        Test.startTest();

        // Call the saveFile method and expect it to not throw an exception
        List<Checklist_Item__c> result = lwcCSVUploaderController.saveFile(jsonArray, cdbId);

        // End test context
        Test.stopTest();

        // Verify that no records were created due to invalid data
        System.assertEquals(0, result.size(), 'No checklist items should be created with invalid data.');
    }
}
