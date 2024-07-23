@isTest
private class ChecklistControllerTest {

@isTest
    static void testNewTask() {
        Checklist__c testList = new Checklist__c();
        testList.Name = 'Test List';
        insert testList;

        // Checklist_Item__c item = new Checklist_Item__c();
        // item.Name = 'Test Item';
        // item.Status__c = false;
        // item.Checklist__c = testList.Id;
        // insert item;
        System.debug('@@@ ' + testList);

        Test.startTest();
        string str = ChecklistController.newTask(testList.Id);
        Test.stopTest();

        System.assertEquals('Success: tasks updated successfully', str, 'Failed');
    }
}