@isTest
public class lwcCSVUploaderControllerTest {
    static String base64Data = EncodingUtil.base64Encode(
        Blob.valueOf('WBS,Name,Notes,Budgeted Time,Actual Hours\n1.0,task 1,,5.00,4.00')
    );

    static testmethod void testfileupload() {
        // Create a new Checklist__c
        Checklist__c testList = new Checklist__c();
        testList.Name = 'Test List';
        insert testList;

        Test.startTest();
        lwcCSVUploaderController.saveFile(base64Data, testList.Id);
        Test.stopTest();
    }
}
