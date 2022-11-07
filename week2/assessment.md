# Project Assessment
## For classifying product names to categories:
- What precision (P@1) were you able to achieve?
    * 0.964

- What fastText parameters did you use?
    * epochs=25, lr=1.0, wordNgrams=2

- How did you transform the product names?
    * Remove all non-alphanumeric characters other than underscore.
    * Convert all letters to lowercase.
    * Trim excess space characters so that tokens are separated by a single space.

- How did you prune infrequent category labels, and how did that affect your precision?
    * Removed all labels with count less than 500. Precision went up from 0.65 to 0.964

## For deriving synonyms from content:

- What were the results for your best model in the tokens used for evaluation?

    ```

    # headphones

    headphone 0.925745
    earbud 0.884394
    ear 0.859699
    earphones 0.809809
    hesh 0.751042
    bud 0.733992
    behind 0.726435
    earbuds 0.711691
    2xl 0.691181
    canceling 0.6868

    # nintendo

    ds 0.894645
    wii 0.883424
    3ds 0.823596
    rabbids 0.77637
    gamecube 0.750945
    bakugan 0.737529
    nicktoons 0.733834
    petz 0.723883
    zelda 0.718888
    mysims 0.713198

    # ps2

    ps3 0.844369
    gba 0.801279
    guide 0.773962
    nhl 0.763285
    gamecube 0.748346
    naruto 0.747259
    wwe 0.740891
    unleashed 0.735431
    codes 0.735405
    code 0.73307

    # holiday

    hanukkah 0.799828
    kwanzaa 0.789995
    cumpleaños 0.78743
    navidad 0.781393
    happy 0.764067
    joy 0.760176
    feliz 0.757238
    gift 0.757231
    gc 0.756623
    thank 0.755052

    ```

- What fastText parameters did you use?
    * epoch=25 and minCount=20

- How did you transform the product names?
    ```
    cat /workspace/datasets/fasttext/titles.txt | sed -e "s/\([.\!?,'/()]\)/ \1 /g" | tr "[:upper:]" "[:lower:]" | sed "s/[^[:alnum:]]/ /g" | tr -s ' ' > /workspace/datasets/fasttext/normalized_titles.txt
    ```

## For integrating synonyms with search:

- How did you transform the product names (if different than previously)?
    * Used default transformations

- What threshold score did you use?
    * 0.75

- Were you able to find the additional results by matching synonyms?
    Yes. It was interesting to see more relevant results for the query `nespresso`