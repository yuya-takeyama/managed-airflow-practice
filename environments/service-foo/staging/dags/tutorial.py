from datetime import timedelta
from random import randrange

# The DAG object; we'll need this to instantiate a DAG
from airflow import DAG

# Operators; we need this to operate!
from airflow.operators.bash_operator import BashOperator
from airflow.utils.dates import days_ago
# These args will get passed on to each operator
# You can override them on a per-task basis during operator initialization
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email': ['airflow@example.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
    # 'queue': 'bash_queue',
    # 'pool': 'backfill',
    # 'priority_weight': 10,
    # 'end_date': datetime(2016, 1, 1),
    # 'wait_for_downstream': False,
    # 'dag': dag,
    # 'sla': timedelta(hours=2),
    # 'execution_timeout': timedelta(seconds=300),
    # 'on_failure_callback': some_function,
    # 'on_success_callback': some_other_function,
    # 'on_retry_callback': another_function,
    # 'sla_miss_callback': yet_another_function,
    # 'trigger_rule': 'all_success'
}
dag = DAG(
    'tutorial',
    default_args=default_args,
    description='A simple tutorial DAG',
    schedule_interval=timedelta(days=1),
    start_date=days_ago(2),
    tags=['example'],
)

a_command = """
python --version
pip --version
pip list
sleep 3
"""

a = BashOperator(
    task_id='a',
    bash_command="{{ dag_run.conf['command'] }}",
    dag=dag,
)

b = BashOperator(
    task_id='b',
    bash_command='sleep 30',
    dag=dag,
)

c_1 = BashOperator(
    task_id='c_1',
    bash_command='sleep ' + str(randrange(1, 31)),
    dag=dag,
)
c_2 = BashOperator(
    task_id='c_2',
    bash_command='sleep ' + str(randrange(1, 31)),
    dag=dag,
)
c_3 = BashOperator(
    task_id='c_3',
    bash_command='sleep ' + str(randrange(1, 31)),
    dag=dag,
)

d = BashOperator(
    task_id='d',
    bash_command='sleep ' + str(randrange(1, 3)),
    dag=dag,
)

e = BashOperator(
    task_id='e',
    bash_command='sleep ' + str(randrange(1, 3)),
    dag=dag,
)

f = BashOperator(
    task_id='f',
    bash_command='sleep ' + str(randrange(1, 3)),
    dag=dag,
)


a >> [c_1, c_2, c_3]
c_1 >> [d, e]
c_2 >> [d, e]
c_3 >> [d, e]
f << [b, d, e]
