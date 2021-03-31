#!/bin/bash

# to configure
mosesdir=../../thirdparty/mosesdecoder

if [ $# -lt 2 ];
then
  echo "Usage: eval.sh <gold> <system>"
  exit 0
fi

gold=$1; shift
system=$1; shift

mkdir -p .tmp_eval

cat $gold \
 | sed 's/\@\@ //g' \
 | $mosesdir/scripts/recaser/detruecase.perl \
 | $mosesdir/scripts/tokenizer/detokenizer.perl -l en \
 > .tmp_eval/$(basename $gold) || exit 0

cat $system \
 | sed 's/\@\@ //g' \
 | $mosesdir/scripts/recaser/detruecase.perl \
 | $mosesdir/scripts/tokenizer/detokenizer.perl -l en \
 | $mosesdir/scripts/generic/multi-bleu-detok.perl .tmp_eval/$(basename $gold) \
 || exit 0

rm -fr .tmp_eval
