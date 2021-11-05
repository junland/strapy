FROM fedora:latest

USER root

RUN dnf upgrade -y && \
    dnf group install "C Development Tools and Libraries" "Development Tools" -y && \
    dnf install bzip2 curl findutils patch diffutils nano vim wget xz hostname sudo bash -y && \
    dnf install autoconf-archive automake bison bison-devel byacc cmake expat-devel expect flex-devel file g++ gawk gcc gcc-c++ gettext-devel \
                ldc libattr-devel m4 make meson ncurses-devel ninja-build perl-ExtUtils-ParseXS perl-XML-Parser python3 rsync texinfo -y && \
    dnf clean all

RUN groupadd builder && \
    useradd -s /bin/bash -g builder -m -k /dev/null -d /source -c "Container build user" builder && \
    echo "builder:builder" | chpasswd && \
    echo "builder ALL = NOPASSWD : ALL" >> /etc/sudoers && \
    echo 'Defaults env_keep += "LC_ALL PATH STRAPY_BUILD_JOBS"' >> /etc/sudoers && \
    echo "umask 022" >> /source/.profile

COPY . /source

RUN chown builder -Rv /source

USER builder

ENV STRAPY_BUILD_JOBS 2

WORKDIR /source
