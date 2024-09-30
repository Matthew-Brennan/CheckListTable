public with sharing class nameAndSignatureController {

    @AuraEnabled
    public static String saveTheFile(Id parentId, String base64Data) {
        try {
            // Decoding the base64 string to a Blob
            Blob decodedBlob = EncodingUtil.base64Decode(base64Data.substring(base64Data.indexOf(',') + 1));

            // Setting the filename with the current timestamp to make it unique
            Datetime now = Datetime.now();
            String formattedFileName = 'Signature Capture ' + now.format('yyyy-MM-dd_HH-mm-ss') + '.jpg';

            // Creating a new ContentVersion record
            ContentVersion contentVersionRec = new ContentVersion();
            contentVersionRec.Title = formattedFileName;
            contentVersionRec.PathOnClient = '/' + formattedFileName;
            contentVersionRec.FirstPublishLocationId = parentId;
            contentVersionRec.VersionData = decodedBlob;
            contentVersionRec.IsMajorVersion = true;

            // Inserting the ContentVersion record
            insert contentVersionRec;

            return contentVersionRec.Id;
        } catch (Exception e) {
            // Handling exceptions and returning the error message
            System.debug('Error in saveTheFile: ' + e.getMessage());
            return 'Error: ' + e.getMessage();
        }
    }
}

