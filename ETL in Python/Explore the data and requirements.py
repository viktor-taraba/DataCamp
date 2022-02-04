# Import the required library
import requests

# Get the zip file
response = requests.get(path)

# Print the status code
print(response.status_code)

# Save the file locally (more about open() in the next lesson)
local_path = f"tmp/data/source/downloaded_at=2021-02-01/PPR-ALL.zip"
with open(local_path, "wb") as f:
    f.write(response.content)

# Import the required method
from zipfile import ZipFile

with ZipFile(path, "r") as f:
    # Get the list of files
    file_names = f.namelist()
    print(file_names)
    # Extract the CSV file
    csv_file_path = f.extract(file_names[0])
    print(csv_file_path)
    
import csv
from pprint import pprint

# Open the csv file in read mode
with open(path, mode="r", encoding="windows-1252") as csv_file:
    # Open csv_file so that each row is a dictionary
    reader = csv.DictReader(csv_file)
    
    # Print the first row
    row = next(reader)
    print(type(row))
    pprint(row)
    
fieldnames = {
    "Date of Sale (dd/mm/yyyy)": "date_of_sale",
    "Address": "address",
    "Postal Code": "postal_code",
    "County": "county",
    "Price (€)": "price",
    "Description of Property": "description",
}

import csv

with open(path, mode="r", encoding="windows-1252") as reader_csv_file:
    reader = csv.DictReader(reader_csv_file)
    # The new file is called "PPR-2021-Dublin-new-headers.csv"
    # and will be saved inside the "tmp" folder    
    with open("/tmp/PPR-2021-Dublin-new-headers.csv",
                    mode="w",
                    encoding="windows-1252",
                ) as writer_csv_file:
        writer = csv.DictWriter(writer_csv_file, fieldnames=new_column_names)
        # Write header as first line
        writer.writeheader()
        for row in reader:
	        # Write all rows in file
	        writer.writerow(row)
          
          
    
    
