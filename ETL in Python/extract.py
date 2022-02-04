import os
import csv
import tempfile
from zipfile import ZipFile

import requests

# Settings
base_path = os.path.abspath(__file__ + "/../../")

# START - Paths for new February 2021 data available

# External website file url
source_url = "https://assets.datacamp.com/production/repositories/5899/datasets/66691278303f789ca4acd3c6406baa5fc6adaf28/PPR-ALL.zip"

# Source path where we want to save the .zip file downloaded from the website
source_path = f"{base_path}/data/source/downloaded_at=2021-02-01/PPR-ALL.zip"

# Raw path where we want to extract the new .csv data
raw_path = f"{base_path}/data/raw/downloaded_at=2021-02-01/ppr-all.csv"

# END - Paths for new February 2021 data available


def create_folder_if_not_exists(path):
    """
    Create a new folder if it doesn't exists
    """
    os.makedirs(os.path.dirname(path), exist_ok=True)


def download_snapshot():
    """
    Download the new dataset from the source
    """
    create_folder_if_not_exists(source_path)
    with open(source_path, "wb") as source_ppr:
        response = requests.get(source_url, verify=False)
        source_ppr.write(response.content)


def save_new_raw_data():
    """
    Save new raw data from the source
    """

    create_folder_if_not_exists(raw_path)
    with tempfile.TemporaryDirectory() as dirpath:
        with ZipFile(
            source_path,
            "r",
        ) as zipfile:
            names_list = zipfile.namelist()
            csv_file_path = zipfile.extract(names_list[0], path=dirpath)
            # Open the CSV file in read mode
            with open(csv_file_path, mode="r", encoding="windows-1252") as csv_file:
                reader = csv.DictReader(csv_file)

                row = next(reader)  # Get first row from reader
                print("[Extract] First row example:", row)

                # Open the CSV file in write mode
                with open(
                    raw_path,
                    mode="w",
                    encoding="windows-1252"
                ) as csv_file:
                    # Rename field names so they're ready for the next step
                    fieldnames = {
                        "Date of Sale (dd/mm/yyyy)": "date_of_sale",
                        "Address": "address",
                        "Postal Code": "postal_code",
                        "County": "county",
                        "Price (€)": "price",
                        "Description of Property": "description",
                    }
                    writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
                    # Write headers as first line
                    writer.writerow(fieldnames)
                    for row in reader:
                        # Write all rows in file
                        writer.writerow(row)

# Main function called inside the execute.py script
def main():
    print("[Extract] Start")
    print("[Extract] Downloading snapshot")
    download_snapshot()
    print(f"[Extract] Saving data from '{source_path}' to '{raw_path}'")
    save_new_raw_data()
    print(f"[Extract] End")
