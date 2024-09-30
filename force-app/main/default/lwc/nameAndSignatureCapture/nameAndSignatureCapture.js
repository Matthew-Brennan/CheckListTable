import { LightningElement, api } from 'lwc';
import insertSignature from '@salesforce/apex/nameAndSignatureController.saveTheFile';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class NameAndSignatureCapture extends LightningElement {
    imgSrc;
    @api recordId;

    renderedCallback() {
        document.fonts.forEach((font) => {
            if (font.family === "Great Vibes" && font.status === "unloaded") {
                // Ensure that the font is loaded so that signature pad could use it.
                font.load();
            }
        });
    }


    @api async saveSignature() {
        const pad = this.template.querySelector("c-signature-pad");
        if (pad) {
            const dataURL = pad.getSignature();
            if (dataURL) {

                console.log(this.recordId);
                try {
                    // Call the Apex method and await its completion
                    const value = await insertSignature({ parentId: this.recordId, base64Data: dataURL });
                    this.imgSrc = dataURL;
                    console.log(this.recordId);
                    console.log(dataURL);
                    console.log(value);
                    // Show success toast message
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Time Report: '+this.recordId+' created! \n +photoID: '+ value ,
                            variant: 'success'
                        })
                    );
                } catch (error) {
                    // Show error toast message
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error saving signature',
                            message: error.body ? error.body.message : error.message,
                            variant: 'error'
                        })
                    );
                    console.error('Error in saveSignature:', error);
                }
            }
        }
    }
    
    clearSignature() {
        const pad = this.template.querySelector("c-signature-pad");
        if (pad) {
            pad.clearSignature();
        }
        this.imgSrc = null;
    }
}