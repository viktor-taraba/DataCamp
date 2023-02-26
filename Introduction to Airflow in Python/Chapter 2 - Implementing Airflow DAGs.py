# Defining a BashOperator task

# The BashOperator allows you to specify any given Shell command or script and add it to an Airflow workflow. 
# This can be a great start to implementing Airflow in your environment.
# As such, you've been running some scripts manually to clean data (using a script called cleanup.sh) prior to delivery 
# to your colleagues in the Data Analytics group. As you get more of these tasks assigned, you've realized it's becoming difficult 
# to keep up with running everything manually, much less dealing with errors or retries. You'd like to implement a simple script as an Airflow operator.
# The Airflow DAG analytics_dag is already defined for you and has the appropriate configurations in place.

# Import the BashOperator
from airflow.operators.bash_operator import BashOperator

# Define the BashOperator 
cleanup = BashOperator(
    task_id='cleanup_task',
    # Define the bash_command
    bash_command='cleanup.sh',
    # Add the task to the dag
    dag=analytics_dag
)


# Multiple BashOperators

# Airflow DAGs can contain many operators, each performing their defined tasks.
# You've successfully implemented one of your scripts as an Airflow task and have decided to continue migrating your individual scripts to a full Airflow DAG. 
# You now want to add more components to the workflow. In addition to the cleanup.sh used in the previous exercise you have two more scripts, 
# consolidate_data.sh and push_data.sh. These further process your data and copy to its final location.
# The DAG analytics_dag is available as before, and your cleanup task is still defined. The BashOperator is already imported.

# Define a second operator to run the `consolidate_data.sh` script
consolidate = BashOperator(
    task_id='consolidate_task',
    bash_command='consolidate_data.sh',
    dag=analytics_dag)

# Define a final operator to execute the `push_data.sh` script
push_data = BashOperator(
    task_id='pushdata_task',
    bash_command='push_data.sh',
    dag=analytics_dag)


# Define order of BashOperators

# Now that you've learned about the bitshift operators, it's time to modify your workflow to include a pull step and to include the task ordering. 
# You have three currently defined components, cleanup, consolidate, and push_data.
# The DAG analytics_dag is available as before and the BashOperator is already imported

# Define a new pull_sales task
pull_sales = BashOperator(
    task_id='pullsales_task',
    bash_command='wget https://salestracking/latestinfo?json',
    dag=analytics_dag
)

# Set pull_sales to run prior to cleanup
pull_sales >> cleanup

# Configure consolidate to run after cleanup
cleanup >> consolidate

# Set push_data to run last
consolidate >> push_data


# Troubleshooting DAG dependencies

# You've created a DAG with intended dependencies based on your workflow but for some reason Airflow won't load / execute the DAG. Try using the terminal to:
# List the DAGs.
# Decipher the error message.
# Use cat workspace/dags/codependent.py to view the Python code.
# Determine which of the following lines should be removed from the Python code. 

from airflow.models import DAG
from airflow.operators.bash_operator import BashOperator
from datetime import datetime

default_args = {
  'owner': 'dsmith',
  'start_date': datetime(2020, 2, 12),
  'retries': 1
}

codependency_dag = DAG('codependency', default_args=default_args)

task1 = BashOperator(task_id='first_task',
                     bash_command='echo 1',
                     dag=codependency_dag)

task2 = BashOperator(task_id='second_task',
                     bash_command='echo 2',
                     dag=codependency_dag)

task3 = BashOperator(task_id='third_task',
                     bash_command='echo 3',
                     dag=codependency_dag)

# task1 must run before task2 which must run before task3
task1 >> task2
task2 >> task3


# Using the PythonOperator

# You've implemented several Airflow tasks using the BashOperator but realize that a couple of specific tasks would be better implemented using Python. 
# You'll implement a task to download and save a file to the system within Airflow.
# The requests library is imported for you, and the DAG process_sales_dag is already defined.

def pull_file(URL, savepath):
    r = requests.get(URL)
    with open(savepath, 'wb') as f:
        f.write(r.content)   
    # Use the print method for logging
    print(f"File pulled from {URL} and saved to {savepath}")

from airflow.operators.python_operator import PythonOperator

# Create the task
pull_file_task = PythonOperator(
    task_id='pull_file',
    # Add the callable
    python_callable=pull_file,
    # Define the arguments
    op_kwargs={'URL':'http://dataserver/sales.json', 'savepath':'latestsales.json'},
    dag=process_sales_dag
)


# More PythonOperators

# To continue implementing your workflow, you need to add another step to parse and save the changes of the downloaded file. 
# The DAG process_sales_dag is defined and has the pull_file task already added. In this case, the Python function is already defined for you, 
# parse_file(inputfile, outputfile). Note that often when implementing Airflow tasks, you won't necessarily understand the individual steps given to you. 
# As long as you understand how to wrap the steps within Airflow's structure, you'll be able to implement a desired workflow.

# Add another Python task
parse_file_task = PythonOperator(
    task_id='parse_file',
    # Set the function to call
    python_callable=parse_file,
    # Add the arguments
    op_kwargs={'inputfile':'latestsales.json', 'outputfile':'parsedfile.json'},
    # Add the DAG
    dag=process_sales_dag
)


# EmailOperator and dependencies

# Now that you've successfully defined the PythonOperators for your workflow, your manager would like to receive a copy of the parsed JSON file via email 
# when the workflow completes. The previous tasks are still defined and the DAG process_sales_dag is configured.

# Import the Operator
from airflow.operators.email_operator import EmailOperator

# Define the task
email_manager_task = EmailOperator(
    task_id='email_manager',
    to='manager@datacamp.com',
    subject='Latest sales JSON',
    html_content='Attached is the latest sales JSON file as requested.',
    files='parsedfile.json',
    dag=process_sales_dag
)

# Set the order of tasks
pull_file_task >> parse_file_task >> email_manager_task


# Schedule a DAG via Python

# You've learned quite a bit about creating DAGs, but now you would like to schedule a specific DAG on a specific day of the week at a certain time. 
# You'd like the code include this information in case a colleague needs to reinstall the DAG to a different server.
# The Airflow DAG object and the appropriate datetime methods have been imported for you.

# Update the scheduling arguments as defined
default_args = {
  'owner': 'Engineering',
  'start_date': datetime(2019, 11, 1),
  'email': ['airflowresults@datacamp.com'],
  'email_on_failure': False,
  'email_on_retry': False,
  'retries': 3,
  'retry_delay': timedelta(minutes=20)
}

dag = DAG('update_dataflows', default_args=default_args, schedule_interval='30 12 * * 3')


# Troubleshooting DAG runs
# You've scheduled a DAG called process_sales which is set to run on the first day of the month and email your manager a copy of the report generated in the workflow. 
# The start_date for the DAG is set to February 15, 2020. Unfortunately it's now March 2nd and your manager did not receive the report and would like to know
# what happened.
# Use the information you've learned about Airflow scheduling to determine what the issue is.

import requests
import json
from datetime import datetime
from airflow.models import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.operators.email_operator import EmailOperator


default_args = {
    'owner':'sales_eng',
    'start_date': datetime(2020, 2, 15),
}

process_sales_dag = DAG(dag_id='process_sales', default_args=default_args, schedule_interval='@monthly')


def pull_file(URL, savepath):
    r = requests.get(URL)
    with open(savepath, 'w') as f:
        f.write(r.content)
    print(f"File pulled from {URL} and saved to {savepath}")
    

pull_file_task = PythonOperator(
    task_id='pull_file',
    # Add the callable
    python_callable=pull_file,
    # Define the arguments
    op_kwargs={'URL':'http://dataserver/sales.json', 'savepath':'latestsales.json'},
    dag=process_sales_dag
)

def parse_file(inputfile, outputfile):
    with open(inputfile) as infile:
      data=json.load(infile)
      with open(outputfile, 'w') as outfile:
        json.dump(data, outfile)
        
parse_file_task = PythonOperator(
    task_id='parse_file',
    # Set the function to call
    python_callable=parse_file,
    # Add the arguments
    op_kwargs={'inputfile':'latestsales.json', 'outputfile':'parsedfile.json'},
    # Add the DAG
    dag=process_sales_dag
)

email_manager_task = EmailOperator(
    task_id='email_manager',
    to='manager@datacamp.com',
    subject='Latest sales JSON',
    html_content='Attached is the latest sales JSON file as requested.',
    files='parsedfile.json',
    dag=process_sales_dag
)

pull_file_task >> parse_file_task >> email_manager_task

#  Answer: The `schedule_interval` has not yet passed since the `start_date`.
