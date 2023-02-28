# Sensory deprivation

# You've recently taken over for another Airflow developer and are trying to learn about the various workflows defined within the system. 
# You come across a DAG that you can't seem to make run properly using any of the normal tools. Try exploring the DAG for any information about what it might 
# be looking for before continuing.

from airflow.models import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.operators.python_operator import PythonOperator
from airflow.operators.http_operator import SimpleHttpOperator
from airflow.contrib.sensors.file_sensor import FileSensor

dag = DAG(
   dag_id = 'update_state',
   default_args={"start_date": "2019-10-01"}
)

precheck = FileSensor(
   task_id='check_for_datafile',
   filepath='salesdata_ready.csv',
   dag=dag)

part1 = BashOperator(
   task_id='generate_random_number',
   bash_command='echo $RANDOM',
   dag=dag
)

import sys
def python_version():
   return sys.version

part2 = PythonOperator(
   task_id='get_python_version',
   python_callable=python_version,
   dag=dag)
   
part3 = SimpleHttpOperator(
   task_id='query_server_for_external_ip',
   endpoint='https://api.ipify.org',
   method='GET',
   dag=dag)
   
precheck >> part3 >> part2

# Answer: The DAG is waiting for the file salesdata_ready.csv to be present.


# Executor implications

# You're learning quite a bit about running Airflow DAGs and are gaining some confidence at developing new workflows. 
# That said, your manager has mentioned that on some days, the workflows are taking a lot longer to finish and asks you to investigate. 
# She also mentions that the salesdata_ready.csv file is taking longer to generate these days and the time of day it is completed is variable.
# This exercise requires information from the previous two lessons - remember the implications of the available arguments and modify the workflow accordingly. 

from airflow.models import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.contrib.sensors.file_sensor import FileSensor
from datetime import datetime

report_dag = DAG(
    dag_id = 'execute_report',
    schedule_interval = "0 0 * * *"
)

precheck = FileSensor(
    task_id='check_for_datafile',
    filepath='salesdata_ready.csv',
    start_date=datetime(2020,2,20),
    mode='reschedule',
    dag=report_dag
)

generate_report_task = BashOperator(
    task_id='generate_report',
    bash_command='generate_report.sh',
    start_date=datetime(2020,2,20),
    dag=report_dag
)

precheck >> generate_report_task

# Missing DAG

# Your manager calls you before you're about to leave for the evening and wants to know why a new DAG workflow she's created isn't showing up in the system. 
# She needs this DAG called execute_report to appear in the system so she can properly schedule it for some tests before she leaves on a trip.
# Airflow is configured using the ~/airflow/airflow.cfg file.

from airflow.models import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.contrib.sensors.file_sensor import FileSensor
from datetime import datetime

report_dag = DAG(
    dag_id = 'execute_report',
    schedule_interval = "0 0 * * *"
)

precheck = FileSensor(
    task_id='check_for_datafile',
    filepath='salesdata_ready.csv',
    start_date=datetime(2020,2,20),
    mode='poke',
    dag=report_dag)

generate_report_task = BashOperator(
    task_id='generate_report',
    bash_command='generate_report.sh',
    start_date=datetime(2020,2,20),
    dag=report_dag
)

precheck >> generate_report_task


# Defining an SLA

# You've successfully implemented several Airflow workflows into production, but you don't currently have any method of determining if 
# a workflow takes too long to run. After consulting with your manager and your team, you decide to implement an SLA at the DAG level on a test workflow.

# Import the timedelta object
from datetime import timedelta

# Create the dictionary entry
default_args = {
  'start_date': datetime(2020, 2, 20),
  'sla': timedelta(minutes=30)
}

# Add to the DAG
test_dag = DAG('test_workflow', default_args=default_args, schedule_interval='@None')


# Defining a task SLA

# After completing the SLA on the entire workflow, you realize you really only need the SLA timing on a specific task instead of the full workflow.

# Import the timedelta object
from datetime import timedelta

test_dag = DAG('test_workflow', start_date=datetime(2020,2,20), schedule_interval='@None')

# Create the task with the SLA
task1 = BashOperator(task_id='first_task',
                     sla=timedelta(hours=3),
                     bash_command='initialize_data.sh',
                     dag=test_dag)


# Generate and email a report

# Airflow provides the ability to automate almost any style of workflow. You would like to receive a report from Airflow when tasks complete without 
# requiring constant monitoring of the UI or log files. You decide to use the email functionality within Airflow to provide this message.

# All the typical Airflow components have been imported for you, and a DAG is already defined as dag.

# Define the email task
email_report = EmailOperator(
        task_id='email_report',
        to='airflow@datacamp.com',
        subject='Airflow Monthly Report',
        html_content="""Attached is your monthly workflow report - please refer to it for more detail""",
        files=['monthly_report.pdf'],
        dag=report_dag
)

# Set the email task to run after the report is generated
email_report << generate_report


# Adding status emails

# You've worked through most of the Airflow configuration for setting up your workflows, but you realize you're not getting any notifications 
# when DAG runs complete or fail. You'd like to setup email alerting for the success and failure cases, but you want to send it to two addresses.

from airflow.models import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.contrib.sensors.file_sensor import FileSensor
from datetime import datetime

default_args={
    'email': ['airflowalerts@datacamp.com', 'airflowadmin@datacamp.com'],
    'email_on_failure': True,
    'email_on_success': True
}
report_dag = DAG(
    dag_id = 'execute_report',
    schedule_interval = "0 0 * * *",
    default_args=default_args
)

precheck = FileSensor(
    task_id='check_for_datafile',
    filepath='salesdata_ready.csv',
    start_date=datetime(2020,2,20),
    mode='reschedule',
    dag=report_dag)

generate_report_task = BashOperator(
    task_id='generate_report',
    bash_command='generate_report.sh',
    start_date=datetime(2020,2,20),
    dag=report_dag
)

precheck >> generate_report_task
