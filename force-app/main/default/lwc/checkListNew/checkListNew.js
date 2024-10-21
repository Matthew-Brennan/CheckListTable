// In CheckListNew.js
import { LightningElement, api } from 'lwc';
import LightningModal from 'lightning/modal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import newChecklist from '@salesforce/apex/checkListNewController.newCheckList';

export default class CheckListNew extends LightningModal {
    @api caseId;
    clName = '';

    handleName(event) {
        this.clName = event.detail.value;
        console.log('Checklist Name:', this.clName);
    }

    handleSubmit(event) {
        event.preventDefault();
        this.handleNewChecklist();
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    async handleNewChecklist() {
        if (!this.clName) {
            this.showToast(
                'Error',
                'Please enter a checklist name',
                'error'
            );
            return;
        }

        try {
            await newChecklist({caseId: this.caseId, clName: this.clName});
            this.close('success');
        } catch (error) {
            console.error('Error creating checklist:', error);
            this.showToast(
                'Error',
                error.body?.message || 'Error creating checklist',
                'error'
            );
        }
    }
}