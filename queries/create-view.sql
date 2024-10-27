--
DROP VIEW IF EXISTS StaffView;

CREATE VIEW StaffView AS
SELECT
    s.id AS staff_id,
    s.salary,
    s.hire_date,
    c.name AS staff_name,
    c.number AS staff_contact_number,
    sv.id AS supervisor_id
FROM staff s
    JOIN contact_info c ON s.contact_info_id = c.id
    LEFT JOIN supervisor sv ON s.id = sv.staff_id;

SELECT * FROM StaffView;

--

DROP VIEW IF EXISTS CallDetailsView;

CREATE VIEW CallDetailsView AS
SELECT
    ca.id AS call_id,
    ca.start_at,
    ca.end_at,
    cu.id AS customer_id,
    a.id AS agent_id,
    s.name AS service_name,
    iss.description AS issue_description
FROM `call` ca
    JOIN customer cu ON ca.customer_id = cu.id
    JOIN agent a ON ca.agent_id = a.id
    LEFT JOIN call_service cs ON ca.id = cs.call_id
    LEFT JOIN service s ON cs.service_id = s.id
    LEFT JOIN call_issue ci ON ca.id = ci.call_id
    LEFT JOIN issue iss ON ci.issue_id = iss.id;
    
SELECT * FROM CallDetailsView;

-- 
DROP VIEW IF EXISTS CustomerFeedBackView;

CREATE VIEW CustomerFeedbackView AS
SELECT
    c.id AS customer_id,
    ci.`name` AS customer_name,
    ci.`number` AS customer_contact_number,
    a.id AS agent_id,
    f.id AS feedback_id,
    f.rating,
    f.comments
FROM
    feedback f
    JOIN customer c ON f.customer_id = c.id
    JOIN agent a ON f.agent_id = a.id
    JOIN contact_info ci ON c.contact_info_id = ci.id;
    
SELECT * FROM CustomerFeedbackView;