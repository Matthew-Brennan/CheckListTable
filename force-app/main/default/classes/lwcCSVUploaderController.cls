public class lwcCSVUploaderController {
    /**********************************************************************
    * Method to insert a new Checklist_Item__c record
    * Parameters:
    * - wbsNum: The WBS (Work Breakdown Structure) number for the task
    * - budgetedTime: The budgeted time for the task
    * - actualTime: The actual time spent on the task
    * - taskName: The name of the task
    * - cdbId: The ID of the related Checklist__c record
    ***********************************************************************/
    @AuraEnabled
    public static Checklist_Item__c insertNewElement(Decimal wbsNum, Decimal budgetedTime, Decimal actualTime, String taskName, String cdbId) {

        // Debugging statements to log the input parameters
        System.debug('wbs ' + wbsNum);
        System.debug('taskName ' + taskName);
        System.debug('cdbId ' + cdbId);
        System.debug('budgetedTime ' + budgetedTime);
        System.debug('actualTime ' + actualTime);

        try { 
            // Create a new Checklist_Item__c record
            Checklist_Item__c newTask = new Checklist_Item__c();
            newTask.Name = taskName;                // Set the task name
            newTask.WBS__c = wbsNum;                // Set the WBS number
            newTask.Budgeted_Time__c = budgetedTime;// Set the budgeted time
            newTask.Actual_Hours__c = actualTime;   // Set the actual time
            newTask.Checklist__c = cdbId;           // Associate the task with the Checklist__c record

            // Insert the new Checklist_Item__c record into the database
            insert newTask;

            // Return the newly created Checklist_Item__c record
            return newTask;           
        } catch (Exception e) {
            // If an exception occurs, handle it by throwing an AuraHandledException with the error message
            throw new AuraHandledException(e.getMessage());
        }
    }    
}
