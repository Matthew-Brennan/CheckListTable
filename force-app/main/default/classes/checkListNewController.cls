public with sharing class checkListNewController {
    public checkListNewController() {

    }

    @AuraEnabled
    public static string newCheckList (String caseId, String clName) {
        

        try{
            Case cse = [SELECT Id
                        FROM Case
                        WHERE Id = :caseId];

            Checklist__c chklst = new Checklist__c();
            chklst.Name = clName;

            insert chklst;

            cse.Checklist__c = chklst.id;
            
            update cse;

            return 'New Checklist Created';

        } catch (Exception e) {
            // Handle any exceptions and throw a user-friendly error message
            throw new AuraHandledException(e.getMessage());
        }

    }
}