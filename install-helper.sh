#!/bin/bash
export DEBUG=""
export phpConfigFile=`php --ini | grep "Loaded Configuration" | sed -e "s|.*:\s*||"`

function addOptionToPhpConfig() {
	if grep -q "$1" $phpConfigFile
	then
		echo "Option $1 already added"
	else
		if [ -n "$DEBUG" ]
		then
			echo "$1 >> $phpConfigFile" 
		else
			echo "$1" >> $phpConfigFile
		fi
	fi
}

function addModuleToPhpConfig() {
	addOptionToPhpConfig "extension=$1.so"
}

function installPhpModule() {
	case "$1" in
		-y)
			$DEBUG printf "no\n" | pecl install $2
			shift
		;;
		redis)
			installRedis
		;;
		*)
			$DEBUG pecl install $1
		;;
	esac

	addModuleToPhpConfig $1

	if [[ "$1" == "apc" ]]
	then
		addOptionToPhpConfig "apc.enable_cli=1"
		addOptionToPhpConfig "apc.slam_defense=0"
	fi
}

function installRedis() {
	_pwd=$PWD
	mkdir build-environment/phpredis-build
	cd build-environment/phpredis-build
	$DEBUG git clone --depth 1 git://github.com/nicolasff/phpredis.git
	$DEBUG cd phpredis
	$DEBUG phpize
	$DEBUG ./configure
	$DEBUG make
	$DEBUG sudo make install
	cd $_pwd
}
