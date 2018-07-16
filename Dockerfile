# extens from circleci elixir image
FROM circleci/elixir:1.6.6

USER root

# Define env variable
ENV SECRETKEY secret

# install and compile git-crypt
RUN git clone https://github.com/AGWA/git-crypt.git
RUN cd git-crypt && make && make install
RUN cd ..

# setting up working directory and copying source codes
WORKDIR /app
ADD . /app

# getting dependencies
RUN mix local.hex --force
RUN mix deps.get --force
RUN mix local.rebar --force
RUN mix ecto.create

# expose 4000
EXPOSE 4000
