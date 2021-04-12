import datetime
import logging

from airflow import DAG
from airflow.operators.python_operator import PythonOperator

def greet_hello():
    logging.info("Hello World")

dag = DAG("FirstDag", start_date=datetime.datetime.now(),schedule_interval=None)

first_task = PythonOperator(python_callable=greet_hello , dag=dag , task_id="first-task")
