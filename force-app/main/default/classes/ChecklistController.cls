public with sharing class ChecklistController {

    // Retrieves checklist items associated with a specific record ID
    // String recordId: the ID of the record page
    @AuraEnabled(cacheable=true)  // Enables this method to be called from Aura or LWC and caches the results
    public static List<Checklist_Item__c> getChecklistItems(String recordId) {
        try {
            //if its not a case object, as cases always start with 500
            if (!recordId.startsWith('500'))
            {
            // Query checklist items related to the provided record ID and order them by WBS__c field
            return [SELECT Id, Name, Status__c, Budgeted_Time__c, Actual_Hours__c, WBS__c, Delta__c
                    FROM Checklist_Item__c
                    WHERE Checklist__r.Id = :recordId
                    ORDER BY WBS__c ASC];
            }
            
            else
            {
                // Query all checklist items and order them by WBS__c field
                Case chklst = [SELECT Id, Checklist__r.Id
                    FROM Case
                    WHERE Id = :recordId];

                return [SELECT Id, Name, Status__c, Budgeted_Time__c, Actual_Hours__c, WBS__c, Delta__c
                FROM Checklist_Item__c
                WHERE Checklist__r.Id = :chklst.Checklist__r.Id
                ORDER BY WBS__c ASC];
            }
        } catch (Exception e) {
            // Handle any exceptions and throw a user-friendly error message
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)  // Enables this method to be called from Aura or LWC and caches the results
    public static String getTypeOfObject(String recordId) {
        try {
            //if its not a case object, as cases always start with 500
            if (!recordId.startsWith('500')){
                return recordId;
            }else{
                // Query all checklist items and order them by WBS__c field
                Case chklst = [SELECT Id, Checklist__r.Id
                    FROM Case
                    WHERE Id = :recordId];

                return chklst.Checklist__r.Id;
            }
        } catch (Exception e) {
            // Handle any exceptions and throw a user-friendly error message
            throw new AuraHandledException(e.getMessage());
        }
    }



    // Deletes a list of checklist items by their IDs
    //List <Id> taskIds: a list of the checked off tasks to be deleted
    @AuraEnabled  // Enables this method to be called from Aura or LWC
    public static void deleteTasks(List<Id> taskIds) {
        try {
            // Query the checklist items to be deleted based on the provided IDs
            List<Checklist_Item__c> tasksToDelete = [SELECT Id FROM Checklist_Item__c WHERE Id IN :taskIds];
            // Delete the queried checklist items
            delete tasksToDelete;
        } catch (Exception e) {
            // Handle any exceptions and throw a user-friendly error message
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Updates the checklist items with the changes provided in the data parameter
    // Object data: a stringifyed JSON of the checklist items to update 
    @AuraEnabled  // Enables this method to be called from Aura or LWC
    public static string updateTasks(Object data) {
        // Deserialize the provided data into a list of Checklist_Item__c records
        List<Checklist_Item__c> tasksForUpdate = (List<Checklist_Item__c>) JSON.deserialize(
            JSON.serialize(data),
            List<Checklist_Item__c>.class
        );

        try {
            // Update the checklist items with the deserialized data
            update tasksForUpdate;
            return 'Success: tasks updated successfully';
        } catch (Exception e) {
            // Return an error message if an exception occurs during the update
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }

    // Inserts a new blank checklist item for a given record ID
    // String recordID: the ID of the record page
    @AuraEnabled  // Enables this method to be called from Aura or LWC
    public static Checklist_Item__c newTask(String recordId) {

        recordId = getTypeOfObject(recordId);
        // Create a new checklist item with default values
        Checklist_Item__c newTask = new Checklist_Item__c();
        newTask.Name = 'New Task';
        newTask.Status__c = false;
        newTask.Budgeted_Time__c = 0.00;
        newTask.Actual_Hours__c = 0.00;
        newTask.Checklist__c = recordId;  // Associate the new task with the provided record ID      
          
        // Insert the new checklist item into the database
        insert newTask;

        // Return the newly created checklist item
        return newTask;
    }

    @AuraEnabled
    public static String getUserInfo(String userId) {
        try {
            // Query for the user's role ID
            List<User> userRoleId = [SELECT UserRoleId FROM User WHERE Id = :userId];
    
            // Check if the user has a role
            if (userRoleId.isEmpty() || userRoleId[0].UserRoleId == null) {
                return 'No role assigned';
            }
    
            // Query the role name based on the role ID
            List<UserRole> userRoleName = [SELECT Name FROM UserRole WHERE Id = :userRoleId[0].UserRoleId];
    
            // Return the role name, or handle the case if no role is found
            if (!userRoleName.isEmpty()) {
                return userRoleName[0].Name;
            } else {
                return 'No role found for the user';
            }
        } catch (Exception e) {
            // Return error message for debugging purposes
            throw new AuraHandledException('Error retrieving user role: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static string getCaseInfo(String caseId) {

        // Query for the user's role ID
        list<Case> cse = [SELECT Billing_Company__c FROM Case WHERE Id = :caseId];

        
        if (!cse.isEmpty()) {
            return cse[0].Billing_Company__c;
        } else {
            return 'No company found for the case';
        }

    }

    @AuraEnabled
    public static string getTOS(String caseId) {

        // Query for the user's role ID
        list<Case> cse = [SELECT Type_of_Support__c FROM Case WHERE Id = :caseId];

        
        if (!cse.isEmpty()) {
            return cse[0].Type_of_Support__c;
        } else {
            return 'No tos found for the case';
        }

    }
}
