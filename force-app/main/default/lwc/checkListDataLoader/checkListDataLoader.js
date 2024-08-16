import { api, track } from 'lwc';
import insertLine from '@salesforce/apex/lwcCSVUploaderController.insertNewElement';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningModal from 'lightning/modal';

const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Site', fieldName: 'Site', type: 'url' },
    { label: 'Account Source', fieldName: 'AccountSource' }
];

export default class CheckListDataLoader extends LightningModal {
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
    handleClose(){
        this.close()
        console.log('closed');
        return 'saved';
    }

    // Ensure that dispatchEvent is only called with an Event object
handleCSV() {
    let lines = [];
    let lines2 = this.fileContents.split('\n');
    lines2.forEach((line, index) => {
        lines.push(line);
    });

    let parsedArray = lines.map(line => this.parseCSVLine(line));

    parsedArray.shift(); // remove the title row
    parsedArray.pop(); // remove the final row that is blank

    // Wrap the logic in a try-catch block
    try {
        parsedArray.forEach(element => {
            insertLine({
                wbsNum: parseFloat(element[0]),
                budgetedTime: parseFloat(element[3]),
                actualTime: parseFloat(element[4]),
                taskName: element[1],
                cdbId: this.recordId
            })
            .then(result => {
                if (result === null || result.length === 0) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Warning',
                            message: 'The CSV file does not contain any data',
                            variant: 'warning',
                        })
                    );
                } else {
                    this.data = result;
                    this.fileName = ' – Uploaded Successfully';
                    this.isTrue = false;
                    this.showLoadingSpinner = false;
                }
            })
            .catch(error => {
                console.error(error);
                this.showLoadingSpinner = false;
                // this.dispatchEvent(
                //     new ShowToastEvent({
                //         title: 'Error while uploading File',
                //         message: error.message,
                //         variant: 'error',
                //     })
                // );
            });
        });
    } catch (error) {
        console.error(error);
        this.showLoadingSpinner = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'An unexpected error occurred.',
                variant: 'error',
            })
        );
    }
}

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