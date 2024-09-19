import { api, track, wire } from 'lwc'; // Importing necessary modules from LWC
import insertLine from '@salesforce/apex/lwcCSVUploaderController.insertNewElement'; // Importing Apex method
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; // Importing Toast event to show notifications
import LightningModal from 'lightning/modal'; // Importing Lightning Modal for creating modal dialogs
import getCLI from '@salesforce/apex/checklistTimeEntryController.checklistTimeEntryController'
export default class CheckListTimeEntry extends LightningModal {

    @api caseId;      // Expose case record ID to the component to receive data from the parent component
    @api checklistId  // Expose checklist record ID to the component to receive data from the parent component


    @wire(getCLI, {checklistId: this.checklistId})
    wiredCheckListEntry(result){
        if(result.data){
            console.log(result);
            console.log(result.data);
            console.log(result.data[0]);
        }
    }

    // Invoked when the user clicks the save button; starts the file upload process
    handleSave() {

        console.log('Case: ' + this.caseId);
        console.log('checklist: ' + this.checklistId);
    }

    // Closes the modal window
    handleClose() {
        this.close(); // Close the modal
        console.log('closed');
        return 'saved'; // Return 'saved' as a confirmation
    }  
}
