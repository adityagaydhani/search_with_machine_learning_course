set -x

# Setup
cd /workspace/search_with_machine_learning_course

### LEVEL 1 ###

# Run createContentTrainingData as is
python week2/createContentTrainingData.py --output /workspace/datasets/fasttext/labeled_products.txt

# Shuffle
shuf /workspace/datasets/fasttext/labeled_products.txt --random-source=<(seq 99999) > /workspace/datasets/fasttext/shuffled_labeled_products.txt

# Create training and test datasets
head -10000 /workspace/datasets/fasttext/shuffled_labeled_products.txt > /workspace/datasets/fasttext/training_data.txt
tail -10000 /workspace/datasets/fasttext/shuffled_labeled_products.txt > /workspace/datasets/fasttext/test_data.txt

# Train the model with default params
~/fastText-0.9.2/fasttext supervised -input /workspace/datasets/fasttext/training_data.txt -output model_sample_default

# Test the default model at various ranks
~/fastText-0.9.2/fasttext test model_sample_default.bin /workspace/datasets/fasttext/test_data.txt
~/fastText-0.9.2/fasttext test model_sample_default.bin /workspace/datasets/fasttext/test_data.txt 5
~/fastText-0.9.2/fasttext test model_sample_default.bin /workspace/datasets/fasttext/test_data.txt 10

# Train the model with custom params
~/fastText-0.9.2/fasttext supervised -input /workspace/datasets/fasttext/training_data.txt -output model_sample_2512 -epoch 25 -lr 1.0 -wordNgrams 2

# Test the model with custom params
~/fastText-0.9.2/fasttext test model_sample_2512.bin /workspace/datasets/fasttext/test_data.txt

# Normalize training and test datasets
cat /workspace/datasets/fasttext/training_data.txt |sed -e "s/\([.\!?,'/()]\)/ \1 /g" | tr "[:upper:]" "[:lower:]" | sed "s/[^[:alnum:]_]/ /g" | tr -s ' ' > /workspace/datasets/fasttext/normalized_training_data.txt
cat /workspace/datasets/fasttext/test_data.txt |sed -e "s/\([.\!?,'/()]\)/ \1 /g" | tr "[:upper:]" "[:lower:]" | sed "s/[^[:alnum:]_]/ /g" | tr -s ' ' > /workspace/datasets/fasttext/normalized_test_data.txt

# Train and test the model on normalized data with custom params
~/fastText-0.9.2/fasttext supervised -input /workspace/datasets/fasttext/normalized_training_data.txt -output model_sample_normalized_2512 -epoch 25 -lr 1.0 -wordNgrams 2
~/fastText-0.9.2/fasttext test model_sample_normalized_2512.bin /workspace/datasets/fasttext/normalized_test_data.txt

# Remove labels with less than 500 samples
python week2/createContentTrainingData.py --output /workspace/datasets/fasttext/pruned_labeled_products.txt --min_products 500

# Create pruned and normalized training and test datasets
shuf /workspace/datasets/fasttext/pruned_labeled_products.txt --random-source=<(seq 99999) | head -10000 | sed -e "s/\([.\!?,'/()]\)/ \1 /g" | tr "[:upper:]" "[:lower:]" | sed "s/[^[:alnum:]_]/ /g" > /workspace/datasets/fasttext/pruned_normalized_training_data.txt
shuf /workspace/datasets/fasttext/pruned_labeled_products.txt --random-source=<(seq 99999) | tail -10000 | sed -e "s/\([.\!?,'/()]\)/ \1 /g" | tr "[:upper:]" "[:lower:]" | sed "s/[^[:alnum:]_]/ /g" > /workspace/datasets/fasttext/pruned_normalized_test_data.txt

# Train and test the model on pruned data with custom params
~/fastText-0.9.2/fasttext supervised -input /workspace/datasets/fasttext/pruned_normalized_training_data.txt -output model_sample_pruned_normalized_2512 -epoch 25 -lr 1.0 -wordNgrams 2
~/fastText-0.9.2/fasttext test model_sample_pruned_normalized_2512.bin /workspace/datasets/fasttext/pruned_normalized_test_data.txt


### LEVEL 2 ###

# Get unlabeled list of product names
cut -d' ' -f2- /workspace/datasets/fasttext/shuffled_labeled_products.txt > /workspace/datasets/fasttext/titles.txt

# Use fasttext skipgram model
~/fastText-0.9.2/fasttext skipgram -input /workspace/datasets/fasttext/titles.txt -output /workspace/datasets/fasttext/title_model

# Run nn
~/fastText-0.9.2/fasttext nn /workspace/datasets/fasttext/title_model.bin

# Normalize the data
cat /workspace/datasets/fasttext/titles.txt | sed -e "s/\([.\!?,'/()]\)/ \1 /g" | tr "[:upper:]" "[:lower:]" | sed "s/[^[:alnum:]]/ /g" | tr -s ' ' > /workspace/datasets/fasttext/normalized_titles.txt

# Train and run the model on normalized data with minCount 20
~/fastText-0.9.2/fasttext skipgram -input /workspace/datasets/fasttext/normalized_titles.txt -output /workspace/datasets/fasttext/normalized_title_model -minCount 20
~/fastText-0.9.2/fasttext nn /workspace/datasets/fasttext/normalized_title_model.bin

### LEVEL 3 ###

# Get top words
cat /workspace/datasets/fasttext/normalized_titles.txt | tr " " "\n" | grep "...." | sort | uniq -c | sort -nr | head -1000 | grep -oE '[^ ]+$' > /workspace/datasets/fasttext/top_words.txt

# Copy synonyms to docker
docker cp /workspace/datasets/fasttext/synonyms.csv opensearch-node1:/usr/share/opensearch/config/synonyms.csv

# Reindex after modifying bbuy_products conf
./index-data.sh -r -p /workspace/search_with_machine_learning_course/week2/conf/bbuy_products.json