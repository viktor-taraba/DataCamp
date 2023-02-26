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
