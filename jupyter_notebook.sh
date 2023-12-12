#!/bin/zsh

jupyter notebook \
  --NotebookApp.allow_origin='https://colab.research.google.com' \
  --port=8889 \
  --notebook-dir='/Users/marksusol/DataScience/' \
  --allow-root \
  --NotebookApp.token='' \
  --NotebookApp.disable_check_xsrf=True \
  --NotebookApp.port_retries=0 > /tmp/jupyter.log 2>&1;