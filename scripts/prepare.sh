#!/bin/bash

build_kb=1
build_sc_machine=1

unameOut="$(uname -s)"

set -eo pipefail

while [ "$1" != "" ]; do
	case $1 in
		"no_build_kb" )
			build_kb=0
			;;
		"no_build_sc_machine" )
			build_sc_machine=0
			build_kb=0
	esac
	shift
done

stage()
{
	echo -en "[$1]\n"
}

clone_project()
{
	if [ ! -d "../$2" ]; then
		printf "Clone %s\n" "$1"
		git clone "$1" ../"$2"
		cd ../"$2"
		git checkout "$3"
		git submodule update --init --recursive
		cd -
	else
		echo -e "You can update $2 manualy\n"
	fi
}


stage "Clone sc-machine"

clone_project https://github.com/ostis-ai/sc-machine.git sc-machine feature/component_manager
git submodule update --init --recursive


if (( $build_sc_machine == 1 )); then
	stage "Build sc-machine"

	cd ../sc-machine/scripts
	case "${unameOut}" in
		Linux*)     ./install_deps_ubuntu.sh --dev;;
		Darwin*)    ./install_deps_macOS;;
		*)	    echo -en "Can't install dependencies. Unsupported OS";;
	esac

	cd ..
	pip3 install setuptools wheel
	pip3 install -r requirements.txt

	cd scripts
	./make_all.sh -m
	cd ..
fi

if (( $build_kb == 1 )); then
	stage "Build knowledge base"
	cd ../scripts
	./build_kb.sh
fi

