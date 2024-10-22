import { api, track } from 'lwc'; // Importing necessary modules from LWC
import insertLine from '@salesforce/apex/lwcCSVUploaderController.insertNewElement'; // Importing Apex method
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; // Importing Toast event to show notifications
import LightningModal from 'lightning/modal'; // Importing Lightning Modal for creating modal dialogs

// Define columns for the data table
const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Site', fieldName: 'Site', type: 'url' },
    { label: 'Account Source', fieldName: 'AccountSource' }
];

export default class CheckListDataLoader extends LightningModal {
    @api recordId; // Expose recordId to the component to receive data from the parent component
    @api chklst;
    @track columns = columns; // Track columns for rendering the data table
    @track data; // Track data to be displayed in the data table
    @track fileName = ''; // Track the name of the uploaded file
    @track UploadFile = 'Upload CSV File'; // Label for the file upload button
    @track showLoadingSpinner = false; // Track loading state to show/hide spinner
    @track isTrue = false; // A generic boolean tracker for state management

    selectedRecords; // Holds selected records (not tracked as no rendering is dependent on it)
    filesUploaded = []; // Holds the files uploaded by the user
    file; // Holds the currently selected file
    fileContents; // Stores the content of the uploaded file
    fileReader; // FileReader instance to read file contents
    content; // Holds formatted content after processing the CSV
    formattedCSV = [[]]; // Initialize a 2D array to store CSV data

    MAX_FILE_SIZE = 1500000; // Maximum file size allowed for upload

    // Handles file selection and updates fileName and filesUploaded properties
    handleFilesChange(event) {
        if (event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = this.filesUploaded[0].name;
        }
    }

    // Invoked when the user clicks the save button; starts the file upload process
    handleSave() {
        if (this.filesUploaded.length > 0) {
            this.uploadFile(); // Proceed with file upload if a file is selected
        } else {
            this.fileName = 'Please select a CSV file to upload!!'; // Prompt the user to select a file
        }
    }

    // Uploads the selected file, checks its size, and reads its contents
    uploadFile() {
        if (this.filesUploaded[0].size > this.MAX_FILE_SIZE) {
            console.log('File Size is too large'); // Log error if file size exceeds the limit
            return;
        }

        this.showLoadingSpinner = true; // Show loading spinner during file processing

        this.fileReader = new FileReader(); // Initialize FileReader to read the file

        // Define the callback for when the file reading is completed
        this.fileReader.onloadend = () => {
            this.fileContents = this.fileReader.result;
            this.handleCSV(); // Process the CSV content
        };

        this.fileReader.readAsText(this.filesUploaded[0]); // Start reading the file as text
    }

    // Closes the modal window
    handleClose() {
        this.close(); // Close the modal
        return 'saved'; // Return 'saved' as a confirmation
    }

    // Processes the CSV content and inserts records into the database using Apex
    handleCSV() {
        let lines = []; // Array to hold each line of the CSV
        let lines2 = this.fileContents.split('\n'); // Split the file content into lines
        lines2.forEach((line, index) => {
            lines.push(line); // Add each line to the lines array
        });

        let parsedArray = lines.map(line => this.parseCSVLine(line)); // Parse each line of the CSV

        parsedArray.shift(); // Remove the header row
        parsedArray.pop(); // Remove the totals
        parsedArray.pop(); // Remove any trailing empty line

        // Try to insert each parsed CSV line into the database
        try {
            parsedArray.forEach(element => {
                console.log(element[0]);
                insertLine({
                    wbsNum: element[0], // Extract WBS number
                    budgetedTime: parseFloat(element[4]), // Extract budgeted time
                    actualTime: 0.00, // Extract actual time
                    taskName: element[1], // Extract task name
                    cdbId: this.recordId, // Use recordId from parent component
                    notes: element[5] // extract notes
                })
                .then(result => {
                    // Handle the result from the Apex method
                    if (result === null || result.length === 0) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Warning',
                                message: 'The CSV file does not contain any data',
                                variant: 'warning',
                            })
                        );
                    } else {
                        this.data = result; // Update data to be displayed in the datatable
                        this.fileName = ' – Uploaded Successfully'; // Update the filename with success message
                        this.isTrue = false;
                        this.showLoadingSpinner = false; // Hide the loading spinner
                    }
                })
                .catch(error => {
                    // Handle any errors that occur during the insert operation
                    console.error(error);
                    this.showLoadingSpinner = false; // Hide the loading spinner on error
                    // Show an error toast if needed
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
            // Catch any unexpected errors and log them
            console.error(error);
            this.showLoadingSpinner = false; // Hide the loading spinner on error
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'An unexpected error occurred.',
                    variant: 'error',
                })
            );
        }
    }

    // Parses a single line of the CSV file into an array of values
    parseCSVLine(line) {
        let result = [];
        let current = '';
        let inQuotes = false; // Flag to handle fields enclosed in quotes
        for (let char of line) {
            if (char === '"') {
                inQuotes = !inQuotes; // Toggle the inQuotes flag
            } else if (char === ',' && !inQuotes) {
                result.push(current.trim()); // Add the current value to the result array
                current = ''; // Reset the current value
            } else {
                current += char; // Add character to the current value
            }
        }
        result.push(current.trim()); // Push the last value
        return result; // Return the parsed array
    }
}
