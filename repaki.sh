#!/bin/bash
# ---------------------------------------------------------------------
# repaki repackages PrisonArchitect translation files using GNU PO
# Copyright (C) 2016 Josef P. Bernhart
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# ---------------------------------------------------------------------

# not everybody calls this file with 'sh'
shopt -s expand_aliases

alias GETTEXT="gettext REPAKI"

if [ -z "$1" ]; then
  echo $(GETTEXT "Bonvolu aldoni loko de main.dat (unua argumento)")
  exit 1
fi

if [ -z "$2" ]; then
  echo "$(GETTEXT "Bonvolu aldoni loko de tradukado po dosiero (dua argumento)")"
  exit 1
fi


MAIN_DAT=$(realpath "$1")
BASE=$(basename "$MAIN_DAT" .dat)
DIR=$(dirname "$MAIN_DAT")

SELF=$(dirname "$0")

LANG_DIR="data/language"
SELF_LANG="$SELF/$LANG_DIR"

PO_FILE=$(realpath "$2")

SVT_UTILS_BASE="$SELF/svt-utils"
SVT_UTILS_GIT="git@github.com:Phantasus/svt-utils.git"

BACKUP=$(realpath "$DIR/${BASE}_backup.dat")
TMP="$DIR/repaki"

if [ ! -e "$SVT_UTILS_BASE" ]; then
  echo "===> $(GETTEXT "svt utils ne ekzistas, elŝuti ĝin ...")"
  cd "$SELF" && git clone "$SVT_UTILS_GIT"
fi

echo "===> $(GETTEXT "Movi PO tradukado al lingvo dosieroj ... ")"
gawk -f "$SVT_UTILS_BASE/po2sv.awk" "$PO_FILE" "$SELF_LANG/base-language.txt" > "$SELF_LANG/base-language.tmp"
mv "$SELF_LANG/base-language.tmp" "$SELF_LANG/base-language.txt"

gawk -f "$SVT_UTILS_BASE/po2sv.awk" "$PO_FILE" "$SELF_LANG/fullgame.txt" > "$SELF_LANG/fullgame.tmp"
mv "$SELF_LANG/fullgame.tmp" "$SELF_LANG/fullgame.txt"


if [ ! -e "$BACKUP" ]; then
  echo "===> $(GETTEXT "Kopi kopio al") $BACKUP"
  cp "$MAIN_DAT" "$BACKUP"
else
  if [ -e "$MAIN_DAT" ]; then
    echo "===> $(GETTEXT "Kopio ekzistas, fari nenio ...")"
  else
    echo "===> $(GETTEXT "Kopio ekzistas sed main.dat ne, kopii kopio")"
    cp "$BACKUP" "$MAIN_DAT"
  fi
fi

echo "===> $(GETTEXT "Kopii lingvo dosieroj ...")"
if [ -e "$TMP" ]; then
  rm -rf "$TMP"
fi

mkdir "$TMP"
cd "$TMP" && unrar x "$MAIN_DAT"
cp "$SELF/$LANG_DIR"/* "$TMP/$LANG_DIR"

echo "===> $(GETTEXT "Kompresi nova luddosiero ... ")"

rm "$MAIN_DAT"
cd "$TMP" && rar a -s -r "$MAIN_DAT" data/*

rm -rf "$TMP"

echo "==================================================================="
echo "===> $(GETTEXT "Faris ĉion, Prison Architect estas nun esperantigita")"
echo "==================================================================="
