fairseq-generate \
    data/all-clean-km/data-bin/ \
    --source-lang en --target-lang km \
    --path checkpoints/checkpoint_best.pt \
    --beam 5 --lenpen 1.2 \
    --gen-subset valid \
    --remove-bpe=sentencepiece > valid-prediction.txt