public class lwcCSVUploaderController {

    @AuraEnabled
    public static Checklist_Item__c insertNewElement(Decimal wbsNum, Decimal budgetedTime, Decimal actualTime, string taskName, String cdbId) {

        system.debug('wbs ' + wbsNum);
        system.debug('taskName ' + taskName);
        system.debug('cdbId ' + cdbId);
        system.debug('budgetedTime ' + budgetedTime);
        system.debug('actualTime ' + actualTime);

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
            throw new AuraHandledException(e.getMessage() +'WBS ' +wbsNum +' bugedted Time ' + budgetedTime + ' actual Time ' + actualTime + ' Task Name '+ taskName+ ' Id '   + cdbId );
        }

    }

    @AuraEnabled
    public static List<Checklist_Item__c> saveFile(String jsonArray, String cdbId) {
        try {
            // Deserialize the JSON array into a list of objects
            List<String> outerList = (List<String>) JSON.deserializeUntyped(jsonArray);

            System.debug(outerList);
            System.debug(outerList[0]);



            // Initialize the list to hold the Checklist_Item__c records
            List<Checklist_Item__c> checklistItems = new List<Checklist_Item__c>();

            // Iterate through each element in the outer list and cast it to a list of objects
            for (Object obj : outerList) {
                List<Object> lstObj = (List<Object>) obj;
                System.debug(lstObj);
                System.debug(lstObj[0]);
                System.debug(lstObj[1]);

                Checklist_Item__c lstCCToInsert = new Checklist_Item__c();
                lstCCToInsert.WBS__c = Decimal.valueOf(String.valueOf(lstObj[0]));
                lstCCToInsert.Name = String.valueOf(lstObj[1]);
                lstCCToInsert.Budgeted_Time__c = Decimal.valueOf(String.valueOf(lstObj[3]));
                lstCCToInsert.Actual_Hours__c = Decimal.valueOf(String.valueOf(lstObj[4]));
                lstCCToInsert.Checklist__c = cdbId;

                // Add the record to the list if it's not empty
                if (lstCCToInsert.Name != null && lstCCToInsert.WBS__c != null) {
                    checklistItems.add(lstCCToInsert);
                }
            }

            // Perform the DML operation to insert the records
            if (!checklistItems.isEmpty()) {
                insert checklistItems;
            }

            // Return the list of inserted records
            return checklistItems;

        } catch (Exception e) {
            System.debug('Error processing CSV file: ' + e.getMessage());
            throw new AuraHandledException('Error processing CSV file: ' + e.getMessage());
        }
    }


    
}
