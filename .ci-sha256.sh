#!/bin/sh

if [ $CI_COMMIT_TAG ] ; then
	for f in $1-$CI_COMMIT_TAG.zip ; do
		sha256sum $f > $f.sha256
	done
else
	for f in $1-.zip ; do
		sha256sum $f > $f.sha256
	done
fi
for f in *.sha256 ; do
	echo $f
	cat $f
done
