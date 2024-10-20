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

RUN cpanm --notest App::cpanminus

# Copy only the files needed for installing dependencies
COPY cpanfile* .
RUN cpanm --notest --from https://cpan.metacpan.org/ --installdeps .

# Copy the rest of the application source code
COPY . .

# Run the stack
CMD make stack-start
