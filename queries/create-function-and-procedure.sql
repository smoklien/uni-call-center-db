-- 7.2.1 calculate_last_month_earnings

DROP FUNCTION IF EXISTS `calculate_last_month_earnings`;

CREATE FUNCTION calculate_last_month_earnings(num_previous_months INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  DECLARE total_price DECIMAL(10,2);

  SELECT SUM(service.price) INTO total_price
  FROM callcenter.call_service
  JOIN callcenter.service ON call_service.service_id = service.id
  JOIN callcenter.`call` ON call_service.call_id = `call`.id
  WHERE `call`.end_at >= DATE_SUB(CURRENT_DATE, INTERVAL num_previous_months MONTH);

  RETURN total_price;
END;

SELECT CALCULATE_LAST_MONTH_EARNINGS(3);

-- 7.2.2 get_agent_total_calls

DROP PROCEDURE IF EXISTS get_agent_total_calls;

CREATE PROCEDURE get_agent_total_calls(IN start_date DATE, IN end_date DATE)
BEGIN
  SELECT 
    `call`.agent_id, 
    ci.`name` AS agent_name,
    COUNT(*) AS total_calls
  FROM 
    callcenter.`call`
  JOIN
    (
      SELECT
        agent.id AS agent_id,
        staff.contact_info_id
      FROM
        agent
      JOIN
        staff ON agent.staff_id = staff.id
    ) a ON `call`.agent_id = a.agent_id
  JOIN
    contact_info ci ON a.contact_info_id = ci.id
  WHERE 
    `call`.start_at >= start_date AND `call`.end_at <= end_date
  GROUP BY 
    a.agent_id, ci.`name`
    ORDER BY 
    total_calls;
END;

CALL get_agent_total_calls('2020-01-01', '2023-12-31');

-- 7.2.3 get_customer_feedback

DROP PROCEDURE IF EXISTS get_customer_feedback;

CREATE PROCEDURE get_customer_feedback()
BEGIN
  SELECT 
    agent.id AS agent_id, 
    contact_info.`name` AS agent_name,
    FORMAT(AVG(feedback.rating), 1) AS average_rating,
    COUNT(*) AS total_feedbacks
  FROM 
	callcenter.agent
    LEFT JOIN callcenter.feedback ON feedback.agent_id = agent.id
    JOIN callcenter.staff ON agent.staff_id = staff.id
    JOIN callcenter.contact_info ON staff.contact_info_id = contact_info.id
  GROUP BY 
    agent.id;
END;

CALL get_customer_feedback();

-- 7.2.4 most_popular_services

DROP PROCEDURE IF EXISTS most_popular_services;

CREATE PROCEDURE most_popular_services()
BEGIN
  SELECT service.id, service.`name`, COUNT(call_service.call_id) AS call_count
  FROM service
  JOIN call_service ON service.id = call_service.service_id
  GROUP BY service.id, service.`name`
  ORDER BY call_count DESC;
END;

CALL most_popular_services();

-- 7.2.5 fetch_agent_related_data

DROP PROCEDURE IF EXISTS fetch_agent_related_data;

CREATE PROCEDURE fetch_agent_related_data(_agent_id INT)
BEGIN
	SELECT `call`.id AS call_id, `call`.start_at, `call`.end_at, customer_id, call_service.service_id, call_issue.issue_id
	FROM `call`
	LEFT JOIN call_service ON `call`.id = call_service.call_id
	LEFT JOIN call_issue ON `call`.id = call_issue.call_id
	WHERE `call`.agent_id = _agent_id;
    
	SELECT id AS feedback_id, rating, comments, customer_id
    FROM feedback WHERE agent_id = _agent_id;
    
	SELECT staff.id AS staff_id, contact_info_id, supervisor_id, `name`,`number`,email, salary, hire_date
	FROM agent
	JOIN staff ON agent.staff_id = staff.id
	JOIN contact_info ON staff.contact_info_id = contact_info.id
	WHERE agent.id = _agent_id;
END;

CALL fetch_agent_related_data(1);

-- 7.2.6 increase_salary_for_agent

DROP PROCEDURE IF EXISTS increase_salary_for_agent;

CREATE PROCEDURE increase_salary_for_agent(IN agent_id INT, IN special_amount DECIMAL(7, 2))
BEGIN
  DECLARE _staff_id INT;
  DECLARE current_salary DECIMAL(7, 2);

  SELECT staff_id INTO _staff_id FROM agent WHERE id = agent_id;
  SELECT salary INTO current_salary FROM staff WHERE id = _staff_id;

  IF current_salary IS NOT NULL THEN
    UPDATE staff SET salary = current_salary + special_amount WHERE id = _staff_id;
    SELECT CONCAT('Salary increased by ', special_amount, ' for Agent ID ', agent_id) AS result;
  ELSE
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Agent not found.';
  END IF;
END;

CALL increase_salary_for_agent(2, 5000.00);

-- 7.2.7 get_agent_total_earnings

DROP PROCEDURE IF EXISTS get_agent_total_earnings;

CREATE PROCEDURE get_agent_total_earnings(IN _agent_id INT)
BEGIN
  DECLARE total_earnings DECIMAL(10, 2);

  SELECT s.salary + COALESCE(agent_earnings.total_service_price, 0) INTO total_earnings
  FROM staff s
  LEFT JOIN (
    SELECT a.staff_id, SUM(serv.price) AS total_service_price
    FROM agent a
    LEFT JOIN `call` c ON a.id = c.agent_id
    LEFT JOIN call_service cs ON c.id = cs.call_id
    LEFT JOIN service serv ON cs.service_id = serv.id
    WHERE a.staff_id = _agent_id
    GROUP BY a.staff_id
  ) agent_earnings ON s.id = agent_earnings.staff_id
  WHERE s.id = _agent_id;

  IF total_earnings IS NOT NULL THEN
    SELECT CONCAT('Total earnings for Agent ID ', _agent_id, ': $', total_earnings) AS result;
  ELSE
    SELECT CONCAT('No earnings available for Agent ID ', _agent_id) AS result;
  END IF;
END;

CALL get_agent_total_earnings(2);

-- 7.2.8 update_agent_supervisor

DROP PROCEDURE IF EXISTS update_agent_supervisor;

CREATE PROCEDURE update_agent_supervisor(IN agentId INT, IN newSupervisorId INT)
BEGIN
  IF EXISTS (SELECT 1 FROM agent WHERE id = agentId) AND EXISTS (SELECT 1 FROM supervisor WHERE id = newSupervisorId) THEN
    UPDATE agent SET supervisor_id = newSupervisorId WHERE id = agentId;
    SELECT CONCAT('Supervisor updated for Agent ID ', agentId, ' to ', newSupervisorid) AS Result;
  ELSE
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Agent or supervisor not found.';
  END IF;
END;

SELECT * FROM agent WHERE id = 3;

CALL update_agent_supervisor(3, 3);

-- 7.2.9 average_call_duration

DROP PROCEDURE IF EXISTS average_call_duration;

CREATE PROCEDURE average_call_duration()
BEGIN
  SELECT agent.id AS agent_id, AVG(TIMESTAMPDIFF(SECOND, `call`.start_at, `call`.end_at)) AS average_duration
  FROM agent
  JOIN `call` ON agent.id = `call`.agent_id
  GROUP BY agent.id
  ORDER BY average_duration;
END;

CALL average_call_duration();

-- 7.2.10 most_common_issues

DROP PROCEDURE IF EXISTS most_common_issues;

CREATE PROCEDURE most_common_issues()
BEGIN
  SELECT `issue`.`id`, `issue`.`description`, COUNT(`call_issue`.`call_id`) AS `call_count`
  FROM `issue`
  JOIN `call_issue` ON `issue`.`id` = `call_issue`.`issue_id`
  GROUP BY `issue`.`id`, `issue`.`description`
  ORDER BY `call_count` DESC;
END;

CALL most_common_issues();