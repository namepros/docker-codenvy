# Copyright (c) 2012-2016 Codenvy, S.A.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
# Contributors:
# Codenvy, S.A. - initial API and implementation
#
# Updated by NamePros
# Original: https://github.com/eclipse/che-dockerfiles/blob/master/recipes/stack-base/ubuntu/Dockerfile

FROM ubuntu:17.04

ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH
RUN true \
    && DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install \
        openssh-server \
        sudo \
        procps \
        wget \
        unzip \
        mc \
        ca-certificates \
        curl \
        software-properties-common \
        python-software-properties \
        openjdk-8-jdk-headless \
        bash-completion \
        locales \
        git \
        subversion \
    && DEBIAN_FRONTEND=noninteractive apt-get -y clean \
    && DEBIAN_FRONTEND=noninteractive apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /run/sshd \
    && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && useradd -u 1000 -G users,sudo -d /home/user --shell /bin/bash -m user \
    && usermod -p "*" user \
    && echo '#!/bin/bash\nset -e\nsudo -H /usr/sbin/sshd -D &\nexec "$@"' > /home/user/entrypoint.sh \
    && chmod +x /home/user/entrypoint.sh \
    && mkdir /projects
    && chown user:user /projects
    && LANG=en_US.UTF-8 locale-gen en_US.UTF-8 \
    && true
ENV LANG en_US.UTF-8
USER user
RUN true \
    && svn --version \
    && cd ~user \
    && sed -i 's/# store-passwords = no/store-passwords = yes/g; s/# store-plaintext-passwords = no/store-plaintext-passwords = yes/g' ~user/.subversion/servers \
    && true
EXPOSE 22 4403
WORKDIR /projects
ENTRYPOINT ["/home/user/entrypoint.sh"]
CMD tail -f /dev/null
