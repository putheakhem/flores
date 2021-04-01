#!/bin/bash

# to configure
py=python3
subword=../../thirdparty/subword-nmt/subword_nmt

SRCS="km"
data=$(dirname "$0")
root=$data/../..
scripts=$root/scripts

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
 --input-src  $data/train.$src \
 --input-tgt  $data/train.$trg \
 --output-src $data/train-dpl.$src \
 --output-tgt $data/train-dpl.$trg || exit 0

# training subword model, seperate for source and target languages
# recommand using training data
# source language
bpe_size_src=8000
bpe_size_trg=8000

# source language
$py $subword/learn_bpe.py \
 -s $bpe_size_src \
 < $data/train-dpl.$src > $models/bpe.$src \
 || exit 0

# target language
$py $subword/learn_bpe.py \
 -s $bpe_size_trg \
 < $data/train-dpl.$trg > $models/bpe.$trg \
 || exit 0

# apply subword to train, dev, test, and other data
# source language
$py $subword/apply_bpe.py \
 -c $models/bpe.$src \
 < $data/train-dpl.$src > $data/train-bpe.$src \
 < $data/valid.$src > $data/valid-bpe.$src \
 < $data/test.$src > $data/test-bpe.$src 
 || exit 0

# target language
$py $subword/apply_bpe.py \
 -c $models/bpe.$trg \
 < $data/train-dpl.$trg > $data/train-bpe.$trg \
 < $data/valid.$trg > $data/train-bpe.$trg \
 < $data/test.$trg > $data/test-bpe.$trg
 || exit 0


 # Valid 
echo "Preprocessing"
for SOMESRC in $SRCS; do
  echo "Binarizing ${SOMESRC}"
  fairseq-preprocess \
    --source-lang $SOMESRC --target-lang en \
    --destdir $data \
    --joined-dictionary \
    --workers 4 \
    --trainpref $data/train-bpe \
    --validpref $data/valid-bpe \
    --validpref $data/test-bpe
done


###########################
# SentencePiece: Not used
# # training subword model, seperate for source and target languages
# # recommand using training data
# # source language
# spm_train=$scripts/spm_train.py
# spm_encode=$scripts/spm_encode.py
# 
# $py $spm_train \
#  --input=$data/data-dpl.$src \
#  --model_prefix=$models/spm.$src \
#  --vocab_size=$spm_size_src \
#  --character_coverage=1.0 \
#  --model_type=bpe || exit 0
# 
# # target language
# $py $spm_train \
#  --input=$data/data-dpl.$trg \
#  --model_prefix=$models/spm.$trg \
#  --vocab_size=$spm_size_trg \
#  --character_coverage=1.0 \
#  --model_type=bpe || exit 0
# 
# # apply subword to train, dev, test, and other data
# # `--min-len` and `--max-len` should be used only when applying on train data
# # source language
# $py $spm_encode \
#  --model $models/spm.$src.model \
#  --output_format=piece \
#  --inputs $data/data-dpl.$src \
#  --outputs $data/data-spm.$src \
#  --min-len $train_minlen --max-len $train_maxlen || exit 0
# 
# $py $spm_encode \
#  --model $models/spm.$trg.model \
#  --output_format=piece \
#  --inputs $data/data-dpl.$trg \
#  --outputs $data/data-spm.$trg \
#  --min-len $train_minlen --max-len $train_maxlen || exit 0


