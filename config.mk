ifeq ($(shell uname), Darwin)
    PYTHON = python3
else ifeq ($(shell uname), Linux)
    PYTHON = python3
else
# for windows
    PYTHON = python
endif
