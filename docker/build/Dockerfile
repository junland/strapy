FROM fedora:latest

RUN groupadd -r builder -g 433 && \
    useradd -m -d /source -u 431 -r -g builder -s /sbin/nologin -c "Container build user" builder

USER root

RUN dnf group install 'Development Tools' -y && \
    dnf install bzip2 curl findutils nano vim wget xz -y && \
    dnf install automake bison bison-devel byacc cmake flex-devel gawk gcc gcc-c++ gettext-devel ldc m4 meson ninja-build texinfo -y && \
    dnf clean all

USER builder

ENV STRAPY_BUILD_JOBS 2

COPY . /source

WORKDIR /source
