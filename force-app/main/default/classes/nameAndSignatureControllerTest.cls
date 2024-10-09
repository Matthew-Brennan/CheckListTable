@IsTest
public class nameAndSignatureControllerTest {

    @TestSetup
    static void setupTestData() {
        // Create test data needed for the tests
        // Example: creating a test Account that will act as the parent for the ContentVersion
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
    }

    @IsTest
    static void testSaveTheFile_Success() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        // Use valid base64 for a test image, ensuring it mimics the correct format
        String base64Data = 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAAAAAAAD';  // truncated for brevity
    
        Test.startTest();
        String result = nameAndSignatureController.saveTheFile(testAccount.Id, base64Data);
        Test.stopTest();
    
        // Query for the inserted ContentVersion
        List<ContentVersion> contentVersionList = [SELECT Id, Title, FirstPublishLocationId, VersionData 
                                                   FROM ContentVersion 
                                                   WHERE Id = :result LIMIT 1];
    
        System.assert(!contentVersionList.isEmpty(), 'ContentVersion record should have been created.');
        ContentVersion contentVersion = contentVersionList[0];
        
        // Assertions to ensure correct record creation
        System.assertEquals(testAccount.Id, contentVersion.FirstPublishLocationId, 'The parent ID should match.');
        System.assert(contentVersion.Title.startsWith('Signature Capture'), 'The file title should start with "Signature Capture".');
        System.assert(contentVersion.VersionData != null, 'The VersionData should not be null.');
    }
    

    @IsTest
    static void testSaveTheFile_Error() {
        // Invalid base64 string to trigger error handling
        String invalidBase64Data = null;
        
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        String result;
    
        // Call the method and check if error message is returned
        Test.startTest();
        
        try{
            result = nameAndSignatureController.saveTheFile(testAccount.Id, invalidBase64Data);
        }catch (AuraHandledException ex){
            // Ensure error message contains "Error" in response
            System.assert(result.contains('Error'), 'The result should contain an error message.');
        }
        Test.stopTest();
        
    }
    
}