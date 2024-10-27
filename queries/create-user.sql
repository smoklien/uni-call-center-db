USE `callcenter`;
SELECT user, host FROM mysql.user WHERE user IN ('callcenter_administrator', 'callcenter_agent', 'callcenter_supervisor', 'callcenter_customer');
SHOW GRANTS;

-- Creating user 'callcenter_administrator'
DROP USER IF EXISTS 'callcenter_administrator'@'localhost';

CREATE USER 'callcenter_administrator'@'localhost' IDENTIFIED BY '12345678';
GRANT ALL PRIVILEGES ON callcenter.* TO 'callcenter_administrator'@'localhost';

-- Creating user 'callcenter_agent'
DROP USER IF EXISTS 'callcenter_agent'@'localhost';

CREATE USER 'callcenter_agent'@'localhost' IDENTIFIED BY '12345678';
GRANT SELECT ON callcenter.feedback TO 'callcenter_agent'@'localhost';
GRANT SELECT ON callcenter.issue TO 'callcenter_agent'@'localhost';
GRANT SELECT ON callcenter.service TO 'callcenter_agent'@'localhost';
GRANT SELECT ON callcenter.customer TO 'callcenter_agent'@'localhost';
GRANT SELECT, INSERT ON callcenter.call_issue TO 'callcenter_agent'@'localhost';
GRANT SELECT, INSERT ON callcenter.call_service TO 'callcenter_agent'@'localhost';
GRANT SELECT, INSERT, UPDATE ON callcenter.`call` TO 'callcenter_agent'@'localhost';

-- Creating user 'callcenter_supervisor'
DROP USER IF EXISTS 'callcenter_supervisor'@'localhost';

CREATE USER 'callcenter_supervisor'@'localhost' IDENTIFIED BY '12345678';
GRANT SELECT ON callcenter.feedback TO 'callcenter_supervisor'@'localhost';
GRANT SELECT, INSERT, DELETE, UPDATE ON callcenter.issue TO 'callcenter_supervisor'@'localhost';
GRANT SELECT, INSERT, DELETE, UPDATE ON callcenter.service TO 'callcenter_supervisor'@'localhost';
GRANT SELECT, INSERT, DELETE, UPDATE ON callcenter.agent TO 'callcenter_supervisor'@'localhost';
GRANT SELECT, INSERT, DELETE, UPDATE ON callcenter.customer TO 'callcenter_supervisor'@'localhost';
GRANT SELECT, INSERT, DELETE, UPDATE ON callcenter.call_issue TO 'callcenter_supervisor'@'localhost';
GRANT SELECT, INSERT, DELETE, UPDATE ON callcenter.call_service TO 'callcenter_supervisor'@'localhost';
GRANT SELECT, INSERT, DELETE, UPDATE ON callcenter.`call` TO 'callcenter_supervisor'@'localhost';

-- Creating user 'callcenter_customer'
DROP USER IF EXISTS 'callcenter_customer'@'localhost';

CREATE USER 'callcenter_customer'@'localhost' IDENTIFIED BY '12345678';
GRANT SELECT, INSERT ON callcenter.feedback TO 'callcenter_customer'@'localhost';