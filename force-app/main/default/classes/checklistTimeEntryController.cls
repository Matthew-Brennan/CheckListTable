public with sharing class checklistTimeEntryController {

    @AuraEnabled(cacheable=true) 
    public static List<Checklist_Item__c> checklistTimeEntryController (String checklistId) {

        try{
            return [SELECT Id, Name, Actual_Hours__c, WBS__c
            FROM Checklist_Item__c
            WHERE Checklist__r.Id = :checklistId AND Status__C = TRUE];

        } catch (Exception e) {
            // Handle any exceptions and throw a user-friendly error message
            throw new AuraHandledException(e.getMessage());
        }

    }

    @AuraEnabled
    public static string updateCheckListEntry (String cliId, Decimal totalHours) {

        try {
            // Query the record by Id
            Checklist_Item__c chklstRecord = [SELECT Id, Name, Actual_Hours__c, WBS__c
                                              FROM Checklist_Item__c
                                              WHERE Id = :cliId LIMIT 1];
    
            // Update the Actual_Hours__c field
            chklstRecord.Actual_Hours__c += totalHours;
            
            // Perform the update
            update chklstRecord;
            
    
            return 'updated successfully';
        } catch (Exception e) {
            // Handle any exceptions and throw a user-friendly error message
            throw new AuraHandledException(e.getMessage());
        }

    }
}