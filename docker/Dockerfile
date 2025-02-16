FROM perl:5.40.1-bookworm
WORKDIR /app

# Core OS setup.  Add a few bits that I often use for debugging

RUN apt-get update
RUN apt-get install -yV postgresql-client git vim build-essential libssl-dev dnsutils 

# Clean up

RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

# Basic Perl dependencies needed to run makefile commands
# and other script not related to the application.  Do not
# add application dependencies here.  You add those to the
# cpanfile.

RUN cpanm --notest --reinstall App::cpanminus # Get lastest version

# Copy only the files needed for installing dependencies
# We do a two step process to avoid rebuilding the image
# when the application source code changes.

COPY cpanfile* .
RUN cpanm --installdeps --notest .

# We ran the cpanm command above to install the dependencies
# first so that now its cached.  This way if we modify the
# Makefile (which is frequently) we don't have reload all of
# the dependencies.

COPY Makefile .

# Copy the rest of the application source code

COPY . .

# Run the stack (starts web application)

CMD make stack-start