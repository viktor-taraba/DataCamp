import os
import requests

# Paths
base_path = "/home/repl/workspace"
source_url = "https://assets.datacamp.com/production/repositories/5899/datasets/66691278303f789ca4acd3c6406baa5fc6adaf28/PPR-ALL.zip"
source_path =  f"{base_path}/data/source/downloaded_at=2021-01-01/ppr-all.zip"

# Create a directory at the `path` passed as an argument
def create_directory_if_not_exists(path):
    """
    Create a new directory if it doesn't exists
    """
    # os.path.dirname() returns up to the directory path.
    # In this case it is: f"{base_path}/downloaded_at=2021-01-01"
    # "ppr-all.zip" is excluded
    os.makedirs(os.path.dirname(path), exist_ok=True)

# Write the file obtained to the specified directory
def download_snapshot():
    """
    Download the new dataset from the source
    """
    create_directory_if_not_exists(source_path)
    # Open the .zip file in binary mode
    with open(source_path, "wb") as source_ppr:
        # 'verify=False' skips the verification the SSL certificate
        response = requests.get(source_url, verify=False)
        source_ppr.write(response.content)

# Download the new dataset
download_snapshot()
