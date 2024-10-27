SELECT s.id AS service_id, s.name, COUNT(cs.call_id) AS usage_count
FROM service s
LEFT JOIN call_service cs ON s.id = cs.service_id
GROUP BY s.id;

SELECT a.id AS agent_id, COUNT(f.id) AS feedback_count
FROM agent a
LEFT JOIN feedback f ON a.id = f.agent_id
GROUP BY a.id
ORDER BY feedback_count DESC
LIMIT 5;

SELECT s.id AS service_id, s.name, AVG(s.price) AS avg_price
FROM service s
GROUP BY s.id
ORDER BY avg_price DESC
LIMIT 5;

SELECT COUNT(*) AS agents_without_feedback
FROM agent a
LEFT JOIN feedback f ON a.id = f.agent_id
WHERE f.id IS NULL;

SELECT i.id AS issue_id, i.description AS common_issue, COUNT(ci.issue_id) AS occurrence_count
FROM issue i
LEFT JOIN call_issue ci ON i.id = ci.issue_id
GROUP BY i.id
ORDER BY occurrence_count DESC
LIMIT 1;

SELECT s.id AS service_id, s.name AS service_name, AVG(f.rating) AS average_rating
FROM service s
JOIN call_service cs ON s.id = cs.service_id
JOIN `call` c ON cs.call_id = c.id
JOIN feedback f ON c.customer_id = f.customer_id
GROUP BY s.id;

SELECT COUNT(ci.issue_id) / COUNT(DISTINCT ca.id) AS avg_issues_per_call
FROM `call` ca
LEFT JOIN call_issue ci ON ca.id = ci.call_id;

SELECT HOUR(start_at) AS hour_of_day, COUNT(id) AS call_count
FROM `call`
GROUP BY hour_of_day;

SELECT a.id AS agent_id, COUNT(ci.call_id) AS issue_call_count
FROM agent a
LEFT JOIN call_issue ci ON a.id = ci.issue_id
GROUP BY a.id
ORDER BY issue_call_count DESC
LIMIT 3;

SELECT s.name AS service_name, MONTH(ca.start_at) AS month, COUNT(cs.call_id) AS call_count
FROM service s
LEFT JOIN call_service cs ON s.id = cs.service_id
LEFT JOIN `call` ca ON cs.call_id = ca.id
GROUP BY s.name, month;

SELECT COUNT(DISTINCT a.id) AS weekend_agent_count
FROM agent a
JOIN `call` ca ON a.id = ca.agent_id
WHERE DAYOFWEEK(ca.start_at) IN (1, 7);

SELECT s.id AS service_id, COUNT(DISTINCT a.id) AS agents_without_feedback_count
FROM service s
LEFT JOIN call_service cs ON s.id = cs.service_id
LEFT JOIN `call` ca ON cs.call_id = ca.id
LEFT JOIN agent a ON ca.agent_id = a.id
LEFT JOIN feedback f ON a.id = f.agent_id
WHERE f.id IS NULL
GROUP BY s.id;

SELECT i.id AS issue_id, i.description AS common_issue, COUNT(ci.issue_id) AS occurrence_count
FROM issue i
LEFT JOIN call_issue ci ON i.id = ci.issue_id
GROUP BY i.id
ORDER BY occurrence_count DESC
LIMIT 1;

SELECT cu.id AS customer_id, ci.`name` AS customer_name
FROM customer cu
JOIN contact_info ci ON cu.contact_info_id = ci.id
WHERE cu.id NOT IN (SELECT DISTINCT customer_id FROM feedback);

SELECT s.name AS service_name, SUM(s.price) AS total_earnings
FROM call_service cs
JOIN service s ON cs.service_id = s.id
GROUP BY s.name;

SELECT ci.name AS customer_name, f.rating AS highest_rating
FROM customer cu
JOIN contact_info ci ON cu.contact_info_id = ci.id
JOIN feedback f ON cu.id = f.customer_id
WHERE f.rating = (SELECT MAX(rating) FROM feedback);

SELECT
  a.id AS agent_id,
  a.staff_id,
  COUNT(c.id) AS call_count
FROM agent a
JOIN `call` c ON a.id = c.agent_id
WHERE MONTH(c.start_at) = 5  -- Specify the desired month
GROUP BY a.id, a.staff_id
ORDER BY call_count DESC
LIMIT 1;

SELECT
  ca.id AS call_id,
  ca.start_at,
  ca.end_at,
  s.name AS service_name,
  s.price
FROM `call` ca
JOIN call_service cs ON ca.id = cs.call_id
JOIN service s ON cs.service_id = s.id
WHERE s.price > (SELECT AVG(price) FROM service);

SELECT
  a.id AS agent_id,
  a.staff_id,
  AVG(CAST(f.rating AS DECIMAL(3, 2))) AS average_rating
FROM agent a
LEFT JOIN feedback f ON a.id = f.agent_id
WHERE a.id IN (
    SELECT agent_id
    FROM feedback
    GROUP BY agent_id
    HAVING COUNT(*) >= 2
  )
GROUP BY a.id, a.staff_id
ORDER BY average_rating DESC
LIMIT 1;

SELECT
  a.id AS agent_id,
  a.staff_id,
  COUNT(c.id) AS total_calls,
  AVG(TIMESTAMPDIFF(SECOND, c.start_at, c.end_at)) AS average_call_duration
FROM agent a
JOIN `call` c ON a.id = c.agent_id
WHERE a.id = (
    SELECT agent_id
    FROM `call`
    GROUP BY agent_id
    ORDER BY COUNT(id) DESC
    LIMIT 1
  )
GROUP BY a.id, a.staff_id;

-- 13)
SELECT
  a.id AS agent_id,
  ci.name AS agent_name,
  SUM(TIMESTAMPDIFF(SECOND, c.start_at, c.end_at)) AS total_duration_seconds
FROM agent a
JOIN staff s ON a.staff_id = s.id
JOIN contact_info ci ON s.contact_info_id = ci.id
JOIN `call` c ON a.id = c.agent_id
GROUP BY a.id, ci.name;