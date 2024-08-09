@isTest
public class lwcCSVUploaderControllerTest {


    @isTest
    static void testinsertNewElement() {

        //Create a temporary checklist item
        Checklist__c testItem = new Checklist__c();
        testItem.Name = 'Test Item';
        insert testItem;

        // Prepare test data
        String cdbId = testItem.Id;

        Decimal budgetedTime = 5;
        Decimal actualTime = 2.3;
        Decimal wbs = 1.0;
        string  taskName = 'Task Name';

        // Call the method with mock data
        Test.startTest();
        try {
            Checklist_Item__c newTask = lwcCSVUploaderController.insertNewElement(wbs, budgetedTime, actualTime, taskName, cdbId);
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Script-thrown exception'));
        }
        Test.stopTest();

        // Verify that 1 record has been inserted
        List<Checklist_Item__c> tasks = [SELECT Id FROM Checklist_Item__c WHERE Checklist__c = :cdbId];
        System.assertEquals(1, tasks.size());
    }

    @isTest
    static void testinsertNewElemenWithBadData() {

        //Create a temporary checklist item
        Checklist__c testItem = new Checklist__c();
        testItem.Name = 'Test Item';
        insert testItem;

        // Prepare test data
        String cdbId = testItem.Id;

        Decimal budgetedTime = 5.6;
        Decimal actualTime = 2.3;
        Decimal wbs = 1.0;
        //string name will be too long and cause it to fail
        string  taskName = 'Task NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask NameTask Name';

        // Call the method with mock data
        Test.startTest();
        try {
            Checklist_Item__c newTask = lwcCSVUploaderController.insertNewElement(wbs, budgetedTime, actualTime, taskName, cdbId);
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Script-thrown exception'));
        }
        Test.stopTest();

        // Verify that 0 record has been inserted
        List<Checklist_Item__c> tasks = [SELECT Id FROM Checklist_Item__c WHERE Checklist__c = :cdbId];
        System.assertEquals(0, tasks.size());
    }
}
