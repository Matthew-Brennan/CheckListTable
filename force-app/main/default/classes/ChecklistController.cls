public with sharing class ChecklistController {
    @AuraEnabled(cacheable=true)
    public static List<Checklist_Item__c> getChecklistItems(String recordId) {
        try {
            return [SELECT Id, Name, Status__c, Budgeted_Time__c, Actual_Hours__c, WBS__c, Delta__c
                    FROM Checklist_Item__c
                    WHERE Checklist__r.Id = :recordId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string updateTasks(Object data) {
        List<Checklist_Item__c> tasksForUpdate = (List<Checklist_Item__c>) JSON.deserialize(
            JSON.serialize(data),
            List<Checklist_Item__c>.class
        );
        try {
            update tasksForUpdate;
            return 'Success: tasks updated successfully';
        }
        catch (Exception e) {
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }
}
