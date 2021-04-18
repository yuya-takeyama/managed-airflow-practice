import sys
import os
import re
import glob
import importlib
import traceback


def to_error_command(exc_info):
  message = '{0}: {1}'.format(exc_info[0].__name__, exc_info[1])
  file = None
  line = None

  for frame, _ in traceback.walk_tb(exc_info[2]):
    co_filename = frame.f_code.co_filename
    if os.path.commonprefix([co_filename, full_environment_path]) == full_environment_path:
      file = co_filename
      line = frame.f_lineno
  relpath = os.path.relpath(file, workspace)

  return '::error file={file},line={line}::{message}'.format(file=relpath, line=line, message=message)


workspace = os.environ.get('GITHUB_WORKSPACE')
environment_path = sys.argv[1]
full_environment_path = os.path.join(workspace, environment_path)

sys.path.append(full_environment_path)

glob_pattern = os.path.join(full_environment_path, 'dags', '*.py')

error = False
for file in glob.glob(glob_pattern):
  dag_file = os.path.relpath(file, full_environment_path)
  module_name = re.sub(r'\.py$', '', dag_file.replace('/', '.'))
  try:
    importlib.import_module(module_name)
  except:
    error = True
    exc_info = sys.exc_info()
    print(to_error_command(exc_info))

if error:
  sys.exit(1)
