public class lwcCSVUploaderController {

    @AuraEnabled
    public static List<Checklist_Item__c> saveFile(String base64Data, String cdbId) {
        List<Checklist_Item__c> lstCCToInsert = new List<Checklist_Item__c>();
        try {
            String data = JSON.deserializeUntyped(base64Data).toString();
            List<String> lstCSVLines = data.split('\n');  

            for (Integer i = 1; i < lstCSVLines.size(); i++) {
                Checklist_Item__c cli = new Checklist_Item__c();
                String csvLine = lstCSVLines[i];
                List<String> csvRowData = parseCSVLine(csvLine);

                if (csvRowData.size() >= 5) {
                   // cli.WBS__c = Decimal.valueOf(csvRowData[0]);
                    cli.Name = csvRowData[1];
                 //   cli.Budgeted_Time__c = Decimal.valueOf(csvRowData[3]); 
                  //  cli.Actual_Hours__c = Decimal.valueOf(csvRowData[4]); 
                    cli.Checklist__c = cdbId;
                    lstCCToInsert.add(cli);
                } else {
                    throw new AuraHandledException('CSV row does not have enough columns: ' + csvLine);
                }
            }

            if (!lstCCToInsert.isEmpty()) {
                insert lstCCToInsert;
            }
        } catch (Exception e) {
            System.debug('Error processing CSV file: ' + e.getMessage());
            throw new AuraHandledException('Error processing CSV file: ' + e.getMessage());
        }

        return lstCCToInsert;
    }

    private static List<String> parseCSVLine(String csvLine) {
        List<String> csvRowData = new List<String>();
        Boolean inQuotes = false;
        String currentValue = '';

        for (Integer i = 0; i < csvLine.length(); i++) {
            String c = csvLine.mid(i, 1);

            if (c == '"') {
                inQuotes = !inQuotes;
            } else if (c == ',' && !inQuotes) {
                csvRowData.add(currentValue);
                currentValue = '';
            } else {
                currentValue += c;
            }
        }
        csvRowData.add(currentValue);

        return csvRowData;
    }
}
