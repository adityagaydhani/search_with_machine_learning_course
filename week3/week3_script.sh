set -x

cd /workspace/search_with_machine_learning_course/week3

### LEVEL 1 ###

# Set roll-up query threshold to 1000
python create_labeled_queries.py --min_queries 1000
# Number of unique rolled-up categories: 406

# Shuffle
shuf /workspace/datasets/fasttext/labeled_queries.txt --random-source=<(seq 99999) > /workspace/datasets/fasttext/shuffled_labeled_queries.txt

# Create training and test datasets
head -50000 /workspace/datasets/fasttext/shuffled_labeled_queries.txt > /workspace/datasets/fasttext/training_data.txt
tail -10000 /workspace/datasets/fasttext/shuffled_labeled_queries.txt > /workspace/datasets/fasttext/test_data.txt

# Train the model with default params
~/fastText-0.9.2/fasttext supervised -input /workspace/datasets/fasttext/training_data.txt -output model_sample_default

# Test the default model at various ranks
~/fastText-0.9.2/fasttext test model_sample_default.bin /workspace/datasets/fasttext/test_data.txt
# N       10000
# P@1     0.477
# R@1     0.47

~/fastText-0.9.2/fasttext test model_sample_default.bin /workspace/datasets/fasttext/test_data.txt 3
# N       10000
# P@3     0.212
# R@3     0.635

~/fastText-0.9.2/fasttext test model_sample_default.bin /workspace/datasets/fasttext/test_data.txt 5
# N       10000
# P@5     0.141
# R@5     0.704

# Train the model with custom params
~/fastText-0.9.2/fasttext supervised -input /workspace/datasets/fasttext/training_data.txt -output model_sample_2512 -epoch 25 -lr 0.5 -wordNgrams 2

# Test the model with custom params
~/fastText-0.9.2/fasttext test model_sample_2512.bin /workspace/datasets/fasttext/test_data.txt
# N       10000
# P@1     0.525
# R@1     0.525

~/fastText-0.9.2/fasttext test model_sample_2512.bin /workspace/datasets/fasttext/test_data.txt 3
# N       10000
# P@3     0.236
# R@3     0.707

~/fastText-0.9.2/fasttext test model_sample_2512.bin /workspace/datasets/fasttext/test_data.txt 5
# N       10000
# P@5     0.154
# R@5     0.768

# Set roll-up query threshold to 10000
python create_labeled_queries.py --min_queries 10000 --output /workspace/datasets/fasttext/labeled_queries_10000.txt
# Number of unique rolled-up categories: 79

# Shuffle
shuf /workspace/datasets/fasttext/labeled_queries_10000.txt  --random-source=<(seq 99999) > /workspace/datasets/fasttext/shuffled_labeled_queries_10000.txt

# Create training and test datasets
head -50000 /workspace/datasets/fasttext/shuffled_labeled_queries_10000.txt > /workspace/datasets/fasttext/training_data_10000.txt
tail -10000 /workspace/datasets/fasttext/shuffled_labeled_queries_10000.txt > /workspace/datasets/fasttext/test_data_10000.txt

# Train the model with custom params
~/fastText-0.9.2/fasttext supervised -input /workspace/datasets/fasttext/training_data_10000.txt -output model_sample_10000_2512 -epoch 25 -lr 0.5 -wordNgrams 2

# Test the model with custom params
~/fastText-0.9.2/fasttext test model_sample_10000_2512.bin /workspace/datasets/fasttext/test_data_10000.txt
# N       10000
# P@1     0.576
# R@1     0.576

~/fastText-0.9.2/fasttext test model_sample_10000_2512.bin /workspace/datasets/fasttext/test_data_10000.txt 3
# N       10000
# P@3     0.258
# R@3     0.774

~/fastText-0.9.2/fasttext test model_sample_10000_2512.bin /workspace/datasets/fasttext/test_data_10000.txt 5
# N       10000
# P@5     0.167
# R@5     0.834

### LEVEL 2 ###

# Run utilities/query.py with query classifier model
python ../utilities/query.py -q model_sample_10000_2512.bin 