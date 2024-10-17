import { api, track, wire } from 'lwc'; // Importing necessary modules from LWC
import insertLine from '@salesforce/apex/lwcCSVUploaderController.insertNewElement'; // Importing Apex method
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; // Importing Toast event to show notifications
import LightningModal from 'lightning/modal'; // Importing Lightning Modal for creating modal dialogs
import getCLI from '@salesforce/apex/checklistTimeEntryController.checklistTimeEntryController'
import updateCLI from '@salesforce/apex/checklistTimeEntryController.updateCheckListEntry'


//import TIME_REPORT from '@salesforce/schema/SFDC_Time_Reporting__c'
export default class CheckListTimeEntry extends LightningModal {

    //TODO: actualHours either truncates the decimal or is acting as an integer
    //TODO: update dataloader to match the new layout
    //TODO: Dataloader add field notes

    //TODO: button for new checklist
    //TODO: linking Checklist items into orginal Time Reporting methods
    //TODO: if not a project WBS must be blank

    // clean up html in time entry

    @api caseId;       // Expose case record ID to the component to receive data from the parent component
    @api checklistId;   // Expose checklist record ID to the component to receive data from the parent component
    @api selectedRowID ;//
    @api timeEntry;
    theCase = '';
    theUser = '';
    Tos = '';
    wbsNum = '';
    hoursWorked = 0.00;
    otHours = 0.00;
    chargeOutPos = '';
    chargeOutRate = '';
    billingCompany = '';
    descOfWork = '';
    timeID = this.caseId;
    //Time Reporting Object Fields
    timeReportAPI = 'SFDC_Time_Reporting__c';

    //Todo: get selected checklist items. for each selected open a new modal with its details

    @wire(getCLI, {checklistId: '$checklistId'})
    getCLI(result){ 
        try{
            if(result){
                // console.log(result);
                this.theCase = this.timeEntry[0];
                this.theUser = this.timeEntry[1];
                this.Tos = this.timeEntry[2];
                this.chargeOutPos = this.timeEntry[3];
                this.chargeOutRate = this.timeEntry[4];
                this.billingCompany = this.timeEntry[5];
                this.descOfWork  = this.timeEntry[6];
                this.wbsNum = this.timeEntry[7];
                //this.hoursWorked = this.timeEntry[8];                
            }
        }catch (error){
            console.log("ERROR: "+ error);
        }

    }


    // Invoked when the user clicks the save button; starts the file upload process
    handleSave() {
        this.timeEntry = [];
    }

    // Closes the modal window
    handleClose() {
        this.close(); // Close the modal
        console.log('closed');
        this.timeEntry = [];
        return 'saved'; // Return 'saved' as a confirmation
    } 

    handleHW(event){
        this.hoursWorked = event.detail.value[0];
    }

    handleOT(event){
        this.otHours = event.detail.value[0];
        this.otHours *= 1.5
    }
    
    async handleSubmit() {
        const rowId = this.selectedRowID.toString(); // set the rowId for the Checklist item being updated to a string
        const totalTime = this.hoursWorked + this.otHours; // add the two values of OT hours and regular hours as a decimal

        await updateCLI({cliId: rowId, totalHours: totalTime,});
        this.timeEntry = [];
        await new Promise(resolve => setTimeout(resolve, 1500));
        this.handleClose();       

    }

    async handleTRSuccess(event){
        this.timeID = event.detail.id;

        // Wait for a moment to ensure the record is fully created
        await new Promise(resolve => setTimeout(resolve, 1000));
        // Query the child component (assuming it's present in the template)
        const signatureComponent = this.template.querySelector('c-name-and-signature-capture');

        // Call the saveSignature method from the child component
        if (signatureComponent) {
            await signatureComponent.saveSignature();  // Calling the method from the child component
            
        } else {
            console.error('Signature component not found');
        }
        
    }

}