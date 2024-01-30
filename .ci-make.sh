#!/usr/bin/env bash

case "$1" in
	"debian-deps")
		apt update
		apt upgrade -y
		apt install -y make graphicsmagick libcairo2-dev python3-nototools pngquant zopfli rsync fonttools patch which sudo inkscape
		ln -s $(which add_vs_cmap) $(which add_vs_cmap).py
		;;
	"debian-add_vs_cmap")
		ln -s $(which add_vs_cmap) $(which add_vs_cmap).py
		;;
	"twemoji-png128")
		cd twemoji/assets
		mkdir 128x128
		cd svg
		for svg in *.svg; do
			inkscape -w 128 -h 128 $svg -o ../128x128/${svg%.svg}.png 2>/dev/null &
			if [[ $(jobs -r -p | wc -l) -ge 12 ]]; then wait -n; fi
		done
		wait
		;;
	"noto-patch")
		cd noto-emoji
		patch -p1 -i ../twemoji-fonts/noto-emoji-use-system-pngquant.patch
		patch -p1 -i ../twemoji-fonts/noto-emoji-build-all-flags.patch
		patch -p1 -i ../twemoji-fonts/noto-emoji-use-gm.patch
		;;
	"twemoji-prep")
		cd noto-emoji
		mv NotoColorEmoji.tmpl.ttx.tmpl Twemoji.tmpl.ttx.tmpl
		sed -i 's/Noto Color Emoji/Twemoji/; s/NotoColorEmoji/Twemoji/; s/Copyright .* Google Inc\./Twitter, Inc and other contributors./; s/ Version .*/ '$VERSION'/; s/.*is a trademark.*//; s/Google, Inc\./Twitter, Inc and other contributors/; s,http://www.google.com/get/noto/,https://github.com/jdecked/twemoji/,; s/.*is licensed under.*/      Creative Commons Attribution 4.0 International/; s,http://scripts.sil.org/OFL,http://creativecommons.org/licenses/by/4.0/,' Twemoji.tmpl.ttx.tmpl
		cd ../twemoji/assets/128x128/
		for png in *.png; do
			mv $png emoji_u${png//-/_}
		done
		;;
	"emoji-build")
		cd noto-emoji
		make -j 12 EMOJI=Twemoji EMOJI_SRC_DIR=../twemoji/assets/128x128 FLAGS= BODY_DIMENSIONS=136x128
		;;
	"zip-deps")
		apt update
		apt upgrade -y
		apt install -y zip
		;;
	"magisk-prep")
		cd magisk
		mkdir -p system/fonts
		cp ../noto-emoji/Twemoji.ttf system/fonts/NotoColorEmoji.ttf
		;;
	"magisk-zip")
		cd magisk
		zip -r ../magisk-twemoji-$CI_COMMIT_TAG.zip *
		;;
	*)
		echo "ERR! INVALID SUBCOMMAND: \"$1\""
		exit 1
		;;
esac
