public class lwcCSVUploaderController {

    @AuraEnabled
    public static List<Checklist_Item__c> saveFile(String base64Data){
    
        String data = JSON.deserializeUntyped(base64Data).toString();
        List<Checklist_Item__c> lstCCToInsert = new List<Checklist_Item__c>();
        List<String> lstCSVLines = data.split('\n');  
    
        for(Integer i = 1; i < lstCSVLines.size(); i++){
        
            Checklist_Item__c cli = new Checklist_Item__c();
            String csvLine = lstCSVLines[i];
            List<String> csvRowData = new List<String>();
        
            for(String column : csvLine.split(',')){
        
                column = column.replaceAll(':quotes:', '"').replaceAll(':comma:', ',');    
                csvRowData.add(column);  
            }
    
            cli.WBS__c = Decimal.valueOf(csvRowData[0]);
            cli.Name = csvRowData[1];
            cli.Budgeted_Time__c = Decimal.valueOf(csvRowData[3]);
            cli.Actual_Hours__c = Decimal.valueOf(csvRowData[4]);
            lstCCToInsert.add(cli);
        }
    
        if (lstCCToInsert != null && lstCCToInsert.size() > 0){
            insert lstCCToInsert;
        }
    
        return lstCCToInsert;  
    }   
}
