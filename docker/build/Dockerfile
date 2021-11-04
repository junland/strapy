FROM fedora:latest

USER root

RUN dnf group install "C Development Tools and Libraries" "Development Tools" -y && \
    dnf install bzip2 curl findutils patch diffutils nano vim wget xz hostname -y && \
    dnf install autoconf-archive automake bison bison-devel byacc cmake expat-devel expect flex-devel file g++ gawk gcc gcc-c++ gettext-devel \
                ldc libattr-devel m4 make meson ncurses-devel ninja-build perl-ExtUtils-ParseXS perl-XML-Parser python3 rsync texinfo -y && \
    dnf clean all

RUN groupadd -r builder -g 433 && \
    useradd -m -d /source -u 431 -r -g builder -c "Container build user" builder

USER builder

ENV STRAPY_BUILD_JOBS 2

COPY . /source

WORKDIR /source
