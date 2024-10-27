-- 7.3.1 delete_agent_related_data

DROP TRIGGER IF EXISTS delete_agent_related_data;

CREATE TRIGGER delete_agent_related_data
AFTER DELETE ON agent
FOR EACH ROW
BEGIN
  DECLARE _staff_id INT;
  DECLARE _contact_info_id INT;

  SELECT staff_id INTO _staff_id FROM agent WHERE id = OLD.id;
  SELECT contact_info_id INTO _contact_info_id FROM staff WHERE id = _staff_id;

  DELETE FROM call_service WHERE call_id IN (SELECT id FROM `call` WHERE agent_id = OLD.id);
  DELETE FROM call_issue WHERE call_id IN (SELECT id FROM `call` WHERE agent_id = OLD.id);
  DELETE FROM `call` WHERE agent_id = OLD.id;
  DELETE FROM feedback WHERE agent_id = OLD.id;
  DELETE FROM staff WHERE id = _staff_id;
  DELETE FROM contact_info WHERE id = _contact_info_id;
END;

DELETE FROM agent WHERE id = 1;

CALL fetch_agent_related_data(1);

-- 7.3.2 delete_supervisor_related_data

DROP TRIGGER IF EXISTS delete_supervisor_related_data;

CREATE TRIGGER delete_supervisor_related_data
AFTER DELETE ON supervisor
FOR EACH ROW
BEGIN
  DECLARE _staff_id INT;
  DECLARE _contact_info_id INT;
  DECLARE _new_supervisor_id INT;

  SELECT staff_id INTO _staff_id FROM supervisor WHERE id = OLD.id;
  SELECT contact_info_id INTO _contact_info_id FROM staff WHERE id = _staff_id;

  -- Пошук наглядача з найменшою кількістю агентів
  SELECT id INTO _new_supervisor_id FROM supervisor
  WHERE id != OLD.id
  ORDER BY (SELECT COUNT(*) FROM agent WHERE supervisor_id = supervisor.id) ASC
  LIMIT 1;

  --  Перерозподіл агентів до нового наглядача
  UPDATE agent SET supervisor_id = _new_supervisor_id WHERE supervisor_id = OLD.id;

  DELETE FROM staff WHERE id = _staff_id;
  DELETE FROM contact_info WHERE id = _contact_info_id;
END;

DELETE FROM supervisor WHERE id = 7;

SELECT supervisor_id, contact_info_id, supervisor.staff_id, agent.id AS agent_id
FROM supervisor
JOIN agent ON agent.supervisor_id = supervisor.id
JOIN staff ON supervisor.staff_id = staff.id
JOIN contact_info ON staff.contact_info_id = contact_info.id
WHERE supervisor.id IN (21);

-- 7.3.3 delete_customer_related_data

DROP TRIGGER IF EXISTS delete_customer_related_data;

CREATE TRIGGER delete_customer_related_data
AFTER DELETE ON customer
FOR EACH ROW
BEGIN
  DELETE FROM call_service WHERE call_id IN (SELECT id FROM `call` WHERE customer_id = OLD.id);
  DELETE FROM call_issue WHERE call_id IN (SELECT id FROM `call` WHERE customer_id = OLD.id);
  DELETE FROM `call` WHERE customer_id = OLD.id;
  DELETE FROM feedback WHERE customer_id = OLD.id;
  DELETE FROM contact_info WHERE id = OLD.contact_info_id;
END;

SELECT `call`.*, call_service.service_id, call_issue.issue_id
FROM `call`
LEFT JOIN call_service ON `call`.id = call_service.call_id
LEFT JOIN call_issue ON `call`.id = call_issue.call_id
WHERE `call`.customer_id = 21;

SELECT * FROM feedback WHERE customer_id = 21;

SELECT contact_info.* FROM contact_info 
JOIN customer ON customer.contact_info_id = contact_info.id
WHERE customer.id = 21;

DELETE FROM customer WHERE id = 21;

-- 7.3.4 delete_call_related_data

DROP TRIGGER IF EXISTS delete_call_related_data;

CREATE TRIGGER delete_call_related_data
AFTER DELETE ON `call`
FOR EACH ROW
BEGIN
  DELETE FROM call_service WHERE call_id = OLD.id;
  DELETE FROM call_issue WHERE call_id = OLD.id;
END;

DELETE FROM `call` WHERE id = 10;

SELECT `call`.*, call_service.service_id, call_issue.issue_id
FROM `call`
LEFT JOIN call_service ON `call`.id = call_service.call_id
LEFT JOIN call_issue ON `call`.id = call_issue.call_id
WHERE `call`.id = 10;

-- 7.3.5 auto_assign_supervisor

CREATE TRIGGER auto_assign_supervisor
BEFORE INSERT ON agent
FOR EACH ROW
BEGIN
  DECLARE _new_supervisor_id INT;

  SELECT id INTO _new_supervisor_id FROM supervisor
  ORDER BY (SELECT COUNT(*) FROM agent WHERE supervisor_id = supervisor.id) ASC
  LIMIT 1;

  SET NEW.supervisor_id = _new_supervisor_id;
END;


INSERT INTO contact_info (name, number, email)
VALUES ('John Doe', '123-456-7890', 'john.doe@example.com');

INSERT INTO staff (salary, hire_date, contact_info_id)
VALUES (50000.00, '2023-01-15', 1001);

INSERT INTO agent (staff_id) VALUES (101);

-- Verify the results
SELECT * FROM staff;
SELECT * FROM agent;