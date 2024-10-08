import { LightningElement, wire, api, track } from 'lwc';
import getCheckListItems from '@salesforce/apex/ChecklistController.getChecklistItems';
import updateTasks from "@salesforce/apex/ChecklistController.updateTasks";
import createNewTask from "@salesforce/apex/ChecklistController.newTask";
import deleteTasks from "@salesforce/apex/ChecklistController.deleteTasks";
import getTypeOfObj from "@salesforce/apex/ChecklistController.getTypeOfObject";
import getUser from '@salesforce/apex/ChecklistController.getUserInfo';
import getCase from '@salesforce/apex/ChecklistController.getCaseInfo'
import getTOS from '@salesforce/apex/ChecklistController.getTOS';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { notifyRecordUpdateAvailable } from "lightning/uiRecordApi";
import LightningModal from 'lightning/modal';
import csvModal from 'c/checkListDataLoader'
import timeEntryModal from 'c/checkListTimeEntry'
import signaturePad from 'c/nameAndSignatureCapture'
import Id from '@salesforce/user/Id';


const columns = [
    { label: 'Task', fieldName: 'Name', editable: true, sortable: true },
    { label: 'WBS', fieldName: 'WBS__c', editable: true, sortable: true },
    { label: 'Completed', fieldName: 'Status__c', editable: true, type: 'boolean', initialWidth: '55px' },
    { label: 'Budgeted Time', fieldName: 'Budgeted_Time__c', editable: true },
    { label: 'Actual Hours', fieldName: 'Actual_Hours__c', editable: true },
    { label: 'Delta', fieldName: 'Delta__c', editable: true, initialWidth: '55px' },
    { 
        label: 'Assigned To', 
        fieldName: 'Assigned_To__c', 
        type: 'customLookup',
        typeAttributes: {
            placeholder: 'Choose User',
            uniqueId: { fieldName: 'Id' }
        },
        editable: true
    }
];

const actions = [
    { label: 'New Task', name: 'new' },
];



export default class ChecklistDataTable extends LightningElement {
    @track checkList = [];
    columns = columns;
    @api recordId;
    passedChklistId;
    draftValues = [];
    error;
    userId = Id;
    chosenRows
    timeEntry = [];
    TimeEntryBool =  false;

    @track isModalOpen = false; // Track modal state
    @track toTimeEntry = false; // track time entry modal state

    // Need to set these values here idk why
    hideCheckboxColumn = false;
    showRowNumberColumn = false;  
    
    @wire(getCheckListItems, { recordId: '$recordId' })
    wiredCheckList(result) {
        //console.log(this.recordId.substring(0,3));
        this.wiredCheckListResult = result;
        if (result.data) {
            this.checkList = result.data.map(item => ({
                ...item,
                Assigned_To__c: item.Assigned_To__c ? {
                    Id: item.Assigned_To__c,
                    Name: item.Assigned_To__r ? item.Assigned_To__r.Name : '',
                    SmallPhotoUrl: item.Assigned_To__r ? item.Assigned_To__r.SmallPhotoUrl : ''
                } : null
            }));
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.checkList = [];
        }
    }

    handleLookupClick(event) {
        const uniqueId = event.detail.uniqueId;
        // Here you would typically open a modal or navigate to a user selection page
        console.log(`Lookup clicked for row with ID: ${uniqueId}`);
        // For now, we'll just log the event. You'll need to implement the actual user selection logic.
    }

    //Function to handle inserting a new blank task
    async handleNewTask() {
        try {
            const result = await createNewTask({ recordId: this.recordId });
            
            console.log("Apex insert result: ", result);
            console.log("TYPE: " + typeof result)
            if(typeof result == 'object'){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Checklist items updated',
                        variant: 'success'
                    })
                );            
                await refreshApex(this.wiredCheckListResult);
            }else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error inserting task',
                        message: result,
                        variant: 'error'
                    })
                );
            }
            
        } catch(error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error inserting records',
                    message: error.body ? error.body.message : error.message,
                    variant: 'error'
                })
            );
        }
    }


    //function to handle saving changes
    async handleSave(event) {
        const updatedFields = event.detail.draftValues.map(draftValue => {
            const field = {};
            Object.keys(draftValue).forEach(key => {
                if (key === 'Assigned_To__c') {
                    field[key] = draftValue[key].Id;
                } else {
                    field[key] = draftValue[key];
                }
            });
            return field;
        });

        // Prepare the record IDs for notifyRecordUpdateAvailable()
        const notifyChangeIds = updatedFields.map(row => { return { "recordId": row.Id } });

        try {
            // Pass edited fields to the updateTasks Apex controller
            const result = await updateTasks({ data: updatedFields });
            console.log(JSON.stringify("Apex update result: " + result));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Checklist items updated',
                    variant: 'success'
                })
            );

            // Refresh LDS cache and wires
            notifyRecordUpdateAvailable(notifyChangeIds);

            // Display fresh data in the datatable
            await refreshApex(this.wiredCheckListResult);
            
            // Clear all draft values in the datatable
            this.draftValues = [];
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating or refreshing records',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.chosenRows = selectedRows;
        this.selectedRowsID = selectedRows.map(selectedRows => selectedRows.Id);

        if (selectedRows.length == 1)
        {
            this.TimeEntryBool = true;
        }
        else{
            this.TimeEntryBool = false;
        }

    }

    async handleClickDelete() {
        const result = confirm('Are you sure you want to delete the selected tasks?');
        if (result) {
            try {
                await deleteTasks({ taskIds: this.selectedRowsID });
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Tasks deleted successfully',
                        variant: 'success'
                    })
                );
                await refreshApex(this.wiredCheckListResult);

                // Unselect rows after delete
                this.template.querySelector('lightning-datatable').selectedRows = [];
                this.selectedRowsID = [];
            } catch (error) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting tasks',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            }
        }
    }

        // requery to refresh the data
        refreshData() {
            return refreshApex(this.wiredCheckListResult);
        }
        //open the dataloader modal
        async handleModalOpen() {
            try {
                const result = await csvModal.open({
                    label: 'Process CSV File',
                    size: 'medium',
                    description: 'Load your CSV file here',
                    component: 'c-check-list-data-loader',
                    recordId: this.passedChklistId,
                });
            if (result === 'saved') {
                this.refreshData();
            }
        } catch {
            console.log('Error opening modal:', error);
        }
        }

        //open the Time Entry Modal
        async handleTimeOpen() {
            this.timeEntry = []
            const usr = await getUser({userId: this.userId});
            const cse = await getCase({caseId: this.recordId});
            const tos = await getTOS({caseId: this.recordId});

            this.timeEntry.push(this.recordId); //[0] Case
            this.timeEntry.push(this.userId);   //[1] User
            this.timeEntry.push(tos);           //[2] Type of Support

            
            
            if (usr == 'L1'){
                this.timeEntry.push('Jr. Technician Rate');     //[3] Charge Out Position
                this.timeEntry.push('140');                     //[4] Charge Out Rage
            }else{ 
                this.timeEntry.push('Sr. Technician Rate');     //[3] Charge Out Position
                this.timeEntry.push('160');                     //[4] Charge Out Rate
            }
             
            //TODO fix the picklist values for this so it works because the TR and Case equvilant values arent teh same string
             this.timeEntry.push('Eastbay Cloud Services Ltd.');   //[5] Billing Company

             
            if(this.chosenRows){

                this.timeEntry.push(this.chosenRows[0].Name);              //[6] Description of work
                this.chosenRows[0].WBS__c ? this.timeEntry.push(this.chosenRows[0].WBS__c.toString()) : this.timeEntry.push('0');            //[7] WBS if blank put 0
            }   

            try {
                const result = await timeEntryModal.open({
                    label: 'Time Entry',
                    size: 'large',
                    description: 'Time Entry',
                    component: 'c-check-list-time-entry',
                    checklistId: this.passedChklistId,
                    caseId: this.recordId,
                    selectedRowID: this.selectedRowsID,
                    timeEntry: this.timeEntry,
                });
                if (result === 'saved') {
                    this.refreshData();
                }
            } catch {
                console.log('Error opening modal:'+ result.error);
            }
            this.timeEntry = [];
        }
    
        //Close the modal
        async handleModalClose() {
            this.refreshData();
            this.isModalOpen = false;
        }
        async handleTimeClose() {
            this.refreshData();
            this.toTimeEntry = false;
            console.log(this.timeEntry);
            this.timeEntry = [];
            console.log(this.timeEntry);
        }
    
        //save the info added by the modal probably wont use as the info should be added from the modal LWC itself
        async handleModalSave() {

            this.isModalOpen = false;
        }

        async handleTimeSave() {

            this.toTimeEntry = false;
        }

        handleSorting(event) {
            this.sortBy = event.detail.fieldName;
            this.sortDirection = event.detail.sortDirection;
            this.sortData(this.sortBy, this.sortDirection);
        }
    
        sortData(fieldname, direction) {
            let parseData = JSON.parse(JSON.stringify(this.checkList));
            // Return the value stored in the field
            let keyValue = (a) => {
                return a[fieldname];
            };
            // checking reverse direction
            let isReverse = direction === 'asc' ? 1: -1;
            // sorting data
            parseData.sort((x, y) => {
                x = keyValue(x) ? keyValue(x) : ''; // handling null values
                y = keyValue(y) ? keyValue(y) : '';
                // sorting values based on direction
                return isReverse * ((x > y) - (y > x));
            });
            this.checkList = parseData;
        }

        //set the id thats used for uploading modal features to the id of the Checklist even if the component is not on the checklist
         async renderedCallback() {
             this.passedChklistId = await getTypeOfObj({recordId: this.recordId});
     }
}
