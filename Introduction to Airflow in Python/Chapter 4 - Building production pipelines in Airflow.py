# Creating a templated BashOperator

# You've successfully created a BashOperator that cleans a given data file by executing a script called cleandata.sh. 
# This works, but unfortunately requires the script to be run only for the current day. Some of your data sources are occasionally behind by a couple 
# of days and need to be run manually.

# You successfully modify the cleandata.sh script to take one argument - the date in YYYYMMDD format. Your testing works 
# at the command-line, but you now need to implement this into your Airflow DAG. 

from airflow.models import DAG
from airflow.operators.bash_operator import BashOperator
from datetime import datetime

default_args = {
  'start_date': datetime(2020, 4, 15),
}

cleandata_dag = DAG('cleandata',
                    default_args=default_args,
                    schedule_interval='@daily')

# Create a templated command to execute
templated_command = """
    bash cleandata.sh {{ ds_nodash }}
"""

# Modify clean_task to use the templated command
clean_task = BashOperator(task_id='cleandata_task',
                          bash_command=templated_command,
                          dag=cleandata_dag)


# Templates with multiple arguments

# You wish to build upon your previous DAG and modify the code to support two arguments - the date in YYYYMMDD format, and a file name 
# passed to the cleandata.sh script.

from airflow.models import DAG
from airflow.operators.bash_operator import BashOperator
from datetime import datetime

default_args = {
  'start_date': datetime(2020, 4, 15),
}

cleandata_dag = DAG('cleandata',
                    default_args=default_args,
                    schedule_interval='@daily')

# Modify the templated command to handle a
# second argument called filename.
templated_command = """
  bash cleandata.sh {{ ds_nodash }} {{ params.filename }}
"""

# Modify clean_task to pass the new argument
clean_task = BashOperator(task_id='cleandata_task',
                          bash_command=templated_command,
                          params={'filename': 'salesdata.txt'},
                          dag=cleandata_dag)

# Create a new BashOperator clean_task2
clean_task2 = BashOperator(task_id='cleandata_task2',
                           bash_command=templated_command,
                           params={'filename': 'supportdata.txt'},
                           dag=cleandata_dag)
                           
# Set the operator dependencies
clean_task >> clean_task2


# Using lists with templates

# Once again, you decide to make some modifications to the design of your cleandata workflow. 
# This time, you realize that you need to run the command cleandata.sh with the date argument and the file argument as before, except now 
# you have a list of 30 files. You do not want to create 30 tasks, so your job is to modify the code to support running the argument for 30 or more files.

from airflow.models import DAG
from airflow.operators.bash_operator import BashOperator
from datetime import datetime

filelist = [f'file{x}.txt' for x in range(30)]

default_args = {
  'start_date': datetime(2020, 4, 15),
}

cleandata_dag = DAG('cleandata',
                    default_args=default_args,
                    schedule_interval='@daily')

# Modify the template to handle multiple files in a 
# single run.
templated_command = """
  <% for filename in params.filenames %>
  bash cleandata.sh {{ ds_nodash }} {{ filename }};
  <% endfor %>
"""

# Modify clean_task to use the templated command
clean_task = BashOperator(task_id='cleandata_task',
                          bash_command=templated_command,
                          params={'filenames': filelist},
                          dag=cleandata_dag)


# Sending templated emails

# While reading through the Airflow documentation, you realize that various operations can use templated fields to provide added flexibility. 
# You come across the docs for the EmailOperator and see that the content can be set to a template. You want to make use of this functionality 
# to provide more detailed information regarding the output of a DAG run.

from airflow.models import DAG
from airflow.operators.email_operator import EmailOperator
from datetime import datetime

# Create the string representing the html email content
html_email_str = """
Date: {{ ds }}
Username: {{ params.username }}
"""

email_dag = DAG('template_email_test',
                default_args={'start_date': datetime(2020, 4, 15)},
                schedule_interval='@weekly')
                
email_task = EmailOperator(task_id='email_task',
                           to='testuser@datacamp.com',
                           subject="{{ macros.uuid.uuid4() }}",
                           html_content=html_email_str,
                           params={'username': 'testemailuser'},
                           dag=email_dag)


# Define a BranchPythonOperator

# After learning about the power of conditional logic within Airflow, you wish to test out the BranchPythonOperator. 
# You'd like to run a different code path if the current execution date represents a new year (ie, 2020 vs 2019).

# Create a function to determine if years are different
def year_check(**kwargs):
    current_year = int(kwargs['ds_nodash'][0:4])
    previous_year = int(kwargs['prev_ds_nodash'][0:4])
    if current_year == previous_year:
        return 'current_year_task'
    else:
        return 'new_year_task'

# Define the BranchPythonOperator
branch_task = BranchPythonOperator(task_id='branch_task', dag=branch_dag,
                                   python_callable=year_check, provide_context=True)
# Define the dependencies
branch_dag >> current_year_task
branch_dag >> new_year_task


# Creating a production pipeline #1

# You've learned a lot about how Airflow works - now it's time to implement your workflow into a production pipeline consisting of many 
# objects including sensors and operators. Your boss is interested in seeing this workflow become automated and able to provide SLA reporting 
# as it provides some extra leverage for closing a deal the sales staff is working on. The sales prospect has indicated that once they see updates in 
# an automated fashion, they're willing to sign-up for the indicated data service.
# From what you've learned about the process, you know that there is sales data that will be uploaded to the system. Once the data is uploaded,
# a new file should be created to kick off the full processing, but something isn't working correctly.
# Refer to the source code of the DAG to determine if anything extra needs to be added.

from airflow.models import DAG
from airflow.contrib.sensors.file_sensor import FileSensor

# Import the needed operators
from airflow.operators.bash_operator import BashOperator
from airflow.operators.python_operator import PythonOperator
from datetime import date, datetime

def process_data(**context):
  file = open('/home/repl/workspace/processed_data.tmp', 'w')
  file.write(f'Data processed on {date.today()}')
  file.close()

    
dag = DAG(dag_id='etl_update', default_args={'start_date': datetime(2020,4,1)})

sensor = FileSensor(task_id='sense_file', 
                    filepath='/home/repl/workspace/startprocess.txt',
                    poke_interval=5,
                    timeout=15,
                    dag=dag)

bash_task = BashOperator(task_id='cleanup_tempfiles', 
                         bash_command='rm -f /home/repl/*.tmp',
                         dag=dag)

python_task = PythonOperator(task_id='run_processing', 
                             python_callable=process_data,
                             dag=dag)

sensor >> bash_task >> python_task


# Creating a production pipeline #2

# Continuing on your last workflow, you'd like to add some additional functionality, specifically adding some SLAs to the code and modifying 
# the sensor components.
# Refer to the source code of the DAG to determine if anything extra needs to be added. The default_args dictionary has been defined for you, 
# though it may require further modification.

from datetime import date

def process_data(**kwargs):

    file = open("/home/repl/workspace/processed_data-" + kwargs['ds'] + ".tmp", "w")
    
    file.write(f"Data processed on {date.today()}")
    
    file.close()

from airflow.models import DAG
from airflow.contrib.sensors.file_sensor import FileSensor
from airflow.operators.bash_operator import BashOperator
from airflow.operators.python_operator import PythonOperator
from dags.process import process_data
from datetime import timedelta, datetime

# Update the default arguments and apply them to the DAG
default_args = {
  'start_date': datetime(2019,1,1),
  'sla': timedelta(minutes=90)
}

dag = DAG(dag_id='etl_update', default_args=default_args)

sensor = FileSensor(task_id='sense_file', 
                    filepath='/home/repl/workspace/startprocess.txt',
                    poke_interval=45,
                    dag=dag)

bash_task = BashOperator(task_id='cleanup_tempfiles', 
                         bash_command='rm -f /home/repl/*.tmp',
                         dag=dag)

python_task = PythonOperator(task_id='run_processing', 
                             python_callable=process_data,
                             provide_context=True,
                             dag=dag)

sensor >> bash_task >> python_task


# Adding the final changes to your pipeline

# To finish up your workflow, your manager asks that you add a conditional logic check to send a sales report via email, only if the day is a weekday. 
# Otherwise, no email should be sent. In addition, the email task should be templated to include the date and a project name in the content.

from datetime import date

def process_data(**kwargs):
    file = open("/home/repl/workspace/processed_data-" + kwargs['ds'] + ".tmp", "w")
    file.write(f"Data processed on {date.today()}")
    file.close()
  
from airflow.models import DAG
from airflow.contrib.sensors.file_sensor import FileSensor
from airflow.operators.bash_operator import BashOperator
from airflow.operators.python_operator import PythonOperator
from airflow.operators.python_operator import BranchPythonOperator
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.email_operator import EmailOperator
from dags.process import process_data
from datetime import datetime, timedelta

# Update the default arguments and apply them to the DAG.

default_args = {
  'start_date': datetime(2019,1,1),
  'sla': timedelta(minutes=90)
}
    
dag = DAG(dag_id='etl_update', default_args=default_args)

sensor = FileSensor(task_id='sense_file', 
                    filepath='/home/repl/workspace/startprocess.txt',
                    poke_interval=45,
                    dag=dag)

bash_task = BashOperator(task_id='cleanup_tempfiles', 
                         bash_command='rm -f /home/repl/*.tmp',
                         dag=dag)

python_task = PythonOperator(task_id='run_processing', 
                             python_callable=process_data,
                             provide_context=True,
                             dag=dag)


email_subject="""
  Email report for {{ params.department }} on {{ ds_nodash }}
"""


email_report_task = EmailOperator(task_id='email_report_task',
                                  to='sales@mycompany.com',
                                  subject=email_subject,
                                  html_content='',
                                  params={'department': 'Data subscription services'},
                                  dag=dag)


no_email_task = DummyOperator(task_id='no_email_task', dag=dag)


def check_weekend(**kwargs):
    dt = datetime.strptime(kwargs['execution_date'],"%Y-%m-%d")
    # If dt.weekday() is 0-4, it's Monday - Friday. If 5 or 6, it's Sat / Sun.
    if (dt.weekday() < 5):
        return 'email_report_task'
    else:
        return 'no_email_task'
    
    
branch_task = BranchPythonOperator(task_id='check_if_weekend',
                                   provide_context=True,
                                   python_callable=check_weekend,
                                   dag=dag)

    
sensor >> bash_task >> python_task

python_task >> branch_task >> [email_report_task, no_email_task]
