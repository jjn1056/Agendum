FROM perl:5.40.0
WORKDIR /app

# Core OS setup

RUN apt-get update
RUN apt-get install -yV postgresql-client git vim

# Clean up

RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

# Basic Perl dependencies needed to run makefile commands
# and other script not related to the application.  Do not
# add application dependencies here.  You add those to the
# cpanfile.

RUN cpanm --notest --reinstall App::cpanminus

# Copy only the files needed for installing dependencies
# We do a twop step process to avoid rebuilding the image
# when the application source code changes.

COPY cpanfile* .
COPY Makefile .
RUN make update-cpanlib

# Copy the rest of the application source code
COPY . .

# Run the stack
CMD make stack-start
