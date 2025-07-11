WITH reviews AS (
  SELECT * FROM UNNEST([
    STRUCT(1 AS product_id, 101 AS review_id, 5 AS rating, TRUE AS has_image, 15 AS helpfulness_score, DATE '2024-01-01' AS review_date, 120 AS word_count),
    STRUCT(1, 102, 4, FALSE, 20, DATE '2024-01-03', 80),
    STRUCT(1, 103, 5, FALSE, 5, DATE '2024-01-02', 50),
    STRUCT(1, 104, 3, TRUE, 25, DATE '2024-01-05', 30),
    STRUCT(1, 105, 5, TRUE, 10, DATE '2024-01-06', 70),
    STRUCT(2, 201, 4, TRUE, 10, DATE '2024-01-01', 90),
    STRUCT(2, 202, 4, FALSE, 15, DATE '2024-01-02', 110),
    STRUCT(2, 203, 3, TRUE, 30, DATE '2024-01-03', 40),
    STRUCT(2, 204, 5, TRUE, 5, DATE '2024-01-04', 60),
    STRUCT(2, 205, 5, FALSE, 12, DATE '2024-01-05', 100)
  ])
),

scored_reviews AS (
  SELECT
    *,
    (
      rating * 5 +                     -- Rating is important, but not dominant
      IF(has_image, 10, 0) +          -- Bonus if review includes an image
      SAFE_DIVIDE(word_count, 20) +   -- more words = better review (ofc it's not always the case)
      helpfulness_score * 1 +         -- Direct votes
      DATE_DIFF(CURRENT_DATE(), review_date, DAY) * -0.1  -- Favor recency (newer = better)
    ) AS relevance_score
  FROM reviews
),

ranked_reviews AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY product_id
      ORDER BY relevance_score DESC
    ) AS rn
  FROM scored_reviews
)

-- Final selection: Top 3 per product
SELECT
  product_id,
  review_id,
  rating,
  has_image,
  word_count,
  helpfulness_score,
  review_date,
  ROUND(relevance_score, 2) AS relevance_score
FROM ranked_reviews
WHERE rn <= 3
ORDER BY product_id, rn;
`