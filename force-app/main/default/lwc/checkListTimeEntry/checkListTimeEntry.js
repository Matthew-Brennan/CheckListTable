import { api, track } from 'lwc'; // Importing necessary modules from LWC
import insertLine from '@salesforce/apex/lwcCSVUploaderController.insertNewElement'; // Importing Apex method
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; // Importing Toast event to show notifications
import LightningModal from 'lightning/modal'; // Importing Lightning Modal for creating modal dialogs

export default class CheckListTimeEntry extends LightningModal {

    passedId; // Expose recordId to the component to receive data from the parent component

    // Invoked when the user clicks the save button; starts the file upload process
    handleSave() {
        console.log('saved');
    }

    // Closes the modal window
    handleClose() {
        this.close(); // Close the modal
        console.log('closed');
        return 'saved'; // Return 'saved' as a confirmation
    }  
}
