public with sharing class ChecklistController {

    //Get the checklist items
    @AuraEnabled(cacheable=true)
    public static List<Checklist_Item__c> getChecklistItems(String recordId) {
        try {
            return [SELECT Id, Name, Status__c, Budgeted_Time__c, Actual_Hours__c, WBS__c, Delta__c
                    FROM Checklist_Item__c
                    WHERE Checklist__r.Id = :recordId
                    ORDER BY WBS__c ASC];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteTasks(List<Id> taskIds){
        try {
            List<Checklist_Item__c> tasksToDelete = [SELECT Id FROM Checklist_Item__c WHERE Id IN :taskIds];
            delete tasksToDelete;
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
        newTask.Budgeted_Time__c = 0.00;
        newTask.Actual_Hours__c = 0.00;
        newTask.Checklist__c = recordId; 
        System.debug('@@@@ ' + newTask);        
        insert newTask;

        return newTask;

       // try { 
       //     return newTask;
        // } catch (Exception e) {
        //     throw new AuraHandledException(e.getMessage());
        // }
    }
}
