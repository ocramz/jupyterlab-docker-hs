FROM ocramz/jupyterlab-docker

USER root

ENV HOME /home/$NB_USER

# Install stack from the FPComplete repositories.
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 575159689BEFB442 && \
    echo 'deb http://download.fpcomplete.com/ubuntu trusty main' > /etc/apt/sources.list.d/fpco.list && \
    apt-get update && \
    apt-get install -y stack pkg-config

USER $NB_USER

RUN mkdir ${HOME}/ihaskell && \
    mkdir ${HOME}/notebooks






# Set up a working directory for IHaskell

WORKDIR ${HOME}/ihaskell

# Set up stack
COPY stack.yaml stack.yaml
RUN stack setup


# Install dependencies for IHaskell
COPY ipython-kernel ipython-kernel

RUN chown $NB_USER ${HOME}/ihaskell/ipython-kernel

RUN stack build --only-snapshot




# Install IHaskell itself. Don't just COPY . so that
# changes in e.g. README.md don't trigger rebuild.
COPY src ${HOME}/ihaskell/src
COPY html ${HOME}/ihaskell/html
COPY main ${HOME}/ihaskell/main

RUN stack build && stack install

# Run the notebook




RUN ihaskell install

ENTRYPOINT stack exec -- jupyter lab --no-browser --NotebookApp.port=8888 '--NotebookApp.ip=*' --NotebookApp.notebook_dir=${HOME}/notebooks

# ENTRYPOINT stack exec -- jupyter notebook --NotebookApp.port=8888 '--NotebookApp.ip=*' --NotebookApp.notebook_dir=/notebooks

# EXPOSE 8888


