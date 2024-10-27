-- Запит 1: Середній рейтинг для кожної послуги
-- Початковий запит:

SELECT s.id AS service_id, s.name AS service_name, AVG(f.rating) AS average_rating
FROM service s
JOIN call_service cs ON s.id = cs.service_id
JOIN `call` c ON cs.call_id = c.id
JOIN feedback f ON c.customer_id = f.customer_id
GROUP BY s.id;

-- Створення індексу для полегшення з'єднань
CREATE INDEX idx_service_id ON call_service (service_id);
CREATE INDEX idx_call_id ON call_service (call_id);
CREATE INDEX idx_customer_id ON `call` (customer_id);


-- Запит 2: Сумарна тривалість дзвінків для кожного агента
-- Початковий запит:

SELECT
  a.id AS agent_id,
  ci.name AS agent_name,
  SUM(TIMESTAMPDIFF(SECOND, c.start_at, c.end_at)) AS total_duration_seconds
FROM agent a
JOIN staff s ON a.staff_id = s.id
JOIN contact_info ci ON s.contact_info_id = ci.id
JOIN `call` c ON a.id = c.agent_id
GROUP BY a.id, ci.name;

-- Створення індексу для полегшення з'єднань
CREATE INDEX idx_agent_id ON `call` (agent_id);


-- Запит 3: Найпопулярніша проблема серед відгуків
-- Початковий запит:

SELECT i.id AS issue_id, i.description AS popular_issue, COUNT(ci.issue_id) AS occurrence_count
FROM issue i
LEFT JOIN call_issue ci ON i.id = ci.issue_id
GROUP BY i.id
ORDER BY occurrence_count DESC
LIMIT 1;

-- Створення індексу для полегшення з'єднань
CREATE INDEX idx_issue_id ON call_issue (issue_id);