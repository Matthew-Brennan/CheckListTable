import { LightningElement, wire, api, track } from 'lwc';
import getCheckListItems from '@salesforce/apex/ChecklistController.getChecklistItems';
import createNewTask from "@salesforce/apex/ChecklistController.updateTasks";
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { notifyRecordUpdateAvailable } from "lightning/uiRecordApi";

const columns = [
    { label: 'Task', fieldName: 'Name', editable: true },
    { label: 'WBS', fieldName: 'WBS__c', editable: true },
    { label: 'Status', fieldName: 'Status__c', editable: true },
    { label: 'Budgeted Time', fieldName: 'Budgeted_Time__c', editable: true },
    { label: 'Actual Hours', fieldName: 'Actual_Hours__c', editable: true },
    { label: 'Delta', fieldName: 'Delta__c', editable: true }
];

const actions = [
    { label: 'New Task', name: 'new' },
];

export default class ChecklistDataTable extends LightningElement {
    @track checkList = [];
    columns = columns;
    @api recordId;
    draftValues = [];
    error;
    
    @wire(getCheckListItems, { recordId: '$recordId' })
    wiredCheckList(result) {
        this.wiredCheckListResult = result;
        if (result.data) {
            this.checkList = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.checkList = [];
        }
    }


    async handleNewTask() {
        try {
            const result = await createNewTask({ recordId: this.recordId });
            console.log("Apex insert result: ", result);
            console.log("TYPE: " + typeof result)
            if(typeof result == Object){
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



    async handleSave(event) {
        const updatedFields = event.detail.draftValues;

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


        // requery to refresh the data
        refreshData() {
            return refreshApex(this.wiredCheckListResult);
        }
}
