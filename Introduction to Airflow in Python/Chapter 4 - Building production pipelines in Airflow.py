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


