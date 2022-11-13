import os
import argparse
import xml.etree.ElementTree as ET
import pandas as pd
import numpy as np
import csv

from tree import CategoryTree

# Useful if you want to perform stemming.
import nltk
stemmer = nltk.stem.PorterStemmer()

categories_file_name = r'/workspace/datasets/product_data/categories/categories_0001_abcat0010000_to_pcmcat99300050000.xml'

queries_file_name = r'/workspace/datasets/train.csv'
output_file_name = r'/workspace/datasets/fasttext/labeled_queries.txt'

parser = argparse.ArgumentParser(description='Process arguments.')
general = parser.add_argument_group("general")
general.add_argument("--min_queries", default=1,  type=int, help="The minimum number of queries per category label (default is 1)")
general.add_argument("--output", default=output_file_name, help="the file to output to")

args = parser.parse_args()
output_file_name = args.output

if args.min_queries:
    min_queries = int(args.min_queries)

# The root category, named Best Buy with id cat00000, doesn't have a parent.
root_category_id = 'cat00000'

tree = ET.parse(categories_file_name)
root = tree.getroot()

# Parse the category XML file to map each category id to its parent category id in a dataframe.
categories = []
parents = []
for child in root:
    id = child.find('id').text
    cat_path = child.find('path')
    cat_path_ids = [cat.find('id').text for cat in cat_path]
    leaf_id = cat_path_ids[-1]
    if leaf_id != root_category_id:
        categories.append(leaf_id)
        parents.append(cat_path_ids[-2])
parents_df = pd.DataFrame(list(zip(categories, parents)), columns =['category', 'parent'])

# Read the training data into pandas, only keeping queries with non-root categories in our category tree.
queries_df = pd.read_csv(queries_file_name)[['category', 'query']]
queries_df = queries_df[queries_df['category'].isin(categories)]

# IMPLEMENT ME: Convert queries to lowercase, and optionally implement other normalization, like stemming.
queries_df["query"] = queries_df["query"]\
                        .str.lower()\
                        .replace("[^a-z0-9]", " ", regex=True)\
                        .replace("\s+", " ", regex=True)\
                        .str.strip()

stemmed_token_map = {token: stemmer.stem(token) for token in set(token for query in queries_df["query"] for token in query.split())}
queries_df["query"] = queries_df["query"].apply(lambda query: " ".join(stemmed_token_map.get(token, token) for token in query.split()))

# IMPLEMENT ME: Roll up categories to ancestors to satisfy the minimum number of queries per category.
category_queries_map = queries_df.groupby(["category"])["query"].apply(list).to_dict()

category_tree = CategoryTree()
category_tree.build_tree(parents_df.set_index("category")["parent"].to_dict())
category_tree.populate_queries(category_queries_map)
rolled_up_category_query_map = category_tree.get_rolled_up_categories(args.min_queries)
print("Number of unique rolled-up categories: ", len(rolled_up_category_query_map))

queries_df = pd.DataFrame([[category, query] for category, queries in rolled_up_category_query_map.items() for query in queries],
                            columns=["category", "query"])

# Create labels in fastText format.
queries_df['label'] = '__label__' + queries_df['category']

# Output labeled query data as a space-separated file, making sure that every category is in the taxonomy.
queries_df = queries_df[queries_df['category'].isin(categories)]
queries_df['output'] = queries_df['label'] + ' ' + queries_df['query']
queries_df[['output']].to_csv(output_file_name, header=False, sep='|', escapechar='\\', quoting=csv.QUOTE_NONE, index=False)
