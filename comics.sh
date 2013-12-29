#!/bin/bash

# crontab -l
# WEBROOT=/data/vhosts/stefan.cog-ent.com/htdocs
# 05,07,09 0 * * * $WEBROOT/comics.sh 
# 05 1,4,7,10 * * * $WEBROOT/comics.sh 

[ -z "$1" ] && date='now' || date="$1"
date="$(date -d $date +%Y%m%d)"
prev="$(date -d $date-1day +%Y%m%d)"
prevweek="$(date -d $date-7day +%Y%m%d)"
echo -e "\n$(date -d $date '+%A, %B %d, %Y')"
WEBROOT=/data/vhosts/stefan.cog-ent.com/comics/htdocs
COMICDIR=$WEBROOT/$date
# Remove comics that are too small to be comics
test -d $COMICDIR && find $COMICDIR -type f -name "*.gif" -size -5000c | xargs -r rm -f
test -d $COMICDIR && find $COMICDIR -empty | xargs -r rmdir
# Remove comics that are the same as the previous day
test -d $COMICDIR && md5sum $COMICDIR/* | sed "s/$date/$prev/" | md5sum -c - 2>/dev/null | grep OK$ | sed "s/$prev/$date/;s/: OK$//" | grep gif$ | xargs -r rm -f
# Or the previous week
test -d $COMICDIR && md5sum $COMICDIR/* | sed "s/$date/$prevweek/" | md5sum -c - 2>/dev/null | grep OK$ | sed "s/$prevweek/$date/;s/: OK$//" | grep gif$ | xargs -r rm -f
mkdir -p $COMICDIR
touch $COMICDIR
agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/31.0.1650.63 Chrome/31.0.1650.63 Safari/537.36"
# wget: --max-redirect=0

#########
referer=http://www.babyblues.com/index.php
test -s $COMICDIR/baby_blues.gif || wget -nv -O $COMICDIR/baby_blues.gif -U "$agent" --referer=$referer $(perl -Mojo -E 'g("http://www.babyblues.com" => {Referer => "'$referer'", "User-Agent" => "'"$agent"'"}); say g("http://safr.kingfeatures.com/idn/babyblues/zone/js/index.php?cn=72&zn=132&fn=22&fd='$(date -d $date +%Y-%m-%d)'&wt=2&fs=0&null=0" => {Referer => "'$referer'", "User-Agent" => "'"$agent"'"})->dom->find("img")->attr("src")')
referer=http://www.beetlebailey.com
test -s $COMICDIR/beetle_bailey.gif || wget -nv -O $COMICDIR/beetle_bailey.gif -U "$agent" --referer=$referer $(perl -Mojo -E 'say g("http://www.beetlebailey.com/comics/'$(date -d $date +%B-%_d-%Y | sed 's/ //')'" => {Referer => "'$referer'", "User-Agent" => "'"$agent"'"})->dom->at("#comicpanel")->find("img")->attr("src")')
test -s $COMICDIR/dilbert.gif || wget -nv -O $COMICDIR/dilbert.gif $(perl -Mojo -E 'say "http://www.dilbert.com".g("http://www.dilbert.com/strips/comic/'$(date -d $date +%Y-%m-%d)'")->dom->at("#strip_enlarged_'$(date -d $date +%Y-%m-%d)'")->find("img")->attr("src")')
if [ $(date -d $date +%a) = "Sun" ]; then
  test -s $COMICDIR/foxtrot.gif || wget -nv -O $COMICDIR/foxtrot.gif $(perl -Mojo -E 'say g("http://www.gocomics.com/foxtrot/'$(date -d $date +%Y/%m/%d)'")->dom->at("p.feature_item")->next->find("img")->attr("src")')
fi
test -s $COMICDIR/frazz.gif || wget -nv -O $COMICDIR/frazz.gif $(perl -Mojo -E 'say g("http://www.gocomics.com/frazz/'$(date -d $date +%Y/%m/%d)'")->dom->at("p.feature_item")->next->find("img")->attr("src")')
test -s $COMICDIR/get_fuzzy.gif || wget -nv -O $COMICDIR/get_fuzzy.gif $(perl -Mojo -E 'say g("http://www.gocomics.com/getfuzzy/'$(date -d $date +%Y/%m/%d)'")->dom->at("p.feature_item")->next->find("img")->attr("src")')
test -s $COMICDIR/pearls_before_swine.gif || wget -nv -O $COMICDIR/pearls_before_swine.gif $(perl -Mojo -E 'say g("http://www.gocomics.com/pearlsbeforeswine/'$(date -d $date +%Y/%m/%d)'")->dom->at("p.feature_item")->next->find("img")->attr("src")')
referer=http://www.zitscomics.com
test -s $COMICDIR/zits.gif || wget -nv -O $COMICDIR/zits.gif -U "$agent" --referer=$referer $(perl -Mojo -E 'say g("http://www.zitscomics.com/comics/'$(date -d $date +%B-%_d-%Y | sed 's/ //')'" => {Referer => "'$referer'", "User-Agent" => "'"$agent"'"})->dom->at("#comicpanel")->find("img")->attr("src")')
#########

chown -R www-data.www-data $WEBROOT
