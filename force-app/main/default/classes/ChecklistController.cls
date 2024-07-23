public with sharing class ChecklistController {

    //Get the checklist items
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

    //update the changed checklist items
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

    //insert a new blank checklist item
    @AuraEnabled
    public static Checklist_Item__c newTask(String recordId) {
        Checklist_Item__c newTask = new Checklist_Item__c();
        newTask.Name = 'New Task';
        newTask.Status__c = false; 
        newTask.Checklist__r.Id = recordId; 

        System.debug('@@@@ ' + newTask);

        try {
            insert newTask;
            return newTask;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
