### xml
# with wkb_geometry
mv query.tsv ${file}.tmp
echo '<xml>' > ${file}.xml
sed -n '1!p' ${file}.tmp | while IFS=$'\t' read -a array; do echo ${array[1]}; dd if=enwiki-latest-pages-articles-multistream.xml skip=$(grep $'\t'"${array[1]}"$'\t' enwiki-latest-pages-articles-multistream-index.csv | awk -F$'\t' '{ print $1 }') count=1000000 iflag=skip_bytes,count_bytes | grep "<title>${array[1]}</title>" | sed "s/<\/title>/<\/title><wkb_geometry>${array[2]}<\/wkb_geometry><fid>${array[0]#http://www.wikidata.org/entity/}<\/fid>/g" >> ${file}.xml; done
echo '</xml>' >> ${file}.xml
# without wkb_geometry
echo '<xml>' > ${file}.xml
sed -n '1!p' ${file}.tmp | while IFS=$'\t' read -a array; do echo ${array[1]}; dd if=enwiki-latest-pages-articles-multistream.xml skip=$(grep $'\t'"${array[1]^}"$'\t' enwiki-latest-pages-articles-multistream-index.csv | awk -F$'\t' '{ print $1 }') count=1000000 iflag=skip_bytes,count_bytes | grep "<title>${array[1]^}</title>" | sed "s/<\/title>/<\/title><fid>${array[0]}<\/fid>/g" >> ${file}.xml; done
echo '</xml>' >> ${file}.xml
# geonames
echo '<xml>' > ${file}.xml
cat ${file}.tmp | while IFS=$'\t' read -a array; do echo ${array[1]}; dd if=enwiki-latest-pages-articles-multistream.xml skip=$(grep $'\t'"${array[1]^}"$'\t' enwiki-latest-pages-articles-multistream-index.csv | awk -F$'\t' '{ print $1 }') count=1000000 iflag=skip_bytes,count_bytes | grep "<title>${array[1]^}</title>" | sed "s/<\/title>/<\/title><fid>${array[0]}<\/fid>/g" >> ${file}.xml; done
echo '</xml>' >> ${file}.xml

### extract intro
# raw
cat ${file}.xml | perl -MHTML::Entities -pe 'decode_entities($_);' -pe 's/<ref/\n<ref/g;' -pe 's/(?=<ref).*(?<=<\/ref>)//g;' -pe 's/(?=<ref).*(?<=\/>)//g;' | tr -d '\n' | tr '\t' '\n' | sed -e 's/^ *//g' -e 's/<page>/@page/g' -e 's/<title>/\a/g' -e 's/<\/title>/\t/g' -e 's/<wkb_geometry>//g' -e 's/<\/wkb_geometry>/\t/g' -e 's/<fid>//g' -e 's/<\/fid>/\t/g' -e 's/<text xml:space="preserve">/@text\n/g' | grep -vi -e '^$' -e '^(' -e '^{' -e '^}' -e '^|' -e '^#' -e '^\*' -e '^=' -e '^:' -e '^_' -e '^&quot;' -e '^&lt;' -e '^\[\[file' -e '^\[\[category' -e '^\[\[image' -e '^<' -e '^<\/' -e '^http:' -e '^note:' -e '^file:' -e '^url=' -e '^[0-9]' -e '^•' -e '^-' | grep -A1 -e '^@page' -e '^@text' | grep -v -e '^--' -e '^@page' -e '^@text' | tr -s " " | tr -d '\n' | tr '\a' '\n' | sed -n '1!p' > ${file}/${file}_intro.csv
# cleaned up
cat ${file}.xml | perl -MHTML::Entities -pe 'decode_entities($_);' -pe 's/<ref/\n<ref/g;' -pe 's/(?=<ref).*(?<=<\/ref>)//g;' -pe 's/(?=<ref).*(?<=\/>)//g;' | tr -d '\n' | tr '\t' '\n' | sed -e 's/^ *//g' -e 's/<page>/@page/g' -e 's/<title>/\a/g' -e 's/<\/title>/\t/g' -e 's/<wkb_geometry>//g' -e 's/<\/wkb_geometry>/\t/g' -e 's/<fid>//g' -e 's/<\/fid>/\t/g' -e 's/<text xml:space="preserve">/@text\n/g' | grep -vi -e '^$' -e '^(' -e '^{' -e '^}' -e '^|' -e '^#' -e '^\*' -e '^=' -e '^:' -e '^_' -e '^&quot;' -e '^&lt;' -e '^\[\[file' -e '^\[\[category' -e '^\[\[image' -e '^<' -e '^<\/' -e '^http:' -e '^note:' -e '^file:' -e '^url=' -e '^[0-9]' -e '^•' -e '^-' | grep -A1 -e '^@page' -e '^@text' | grep -v -e '^--' -e '^@page' -e '^@text' | tr -s " " | tr -d '\n' | tr '\a' '\n' | sed -n '1!p' | tr '\n' '\a' | sed -e 's/\[\[/\n\[\[/g' -e 's/\]\]/\]\]\n/g' | sed -e 's/^\[\[.*|/\[\[/g' -e 's/{{/\n{{/g' -e 's/}}[,:;]\?/}}\n/g' -e 's/ (/\nFOOBAR/g' | sed '/)\t/! s/)/FOOBAR\n/g' | grep -v '^{{\|}}' | grep -v -e 'FOOBAR' -e '^ \?[;:] \?$' | tr -d '\n' | tr '\a' '\n' | tr -s '  ' | sed -e "s/'''//g" -e 's/\[\[//g' -e 's/\]\]//g' -e 's/\bSt\./St/g' -e 's/\bU\.S\.A\./USA/g' -e 's/\bU\.S\./US/g' -e 's/c\./c/g' -e 's/ ,/,/g' > ${file}/${file}_intro.csv

### extract section
# raw
declare -a sections=("climat" "description" "ecolog" "fauna" "flora" "geograph")
for section in "${sections[@]}"; do cat ${file}.xml | perl -MHTML::Entities -pe 'decode_entities($_);' -pe 's/<ref/\n<ref/g;' -pe 's/(?=<ref).*(?<=<\/ref>)//g;' -pe 's/(?=<ref).*(?<=\/>)//g;' | tr -d '\n' | tr '\t' '\n' | sed -e 's/^ *//g' -e 's/<page>/@page/g' -e 's/<title>/\a/g' -e 's/<\/title>/\t/g' -e 's/<wkb_geometry>//g' -e 's/<\/wkb_geometry>/\t/g' -e 's/<fid>//g' -e 's/<\/fid>/\t/g' -e 's/^=\+.*'${section}'.*=\+$/@mysection/Ig' | grep -vi -e '^$' -e '^(' -e '^{' -e '^}' -e '^|' -e '^#' -e '^\*' -e '^=' -e '^:' -e '^_' -e '^&quot;' -e '^&lt;' -e '^\[\[file' -e '^\[\[category' -e '^\[\[image' -e '^<' -e '^<\/' -e '^http:' -e '^note:' -e '^file:' -e '^url=' -e '^[0-9]' -e '^•' -e '^-' | grep -A1 -e '^@page' -e '^@mysection' | grep -v -e '^--' -e '^@page' -e '^@mysection' | tr -s " " | tr -d '\n' | tr '\a' '\n' | sed -n '1!p' > ${file}_${section}.csv; done
# cleaned up
declare -a sections=("climat" "description" "ecolog" "fauna" "flora" "geograph")
for section in "${sections[@]}"; do cat ${file}.xml | perl -MHTML::Entities -pe 'decode_entities($_);' -pe 's/<ref/\n<ref/g;' -pe 's/(?=<ref).*(?<=<\/ref>)//g;' -pe 's/(?=<ref).*(?<=\/>)//g;' | tr -d '\n' | tr '\t' '\n' | sed -e 's/^ *//g' -e 's/<page>/@page/g' -e 's/<title>/\a/g' -e 's/<\/title>/\t/g' -e 's/<wkb_geometry>//g' -e 's/<\/wkb_geometry>/\t/g' -e 's/<fid>//g' -e 's/<\/fid>/\t/g' -e 's/^=\+.*'${section}'.*=\+$/@mysection/Ig' | grep -vi -e '^$' -e '^(' -e '^{' -e '^}' -e '^|' -e '^#' -e '^\*' -e '^=' -e '^:' -e '^_' -e '^&quot;' -e '^&lt;' -e '^\[\[file' -e '^\[\[category' -e '^\[\[image' -e '^<' -e '^<\/' -e '^http:' -e '^note:' -e '^file:' -e '^url=' -e '^[0-9]' -e '^•' -e '^-' | grep -A1 -e '^@page' -e '^@mysection' | grep -v -e '^--' -e '^@page' -e '^@mysection' | tr -s " " | tr -d '\n' | tr '\a' '\n' | sed -n '1!p' | tr '\n' '\a' | sed -e 's/\[\[/\n\[\[/g' -e 's/\]\]/\]\]\n/g' | sed -e 's/^\[\[.*|/\[\[/g' -e 's/{{/\n{{/g' -e 's/}}[,:;]\?/}}\n/g' -e 's/ (/\nFOOBAR/g' | sed '/)\t/! s/)/FOOBAR\n/g' | grep -v '^{{\|}}' | grep -v -e 'FOOBAR' -e '^ \?[;:] \?$' | tr -d '\n' | tr '\a' '\n' | tr -s '  ' | sed -e "s/'''//g" -e 's/\[\[//g' -e 's/\]\]//g' -e 's/\bSt\./St/g' -e 's/\bU\.S\.A\./USA/g' -e 's/\bU\.S\./US/g' -e 's/c\./c/g' -e 's/ ,/,/g' > ${file}/${file}_${section}.csv; done

### paste sections
# with fid + wkb_geometry
echo "enwiki_title"$'\t'"wkb_geometry"$'\t'"fid"$'\t'"intro"$'\t'"climat"$'\t'"description"$'\t'"ecolog"$'\t'"fauna"$'\t'"flora"$'\t'"geograph" > ${file}/${file}.csv
paste ${file}/${file}_intro.csv ${file}/${file}_climat.csv ${file}/${file}_description.csv ${file}/${file}_ecolog.csv ${file}/${file}_fauna.csv ${file}/${file}_flora.csv ${file}/${file}_geograph.csv | awk -F '\t' 'BEGIN {OFS="\t";} {print $1,$2,$3,$4,$8,$12,$16,$20,$24,$28}' >> ${file}/${file}.csv
# with fid
echo "enwiki_title"$'\t'"fid"$'\t'"intro"$'\t'"climat"$'\t'"description"$'\t'"ecolog"$'\t'"fauna"$'\t'"flora"$'\t'"geograph" > ${file}/${file}.csv
paste ${file}/${file}_intro.csv ${file}/${file}_climat.csv ${file}/${file}_description.csv ${file}/${file}_ecolog.csv ${file}/${file}_fauna.csv ${file}/${file}_flora.csv ${file}/${file}_geograph.csv | awk -F '\t' 'BEGIN {OFS="\t";} {print $1,$2,$3,$6,$9,$12,$15,$18,$21}' >> ${file}/${file}.csv

### extract links
# xml
echo '<xml>' > ${file}_links.xml
cat ${file}/${file}.csv | grep -oP '(?<=\[\[).*?(?=\||\]\])' | sort -u | while read link; do dd if=enwiki-latest-pages-articles-multistream.xml skip=$(grep $'\t'"${link^}"$'\t' enwiki-latest-pages-articles-multistream-index.csv | awk '{print $1}') count=1000000 iflag=skip_bytes,count_bytes | grep "<title>${link^}</title>" >> ${file}_links.xml; done
echo '</xml>' >> ${file}_links.xml
# intro
cat ${file}_links.xml | perl -MHTML::Entities -pe 'decode_entities($_);' -pe 's/<ref/\n<ref/g;' -pe 's/(?=<ref).*(?<=<\/ref>)//g;' -pe 's/(?=<ref).*(?<=\/>)//g;' | tr -d '\n' | tr '\t' '\n' | sed -e 's/^ *//g' -e 's/<page>/@page/g' -e 's/<title>/\a/g' -e 's/<\/title>/\t/g' -e 's/<wkb_geometry>//g' -e 's/<\/wkb_geometry>/\t/g' -e 's/<fid>//g' -e 's/<\/fid>/\t/g' -e 's/<text xml:space="preserve">/@text\n/g' | grep -vi -e '^$' -e '^(' -e '^{' -e '^}' -e '^|' -e '^#' -e '^\*' -e '^=' -e '^:' -e '^_' -e '^&quot;' -e '^&lt;' -e '^\[\[file' -e '^\[\[category' -e '^\[\[image' -e '^<' -e '^<\/' -e '^http:' -e '^note:' -e '^file:' -e '^url=' -e '^[0-9]' -e '^•' -e '^-' | grep -A1 '^@text' | grep -v -e '^@text' -e '^--' -e '^@page' > ${file}/${file}_links.tmp
# get fid
echo "fid"$'\t'"intro" > ${file}/${file}_links.csv
cat ${file}/${file}.csv | grep -noP '(?=\[\[).*?(?<=\]\])' | sed -e 's/:/\t/g' -e 's/\[\[/'"'''"'/g' -e 's/\]\]/'"'''"'/g' | while IFS=$'\t' read -a array; do fid=`sed -n "${array[0]}p" ${file}/${file}.csv | awk -F '\t' '{print $2}'`; def=`grep "${array[1]}" ${file}/${file}_links.tmp`; echo ${fid}$'\t'${def} | awk -F\t '$2' >> ${file}/${file}_links.csv; done