#!/bin/bash

# configure your python path if you have many python version
py=python3

data=$(dirname "$0")
root=$data/../..
scripts=$root/scripts

spm_train=$scripts/spm_train.py
spm_encode=$scripts/spm_encode.py

models=$data/models
mkdir -p $models

src=en
trg=km

spm_size_src=8000
spm_size_trg=800
train_minlen=1  # remove sentences with <1 BPE token
train_maxlen=250  # remove sentences with >250 BPE tokens 

# remove doublicate
$py $scripts/deduplicate.py \
 --input-src  $data/data-true.$src \
 --input-tgt  $data/data-true.$trg \
 --output-src $data/data-dpl.$src \
 --output-tgt $data/data-dpl.$trg || exit 0

# training subword model, seperate for source and target languages
# recommand using training data
# source language
$py $spm_train \
 --input=$data/data-dpl.$src \
 --model_prefix=$models/spm.$src \
 --vocab_size=$spm_size_src \
 --character_coverage=1.0 \
 --model_type=bpe || exit 0

# target language
$py $spm_train \
 --input=$data/data-dpl.$trg \
 --model_prefix=$models/spm.$trg \
 --vocab_size=$spm_size_trg \
 --character_coverage=1.0 \
 --model_type=bpe || exit 0

# apply subword to train, dev, test, and other data
# `--min-len` and `--max-len` should be used only when applying on train data
# source language
$py $spm_encode \
 --model $models/spm.$src.model \
 --output_format=piece \
 --inputs $data/data-dpl.$src \
 --outputs $data/data-spm.$src \
 --min-len $train_minlen --max-len $train_maxlen || exit 0

$py $spm_encode \
 --model $models/spm.$trg.model \
 --output_format=piece \
 --inputs $data/data-dpl.$trg \
 --outputs $data/data-spm.$trg \
 --min-len $train_minlen --max-len $train_maxlen || exit 0


