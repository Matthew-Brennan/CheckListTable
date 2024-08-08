import { LightningElement, api, track } from 'lwc';
import saveFile from '@salesforce/apex/lwcCSVUploaderController.saveFile';
import insertLine from '@salesforce/apex/lwcCSVUploaderController.insertNewElement';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Site', fieldName: 'Site', type: 'url' },
    { label: 'Account Source', fieldName: 'AccountSource' }
];

export default class CheckListDataLoader extends LightningElement {
    @api recordId;

    @track columns = columns;
    @track data;
    @track fileName = '';
    @track UploadFile = 'Upload CSV File';
    @track showLoadingSpinner = false;
    @track isTrue = false;

    selectedRecords;
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    formattedCSV = [[]];
    
    MAX_FILE_SIZE = 1500000;

    connectedCallback() {
        console.log('Record ID:', this.recordId);
        if (!this.recordId) {
            console.error('recordId is undefined');
        }
    }

    handleFilesChange(event) {
        if (event.target.files.length > 0) {
        this.filesUploaded = event.target.files;
        this.fileName = this.filesUploaded[0].name;
        }

    }

    handleSave() {

        if (this.filesUploaded.length > 0) {
            this.uploadFile();
        } else {
            this.fileName = 'Please select a CSV file to upload!!';
        }

    }

    uploadFile() {

        if (this.filesUploaded[0].size > this.MAX_FILE_SIZE) {
            console.log('File Size is too large');
            return;
        }

        this.showLoadingSpinner = true;

        this.fileReader = new FileReader();

        this.fileReader.onloadend = () => {
            this.fileContents = this.fileReader.result;
            this.handleCSV();
        };

        this.fileReader.readAsText(this.filesUploaded[0]);

    }

    handleCSV() {

        let lines = [];
        let lines2 = this.fileContents.split('\n');
        lines2.forEach((line, index) => {
        lines.push(line);
        });

        let parsedArray = lines.map(line => this.parseCSVLine(line));

        parsedArray.shift(); // remove the title row
        parsedArray.pop(); // remove the final row that is blank

        console.log('RECORD ID: ' + this.recordId);

        try{
            parsedArray.forEach(element => {   
                insertLine({
                    wbsNum: parseFloat(element[0]),
                    budgetedTime: parseFloat(element[3]),
                    actualTime: parseFloat(element[4]),
                    taskName: element[1],
                    cbdId: this.recordId
            })
            .then(result => {
                            if (result === null || result.length === 0) {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Warning',
                                        message: 'The CSV file does not contain any data',
                                        variant: 'warning',
                                    }),
                                );
                            } else {
                                this.data = result;
                                this.fileName = this.fileName + ' – Uploaded Successfully';
                                this.isTrue = false;
                                this.showLoadingSpinner = false;
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Success!!',
                                        message: this.filesUploaded[0].name + ' – Uploaded Successfully!!!',
                                        variant: 'success',
                                    }),
                                );
                            }
                        })
                        .catch(error => {
                            console.error(error);
                            this.showLoadingSpinner = false;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error while uploading File',
                                    message: error.message,
                                    variant: 'error',
                                }),
                            );
                        });
        })

        } catch (error) {
                console.error(error);
                this.showLoadingSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'An unexpected error occurred.',
                        variant: 'error',
                    }),
                );
            }
        }     
    
        // try {
        //     // Base64 encode the file contents
        //     const jsonArray = JSON.stringify(parsedArray);
        //     saveFile({ jsonArray: jsonArray, cdbId: this.recordId })
        //         .then(result => {
        //             if (result === null || result.length === 0) {
        //                 this.dispatchEvent(
        //                     new ShowToastEvent({
        //                         title: 'Warning',
        //                         message: 'The CSV file does not contain any data',
        //                         variant: 'warning',
        //                     }),
        //                 );
        //             } else {
        //                 this.data = result;
        //                 this.fileName = this.fileName + ' – Uploaded Successfully';
        //                 this.isTrue = false;
        //                 this.showLoadingSpinner = false;
        //                 this.dispatchEvent(
        //                     new ShowToastEvent({
        //                         title: 'Success!!',
        //                         message: this.filesUploaded[0].name + ' – Uploaded Successfully!!!',
        //                         variant: 'success',
        //                     }),
        //                 );
        //             }
        //         })
        //         .catch(error => {
        //             console.error(error);
        //             this.showLoadingSpinner = false;
        //             this.dispatchEvent(
        //                 new ShowToastEvent({
        //                     title: 'Error while uploading File',
        //                     message: error.message,
        //                     variant: 'error',
        //                 }),
        //             );
        //         });
    
        // } catch (error) {
        //     console.error(error);
        //     this.showLoadingSpinner = false;
        //     this.dispatchEvent(
        //         new ShowToastEvent({
        //             title: 'Error',
        //             message: 'An unexpected error occurred.',
        //             variant: 'error',
        //         }),
        //     );
        // }
    // }

    // Function to parse CSV line considering quotes
    parseCSVLine(line) {
        let result = [];
        let current = '';
        let inQuotes = false;
        for (let char of line) {
            if (char === '"') {
                inQuotes = !inQuotes; // Toggle inQuotes flag
            } else if (char === ',' && !inQuotes) {
                result.push(current.trim());
                current = '';
            } else {
                current += char;
            }
        }
        result.push(current.trim()); // Push the last value
        return result;
    }
}