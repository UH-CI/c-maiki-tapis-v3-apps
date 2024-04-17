FROM continuumio/miniconda:latest

RUN mkdir -p /usr/share/man/man1

WORKDIR /envworkspace

RUN apt-get update --allow-releaseinfo-change \
    && apt-get install -y openjdk-11-jre-headless \
    build-essential \
    uuid-dev \
    libgpgme-dev \
    squashfs-tools \
    libseccomp-dev \
    wget \
    pkg-config \
    git


# Installing go
RUN export VERSION=1.17.2 OS=linux ARCH=amd64 && \
    wget https://dl.google.com/go/go$VERSION.$OS-$ARCH.tar.gz && \
    tar -C /usr/local -xzvf go$VERSION.$OS-$ARCH.tar.gz && \
    rm go$VERSION.$OS-$ARCH.tar.gz && \
    echo 'export GOPATH=${HOME}/go' >> ~/.bashrc && \
    echo 'export PATH=/usr/local/go/bin:${PATH}:${GOPATH}/bin' >> ~/.bashrc


RUN ["/bin/bash", "-c", "source ~/.bashrc"]

RUN export VERSION=3.9.0 && \
    wget https://github.com/sylabs/singularity/releases/download/v${VERSION}/singularity-ce-${VERSION}.tar.gz && \
    tar -xzf singularity-ce-${VERSION}.tar.gz

RUN ["/bin/bash", "-c", "source ~/.bashrc && export VERSION=3.9.0 && \
    cd singularity-ce-${VERSION} && \
    ./mconfig --without-suid && \
    make -C builddir && \
    make -C builddir install"]

RUN rm -rf singularity singularity-ce-3.9.0.tar.gz

RUN mkdir /output
RUN mkdir -p /etc/slurm /etc/slurm/plugins /mnt/config/etc/slurm/plugins/ /usr/lib64/slurm/ /var/run/munge

RUN touch /bin/srun /bin/squeue /bin/sbatch /bin/sinfo /usr/lib64/libmunge.so.2

ENV HOME="/envworkspace"

COPY . /envworkspace

CMD /bin/bash wrapper.sh
