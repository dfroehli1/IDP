FROM public.ecr.aws/lambda/python:3.11

# Copy function code
COPY handler.py ${LAMBDA_TASK_ROOT}

# Install dependencies (if you have requirements.txt)
# COPY requirements.txt .
# RUN pip install -r requirements.txt

# Set the handler
CMD ["handler.lambda_handler"]
