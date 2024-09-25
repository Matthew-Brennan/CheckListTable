import { api, track, wire } from 'lwc'; // Importing necessary modules from LWC
import insertLine from '@salesforce/apex/lwcCSVUploaderController.insertNewElement'; // Importing Apex method
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; // Importing Toast event to show notifications
import LightningModal from 'lightning/modal'; // Importing Lightning Modal for creating modal dialogs
import getCLI from '@salesforce/apex/checklistTimeEntryController.checklistTimeEntryController'
//import TIME_REPORT from '@salesforce/schema/SFDC_Time_Reporting__c'
export default class CheckListTimeEntry extends LightningModal {

    @api caseId;       // Expose case record ID to the component to receive data from the parent component
    @api checklistId   // Expose checklist record ID to the component to receive data from the parent component
    @api selectedRowID //
    @api timeEntry

    //Time Reporting Object Fields
    timeReportAPI = 'SFDC_Time_Reporting__c';

    renderedCallBack(){
        console.log('Time Report Api: ' + this.timeReportAPI);
        console.log('Selected Row: ' + this.selectedRowID);
    }

    //Todo: get selected checklist items. for each selected open a new modal with its details

    @wire(getCLI, {checklistId: '$checklistId'})
    getCLI(result){ 
        try{
            if(result){
                // console.log(result);
                console.log('Time Report Api: ' + this.timeReportAPI);
                console.log('Selected Row: ' + this.selectedRowID);
                console.log(this.formatTimeEntry());
                
            }
        }catch (error){
            console.log("ERROR: "+ error);
        }

    }

    formatTimeEntry(){
        this.selectedRowID.forEach(element => {
            console.log(element);
            
        });
    }


    // Invoked when the user clicks the save button; starts the file upload process
    handleSave() {
        console.log('Case: ' + this.caseId);
    }

    // Closes the modal window
    handleClose() {
        this.close(); // Close the modal
        console.log('closed');
        return 'saved'; // Return 'saved' as a confirmation
    }  
}
