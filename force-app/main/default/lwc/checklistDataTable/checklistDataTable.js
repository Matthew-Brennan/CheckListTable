import { LightningElement, wire, api, track } from 'lwc';
import getCheckListItems from '@salesforce/apex/ChecklistController.getChecklistItems';
import hasChecklist from '@salesforce/apex/ChecklistController.hasChecklist';
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
import { loadStyle } from 'lightning/platformResourceLoader';
import LightningModal from 'lightning/modal';
import csvModal from 'c/checkListDataLoader'
import timeEntryModal from 'c/checkListTimeEntry'
import newListModal from 'c/checkListNew'
import signaturePad from 'c/nameAndSignatureCapture'
import Id from '@salesforce/user/Id';
import { NavigationMixin } from 'lightning/navigation';
import tablesccs from '@salesforce/resourceUrl/checklistCSS'


const columns = [
    { label: 'Task', fieldName: 'Name', editable: true, sortable: true },
    { label: 'WBS', fieldName: 'WBS__c', editable: true, sortable: true },
    { label: 'Completed', fieldName: 'Status__c', editable: true, type: 'boolean' },
    { label: 'Budgeted Time', fieldName: 'Budgeted_Time__c', editable: true },
    { label: 'Actual Hours', fieldName: 'Actual_Hours__c', editable: true },
    { label: 'Hours Overbudget', fieldName: 'Delta__c', editable: true },
    { label: 'Notes', fieldName: 'Notes__c', editable: true },
];

const actions = [
    { label: 'New Task', name: 'new' },
];

const PAGE_SIZE = 10;

export default class ChecklistDataTable extends NavigationMixin(LightningElement) {
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
    checkListBool = false;

    @track isModalOpen = false; // Track modal state
    @track toTimeEntry = false; // track time entry modal state
    @track toNewList = false;   // track New List modal state

    // Need to set these values here idk why
    hideCheckboxColumn = false;
    showRowNumberColumn = false;

    // Pagination variables
    @track pageNumber = 1;
    @track totalPages = 0;
    pageSize = PAGE_SIZE;
    

    @wire(hasChecklist, { recordId: '$recordId' })
    wiredCase(result){
        if(result.data){
            this.checkListBool = result.data;
        }else if (result.error) {
            this.error = result.error;

        }
        
    }



    @wire(getCheckListItems, { recordId: '$recordId' })
    wiredCheckList(result) {
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
            this.totalPages = Math.ceil(this.checkList.length / this.pageSize);
            this.paginateData();
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.checkList = [];
            this.paginatedCheckList = [];
        }
    }

    paginateData() {
        const start = (this.pageNumber - 1) * this.pageSize;
        const end = this.pageNumber * this.pageSize;
        this.paginatedCheckList = this.checkList.slice(start, end);
    }

    previousPage() {
        if (this.pageNumber > 1) {
            this.pageNumber = this.pageNumber - 1;
            this.paginateData();
        }
    }

    nextPage() {
        if (this.pageNumber < this.totalPages) {
            this.pageNumber = this.pageNumber + 1;
            this.paginateData();
        }
    }

    get disablePrevious() {
        return this.pageNumber <= 1;
    }

    get disableNext() {
        return this.pageNumber >= this.totalPages;
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'view_details':
                this.navigateToRecordPage(row.Id);
                break;
            default:
                break;
        }
    }

    navigateToRecordPage(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Checklist_Item__c',
                actionName: 'view'
            }
        });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,    // 'success', 'error', 'warning', 'info'
            mode: 'dismissable'  // 'dismissable', 'pester', 'sticky'
        });
        this.dispatchEvent(event);
    }

    handleLookupClick(event) {
        const uniqueId = event.detail.uniqueId;
        // Here you would typically open a modal or navigate to a user selection page
        //console.log(`Lookup clicked for row with ID: ${uniqueId}`);
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
            this.totalPages = Math.ceil(this.checkList.length / this.pageSize);
            this.paginateData();
            
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
            
            if (result === 'Success: tasks updated successfully') {
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
            } else {
                throw new Error(result);
            }
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating records',
                    message: error.message || 'Unknown error occurred',
                    variant: 'error'
                })
            );
        }
        this.paginateData();
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

    //open the dataloader modal
    async handleNewChecklist() {
        try {
            const result = await newListModal.open({
                label: 'Create New Checklist',
                size: 'medium',
                description: 'Create New Checklist',
                component: 'c-check-list-new',
                caseId: this.recordId,
            });
        if (result === 'success') {
            // Success toast
            this.showToast(
                'Success',
                'Checklist created successfully',
                'success'
            );
            await this.handleChecklistClose();
            this.refreshData();
        }
        } catch (error){
            console.log('Error opening modal:');
            // Error toast
            this.showToast(
                'Error',
                error.body?.message || 'Error creating checklist',
                'error'
            );
        }
    }

    //Close the modal
    async handleModalClose() {
        this.refreshData();
        await refreshApex(this.records);
        this.isModalOpen = false;
    }
    async handleTimeClose() {
        this.refreshData();
        this.toTimeEntry = false;
        console.log(this.timeEntry);
        this.timeEntry = [];
        console.log(this.timeEntry);
    }

    async handleChecklistClose() {
        await refreshApex(this.recordId);
        this.refreshData();
        this.toNewList = false;
    }

    //save the info added by the modal probably wont use as the info should be added from the modal LWC itself
    async handleModalSave() {

        this.isModalOpen = false;
    }

    async handleTimeSave() {

        this.toTimeEntry = false;
    }

    async handleNewSave() {

        this.toNewList = false;
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

    connectedCallback(){
        loadStyle(this, tablesccs);
    }

     
}
