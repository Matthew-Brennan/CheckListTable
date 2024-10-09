import { LightningElement, api } from 'lwc';
import findUsers from '@salesforce/apex/c/customLookupCell.userLookup'

export default class CustomLookupCell extends LightningElement {
    @api value;
    @api placeholder;
    @api uniqueId;

    get hasValue() {
        return this.value && this.value.Id;
    }

    get photoUrl() {
        return this.value && this.value.SmallPhotoUrl ? this.value.SmallPhotoUrl : '/my/default/photo/path.jpg';
    }

    handleClick() {
        // Here you would typically open a lookup dialog
        // For now, we'll just dispatch an event
        const event = new CustomEvent('lookupclick', {
            composed: true,
            bubbles: true,
            detail: {
                uniqueId: this.uniqueId
            }
        });
        this.dispatchEvent(event);
    }
}