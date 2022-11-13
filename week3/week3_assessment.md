## Assessment ##

### For query classification: ###
- How many unique categories did you see in your rolled up training data when you set the minimum number of queries per category to 1000? To 10000?
    * min_queries = 1000 -> 406
    * min_queries = 10000 -> 79

- What were the best values you achieved for R@1, R@3, and R@5? You should have tried at least a few different models, varying the minimum number of queries per category, as well as trying different fastText parameters or query normalization. Report at least 2 of your runs.
    * Config: `-min_queries 1000 -epoch 25 -lr 0.5 -wordNgrams 2`
        * R@1 = 0.525
        * R@3 = 0.707
        * R@5 = 0.768
    * Config: `-min_queries 10000 -epoch 25 -lr 0.5 -wordNgrams 2`
        * R@1 = 0.576
        * R@3 = 0.774
        * R@5 = 0.834
    * See `week3_script.sh` for more details.

### For integrating query classification with search: ###
- Give 2 or 3 examples of queries where you saw a dramatic positive change in the results because of filtering. Make sure to include the classifier output for those queries.
    * "macbook pro" - Saw 27 highly relevant results because of filtering, returns 2151 fuzzy-matched results otherwise.
        ```
        (('__label__pcmcat247400050001', '__label__abcat0515025', '__label__abcat0206000', '__label__abcat0500000', '__label__abcat0101001', '__label__abcat0513000', '__label__pcmcat247400050000', '__label__abcat0501000', '__label__abcat0515027', '__label__pcmcat164200050013'), array([8.21121752e-01, 1.19407259e-01, 1.09105930e-02, 1.08871181e-02,
       9.74709075e-03, 8.68763588e-03, 7.24017667e-03, 1.74299744e-03,
       1.02040998e-03, 7.07600673e-04]))
        ```
    * beats headphones - Significantly prunes the result set, from 3942 to 631.
        ```
        (('__label__pcmcat144700050004', '__label__abcat0204000', '__label__abcat0208011', '__label__abcat0811002', '__label__abcat0715000', '__label__abcat0207000', '__label__pcmcat247400050000', '__label__abcat0515000', '__label__abcat0307005', '__label__abcat0800000'), array([9.05176222e-01, 8.79240781e-02, 3.95042636e-03, 6.16675185e-04,
       5.32191829e-04, 4.48344130e-04, 2.20046451e-04, 1.85854471e-04,
       1.05042331e-04, 6.98024523e-05]))
        ```

- Give 2 or 3 examples of queries where filtering hurt the results, either because the classifier was wrong or for some other reason. Again, include the classifier output for those queries.
    * "pirates of the caribbean" - While the classifier predicts the category label '__label__cat02015' (movies and tv shows), which seems to be logical, the correct label for this query is "__label__abcat0706002" (wii games) based on logs.
        ```
        (('__label__cat02015', '__label__cat02001', '__label__cat02009', '__label__abcat0703002', '__label__pcmcat232900050017', '__label__cat02010', '__label__cat09000', '__label__abcat0707000', '__label__abcat0900000', '__label__pcmcat174700050005'), array([9.93172646e-01, 2.46153073e-03, 1.08475855e-03, 5.37450367e-04,
       4.70082683e-04, 4.22920915e-04, 2.92676908e-04, 2.39460991e-04,
       1.52575594e-04, 1.42610777e-04]))
        ```