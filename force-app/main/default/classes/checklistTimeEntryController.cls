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

    @AuraEnabled(cacheable=true) 
    public static string updateCheckListEntry (String cliId, Decimal totalHours) {

        try{
            List <Checklist_Item__c> chklstRecord = [SELECT Id, Name, Actual_Hours__c, WBS__c
            FROM Checklist_Item__c
            WHERE Checklist_Item__c.Id = :cliId];

            chklstRecord[0].Actual_Hours__c += totalHours;

            update chklstRecord;

            return 'updated sucessfully';

        } catch (Exception e) {
            // Handle any exceptions and throw a user-friendly error message
            throw new AuraHandledException(e.getMessage());
        }

    }
}