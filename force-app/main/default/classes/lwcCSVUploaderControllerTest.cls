@isTest
public class lwcCSVUploaderControllerTest

{

Static String base64Data = '\"Name,Site,Account Source\\r\\nTest1,Test1.com,web\\r\\nTest2,Test2.com,web\\r\\nTest3,Test3.com,web\\r\\nTest4,Test4.com,web\\r\\n\"';

static testmethod void testfileupload(){

Test.startTest();

lwcCSVUploaderController.saveFile(base64Data);

Test.stopTest();

}

}