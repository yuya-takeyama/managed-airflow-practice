from datetime import datetime
from airflow import DAG
from airflow.operators.python_operator import PythonOperator

def print_hello():
  return 'Hello Wolrd'

dag = DAG('hello_world', description='Hello world example', schedule_interval='* * * * *', start_date=datetime(2017, 3, 20), catchup=False)

hello_operator = PythonOperator(task_id='hello_task', python_callable=print_hello, dag=dag)
