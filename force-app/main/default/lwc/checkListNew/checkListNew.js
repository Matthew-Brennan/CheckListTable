import { LightningElement, api } from 'lwc';
import LightningModal from 'lightning/modal'; // Importing Lightning Modal for creating modal dialogs
import newChecklist from '@salesforce/apex/checkListNewController.newCheckList';
export default class CheckListNew extends LightningModal {

    @api caseId;       // Expose case record ID to the component to receive data from the parent component
    //create the checklist
    //insert checklist into checklist field on the current case

    handleNewChecklist(){
        console.log('Hello');
        }
}