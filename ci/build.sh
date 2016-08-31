#!/bin/bash

set -ex
set -eo pipefail

function run_docker
{
	$DOCKER_PREFIX docker run --rm=true \
	 --user="${USER}" -w "${PWD}" -v "${PWD}":"${PWD}":Z \
         -t $1 $2
}

env

if [ -d output-images ]; then
	echo 'output-images already exists!';
	exit 1;
fi

for distro in ubuntu1510 fedora23;
do
	base_dockerfile=ci/docker/$distro
	if [[ -n "$HTTP_PROXY" ]]; then
		http_proxy=$HTTP_PROXY
	fi
	if [[ -n "$http_proxy" ]]; then
	  if [[ "$distro" == fedora23 ]]; then
	    PROXY="RUN echo \"proxy=${http_proxy}\" >> /etc/dnf/dnf.conf"
	  fi
	  if [[ "$distro" == ubuntu1510 ]]; then
	    PROXY="RUN echo \"Acquire::http::Proxy \\"\"${http_proxy}/\\"\";\" > /etc/apt/apt.conf.d/000apt-cacher-ng-proxy"
	  fi
        fi

	Dockerfile=$(head -n1 $base_dockerfile; echo ${PROXY}; tail -n +2 $base_dockerfile; cat << EOF
RUN grep -q ${GROUPS} /etc/group || groupadd -g ${GROUPS} ${USER}
RUN grep -q ${UID} /etc/passwd || useradd -d ${HOME} -m -u ${UID} -g ${GROUPS} ${USER}
${PROXY}
RUN locale-gen en_US.UTF-8
USER ${USER}
ENV HOME ${HOME}
EOF
)
	$DOCKER_PREFIX docker build -t openbmc/broomstick-$distro - <<< "${Dockerfile}"
	mkdir -p output-images/$distro
	run_docker openbmc/broomstick-$distro "./ci/build-all-defconfigs.sh output-images/$distro"
	if [ $? = 0 ]; then
		mv *-images output-$distro/
	else
		exit $?;
	fi
done;

