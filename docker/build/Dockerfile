FROM fedora:latest

RUN groupadd -r builder -g 433 && \
    useradd -m -d /source -u 431 -r -g builder -s /sbin/nologin -c "Container build user" builder

USER root

RUN dnf group install 'Development Tools' -y && \
    dnf install vim nano wget curl bzip2 xz findutils -y && \
    dnf install gcc gcc-c++ automake bison byacc cmake ldc m4 meson ninja-build texinfo flex-devel bison-devel gettext-devel -y && \
    dnf clean all

USER builder

ENV STRAPY_BUILD_JOBS 2

COPY . /source

WORKDIR /source
