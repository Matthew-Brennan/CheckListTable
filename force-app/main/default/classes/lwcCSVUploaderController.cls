public class lwcCSVUploaderController {

    @AuraEnabled
    public static Checklist_Item__c insertNewElement(Decimal wbsNum, Decimal budgetedTime, Decimal actualTime, string taskName, string cdbId) {

        System.debug('wbs ' + wbsNum);
        System.debug('taskName ' + taskName);
        System.debug('cdbId ' + cdbId);
        System.debug('budgetedTime ' + budgetedTime);
        System.debug('actualTime ' + actualTime);

        try { 
            Checklist_Item__c newTask = new Checklist_Item__c();
            newTask.Name = taskName;
            newTask.WBS__c = wbsNum;
            newTask.Budgeted_Time__c = budgetedTime;
            newTask.Actual_Hours__c = actualTime;
            newTask.Checklist__c = cdbId; 
        
            insert newTask;

            return newTask;           
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }    
}
