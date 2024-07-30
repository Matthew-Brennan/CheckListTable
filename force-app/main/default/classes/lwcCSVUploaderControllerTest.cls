@isTest
public class lwcCSVUploaderControllerTest{

    Static String base64Data = '\"WBS,Name,Notes,Budgeted Time,Actual Hours\\r\\n1,task 1,,5.00,4.00,\\r\\n"';

    static testmethod void testfileupload(){

        //create a new Checklist__c
        Checklist__c testList = new Checklist__c();
        testList.Name = 'Test List';
        insert testList;
        

        Test.startTest();
        lwcCSVUploaderController.saveFile(base64Data, testList.Id);
        Test.stopTest();
    }
}