CREATE DATABASE IF NOT EXISTS disney_plus;
USE disney_plus;

-- ACCOUNT
CREATE TABLE account
( account_id     INT NOT NULL,
  email          TEXT NOT NULL,
  password_hash  TEXT NOT NULL,
  creation_date  DATE NOT NULL,
  billing_info   TEXT NOT NULL,
  CONSTRAINT account_pk PRIMARY KEY (account_id)
);

-- CONTENT
CREATE TABLE content
( content_id     INT NOT NULL,
  release_year   INT NOT NULL,
  rating         INT,
  primary_genre  VARCHAR(30) NOT NULL,
  language       VARCHAR(30) NOT NULL,
  CONSTRAINT content_pk PRIMARY KEY (content_id)
);

-- SUBSCRIPTION PLAN
CREATE TABLE subscription_plan
( plan_id       INT NOT NULL,
  plan_name     VARCHAR(15) NOT NULL,
  price         INT NOT NULL,
  max_profiles  INT NOT NULL,
  max_devices   INT NOT NULL,
  resolution    TEXT NOT NULL,
  CONSTRAINT subscription_plan_pk PRIMARY KEY (plan_id)
);

-- ADVERTISER
CREATE TABLE advertiser
( advertiser_id INT NOT NULL,
  name          VARCHAR(30) NOT NULL,
  industry      VARCHAR(30) NOT NULL,
  CONSTRAINT advertiser_pk PRIMARY KEY (advertiser_id)
);

-- CONTENT_LANGUAGE (multi-valued)
CREATE TABLE content_language
( content_id INT NOT NULL,
  language   VARCHAR(30) NOT NULL,
  CONSTRAINT content_language_pk PRIMARY KEY (content_id, language),
  CONSTRAINT content_language_fk FOREIGN KEY (content_id)
    REFERENCES content(content_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- MOVIE (child of content)
CREATE TABLE movie
( movie_title VARCHAR(30) NOT NULL,
  content_id  INT NOT NULL,
  CONSTRAINT movie_pk PRIMARY KEY (content_id, movie_title),
  CONSTRAINT movie_fk FOREIGN KEY (content_id)
    REFERENCES content(content_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- EPISODE (child of content)
CREATE TABLE episode
( series_title VARCHAR(30) NOT NULL,
  content_id   INT NOT NULL,
  season_no    INT NOT NULL,
  episode_no   INT NOT NULL,
  CONSTRAINT episode_pk PRIMARY KEY (content_id, series_title, season_no, episode_no),
  CONSTRAINT episode_fk FOREIGN KEY (content_id)
    REFERENCES content(content_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- PROFILES (composite key)
CREATE TABLE profiles
( account_id           INT NOT NULL,
  profile_no           INT NOT NULL,
  profile_type         TEXT NOT NULL,
  max_maturity_rating  VARCHAR(20) NOT NULL,
  language             VARCHAR(10) NOT NULL,
  CONSTRAINT profiles_pk PRIMARY KEY (profile_no, account_id),
  CONSTRAINT profiles_fk FOREIGN KEY (account_id)
    REFERENCES account(account_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- DEVICE (composite key)
CREATE TABLE device
( device_id       INT NOT NULL,
  account_id      INT NOT NULL,
  device_type     VARCHAR(20) NOT NULL,
  registered_date DATE NOT NULL,
  last_active     DATE NOT NULL,
  CONSTRAINT device_pk PRIMARY KEY (device_id, account_id),
  CONSTRAINT device_fk FOREIGN KEY (account_id)
    REFERENCES account(account_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- SUBSCRIPTION CONTRACT
CREATE TABLE subscription_contract
( contract_id    INT NOT NULL,
  account_id     INT NOT NULL,
  plan_id        INT NOT NULL,
  start_date     DATE NOT NULL,
  end_date       DATE NULL,
  billing_cycle  INT NOT NULL,
  status         TEXT NOT NULL,
  reason_code    TEXT NOT NULL,
  CONSTRAINT subscription_contract_pk PRIMARY KEY (contract_id, account_id),
  CONSTRAINT subscription_contract_fk1 FOREIGN KEY (account_id)
    REFERENCES account(account_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT subscription_contract_fk2 FOREIGN KEY (plan_id)
    REFERENCES subscription_plan(plan_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

-- AD CAMPAIGN
CREATE TABLE ad_campaign
( campaign_id     INT NOT NULL,
  advertiser_id   INT NOT NULL,
  campaign_name   VARCHAR(30) NOT NULL,
  start_date      TIMESTAMP NOT NULL,
  end_date        TIMESTAMP NULL,
  targeting_notes TEXT NOT NULL,
  CONSTRAINT ad_campaign_pk PRIMARY KEY (campaign_id),
  CONSTRAINT ad_campaign_fk FOREIGN KEY (advertiser_id)
    REFERENCES advertiser(advertiser_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- AD IMPRESSION
CREATE TABLE ad_impression
( impression_id   INT NOT NULL,
  campaign_id     INT NOT NULL,
  impression_time TIMESTAMP NOT NULL,
  shown_at        TIMESTAMP NOT NULL,
  skipped_flag    BOOLEAN NOT NULL DEFAULT FALSE,
  CONSTRAINT ad_impression_pk PRIMARY KEY (impression_id),
  CONSTRAINT ad_impression_fk FOREIGN KEY (campaign_id)
    REFERENCES ad_campaign(campaign_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- PLAYBACK EVENT
CREATE TABLE playback_event
( playback_event_id INT NOT NULL,
  account_id        INT NOT NULL,   -- to reference composite keys
  profile_no        INT NOT NULL,
  device_id         INT NOT NULL,
  content_id        INT NOT NULL,
  impression_id     INT NULL,
  start_time        TIMESTAMP NOT NULL,
  end_time          TIMESTAMP NOT NULL,
  CONSTRAINT playback_event_pk PRIMARY KEY (playback_event_id),
  CONSTRAINT playback_event_fk1 FOREIGN KEY (profile_no, account_id)
    REFERENCES profiles(profile_no, account_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT playback_event_fk2 FOREIGN KEY (device_id, account_id)
    REFERENCES device(device_id, account_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT playback_event_fk3 FOREIGN KEY (content_id)
    REFERENCES content(content_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT playback_event_fk4 FOREIGN KEY (impression_id)
    REFERENCES ad_impression(impression_id)
    ON DELETE SET NULL ON UPDATE CASCADE
);

INSERT INTO account (account_id, email, password_hash, creation_date, billing_info) VALUES
(1001,'lena.mae12@gmail.com','Ab3dE7fG9hJ2kL5mN8p','2023-02-14','Visa **** 1842, exp 11/28, SG'),
(1002,'akash.t@outlook.com','Q1wE2rT3yU4iO5pA6sD','2024-07-03','Mastercard **** 5521, exp 05/27, SG'),
(1003,'sylvia.ng@proton.me','Z9xC8vB7nM6lK5jH4gF','2022-11-29','AMEX **** 0314, exp 09/26, SG'),
(1004,'marco.russo@gmail.com','tY7uI6oP5aS4dF3gH2jK','2025-04-18','Visa **** 9027, exp 02/29, SG'),
(1005,'hana.kim91@yahoo.com','mN8bV7cX6zA5sD4fG3hJ','2021-06-07','Mastercard **** 6670, exp 08/27, SG'),
(1006,'peter.owens@icloud.com','rT5yG6hJ7kL8mN9bV0cX','2023-09-25','Visa **** 4412, exp 12/28, SG'),
(1007,'nurul.huda@live.com','pO9iU8yT7rE6wQ5eR4tY','2024-01-09','AMEX **** 1188, exp 03/27, SG'),
(1008,'joao.sousa@hotmail.com','cV3bN4mM5lK6jJ7hH8gF','2022-03-31','Mastercard **** 3205, exp 01/28, SG'),
(1009,'zara.ahmad@zoho.com','aS1dF2gH3jK4lL5mM6nB','2025-08-02','Visa **** 7054, exp 10/29, SG'),
(1010,'quentin.lee@mail.com','xC2vB3nN4mM5kK6jJ7hG','2020-12-12','Debit **** 9421, exp 06/27, SG');

select * from account;

INSERT INTO advertiser (advertiser_id, name, industry) VALUES
(2001, 'Coca-Cola', 'Food and Beverage'),
(2002, 'Toyota', 'Automotive'),
(2003, 'Samsung', 'Electronics'),
(2004, 'Apple', 'Electronics'),
(2005, 'Nike', 'Apparel'),
(2006, 'McDonald''s', 'Restaurants'),
(2007, 'Amazon', 'E-commerce'),
(2008, 'Unilever', 'Consumer Goods'),
(2009, 'HSBC', 'Financial Services'),
(2010, 'Vodafone', 'Telecommunications');

select * from advertiser;

INSERT INTO content (content_id, release_year, rating, primary_genre, language) VALUES
-- Movies
(3101, 2020, 9, 'Animation', 'English'),   -- Soul
(3102, 2021, 8, 'Animation', 'English'),   -- Luca
(3103, 2022, 8, 'Animation', 'English'),   -- Turning Red
(3104, 2019, 8, 'Adventure', 'English'),   -- Togo
(3105, 2019, 7, 'Comedy',    'English');   -- Noelle

INSERT INTO content (content_id, release_year, rating, primary_genre, language) VALUES
(3106, 2019, 9, 'Sci-Fi',  'English'),  -- The Mandalorian
(3107, 2021, 9, 'Fantasy', 'English'),  -- Loki
(3108, 2021, 8, 'Action',  'English'),  -- Hawkeye
(3109, 2022, 9, 'Sci-Fi',  'English'),  -- Andor
(3110, 2023, 8, 'Sci-Fi',  'English');  -- Ahsoka

INSERT INTO movie (movie_title, content_id) VALUES
('Soul',        3101),
('Luca',        3102),
('Turning Red', 3103),
('Togo',        3104),
('Noelle',      3105);

-- Episodes (sample: first 3 eps of Season 1 for each series)
INSERT INTO episode (series_title, content_id, season_no, episode_no) VALUES
-- The Mandalorian (S1 E1–E3)
('The Mandalorian', 3106, 1, 1),
('The Mandalorian', 3106, 1, 2),
('The Mandalorian', 3106, 1, 3),

-- Loki (S1 E1–E3)
('Loki', 3107, 1, 1),
('Loki', 3107, 1, 2),
('Loki', 3107, 1, 3),

-- Hawkeye (S1 E1–E3)
('Hawkeye', 3108, 1, 1),
('Hawkeye', 3108, 1, 2),
('Hawkeye', 3108, 1, 3),

-- Andor (S1 E1–E3)
('Andor', 3109, 1, 1),
('Andor', 3109, 1, 2),
('Andor', 3109, 1, 3),

-- Ahsoka (S1 E1–E3)
('Ahsoka', 3110, 1, 1),
('Ahsoka', 3110, 1, 2),
('Ahsoka', 3110, 1, 3);

select * from episode;

select * from movie;

INSERT INTO profiles (account_id, profile_no, profile_type, max_maturity_rating, language) VALUES
-- 1001
(1001, 1, 'Standard', 'PG13', 'en'),
(1001, 2, 'Kids',     'G',    'en'),
(1001, 3, 'Teen',     'NC16', 'ms'),

-- 1002
(1002, 1, 'Standard', 'PG13', 'en'),
(1002, 2, 'Kids',     'PG',   'en'),
(1002, 3, 'Teen',     'NC16', 'ta'),

-- 1003
(1003, 1, 'Standard', 'M18',  'en'),
(1003, 2, 'Kids',     'G',    'en'),
(1003, 3, 'Teen',     'NC16', 'zh'),

-- 1004
(1004, 1, 'Standard', 'R21',  'en'),
(1004, 2, 'Kids',     'PG',   'en'),
(1004, 3, 'Teen',     'NC16', 'it'),

-- 1005
(1005, 1, 'Standard', 'PG13', 'en'),
(1005, 2, 'Kids',     'G',    'en'),
(1005, 3, 'Teen',     'NC16', 'id'),

-- 1006
(1006, 1, 'Standard', 'PG13', 'en'),
(1006, 2, 'Kids',     'G',    'en'),
(1006, 3, 'Teen',     'M18',  'fr'),

-- 1007
(1007, 1, 'Standard', 'PG13', 'en'),
(1007, 2, 'Kids',     'PG',   'en'),
(1007, 3, 'Teen',     'NC16', 'ms'),

-- 1008
(1008, 1, 'Standard', 'PG',   'en'),
(1008, 2, 'Kids',     'G',    'en'),
(1008, 3, 'Teen',     'NC16', 'pt'),

-- 1009
(1009, 1, 'Standard', 'PG13', 'en'),
(1009, 2, 'Kids',     'G',    'en'),
(1009, 3, 'Teen',     'M18',  'es'),

-- 1010
(1010, 1, 'Standard', 'PG13', 'en'),
(1010, 2, 'Kids',     'PG',   'en'),
(1010, 3, 'Teen',     'NC16', 'zh');

select * from profiles;

INSERT INTO device (device_id, account_id, device_type, registered_date, last_active) VALUES
-- 1001
(5101, 1001, 'iPhone',        '2023-11-12', '2025-10-30'),
(5102, 1001, 'Laptop',        '2024-02-03', '2025-10-28'),
(5103, 1001, 'Smart TV',      '2024-05-21', '2025-10-29'),
(5104, 1001, 'iPad',          '2024-08-15', '2025-10-31'),

-- 1002
(5105, 1002, 'Android Phone', '2023-10-09', '2025-10-27'),
(5106, 1002, 'Laptop',        '2024-07-04', '2025-10-31'),
(5107, 1002, 'Chromecast',    '2024-09-12', '2025-10-25'),
(5108, 1002, 'Smart TV',      '2024-11-19', '2025-10-30'),

-- 1003
(5109, 1003, 'iPad',          '2022-12-01', '2025-10-15'),
(5110, 1003, 'Apple TV',      '2023-06-18', '2025-10-29'),
(5111, 1003, 'Laptop',        '2024-03-02', '2025-10-21'),
(5112, 1003, 'Android Phone', '2024-10-10', '2025-10-20'),

-- 1004
(5113, 1004, 'Smart TV',      '2025-04-18', '2025-10-30'),
(5114, 1004, 'PS5',           '2025-05-02', '2025-10-29'),
(5115, 1004, 'iPhone',        '2025-06-14', '2025-10-22'),
(5116, 1004, 'Laptop',        '2025-08-01', '2025-10-25'),

-- 1005
(5117, 1005, 'Android Phone', '2021-08-15', '2025-09-23'),
(5118, 1005, 'Tablet',        '2023-02-09', '2025-10-11'),
(5119, 1005, 'Smart TV',      '2024-04-20', '2025-10-01'),
(5120, 1005, 'Laptop',        '2024-09-05', '2025-10-26'),

-- 1006
(5121, 1006, 'Laptop',        '2023-10-01', '2025-10-26'),
(5122, 1006, 'Chromecast',    '2024-02-14', '2025-10-12'),
(5123, 1006, 'iPad',          '2024-06-30', '2025-10-28'),
(5124, 1006, 'Smart TV',      '2024-11-07', '2025-10-24'),

-- 1007
(5125, 1007, 'iPhone',        '2024-01-09', '2025-10-18'),
(5126, 1007, 'Smart TV',      '2024-03-01', '2025-10-19'),
(5127, 1007, 'Laptop',        '2024-07-22', '2025-10-30'),
(5128, 1007, 'Apple TV',      '2024-09-10', '2025-10-21'),

-- 1008
(5129, 1008, 'Android Phone', '2022-03-31', '2025-10-05'),
(5130, 1008, 'Xbox',          '2023-05-20', '2025-10-29'),
(5131, 1008, 'Smart TV',      '2024-01-18', '2025-10-14'),
(5132, 1008, 'Laptop',        '2024-08-27', '2025-10-30'),

-- 1009
(5133, 1009, 'iPad',          '2023-04-12', '2025-10-01'),
(5134, 1009, 'Apple TV',      '2024-01-21', '2025-10-27'),
(5135, 1009, 'Android Phone', '2024-06-03', '2025-10-28'),
(5136, 1009, 'Smart TV',      '2024-10-15', '2025-10-30'),

-- 1010
(5137, 1010, 'Laptop',        '2020-12-12', '2025-09-14'),
(5138, 1010, 'Smart TV',      '2022-06-30', '2025-10-10'),
(5139, 1010, 'iPhone',        '2024-02-01', '2025-10-26'),
(5140, 1010, 'Chromecast',    '2024-09-09', '2025-10-25');

select * from device;

-- 1) Backfill each title’s original language from content.language
INSERT IGNORE INTO content_language (content_id, language)
SELECT content_id, language FROM content
WHERE content_id BETWEEN 3101 AND 3110;

-- 2) Add additional languages per title (adjust as you like)

-- Movies
INSERT IGNORE INTO content_language (content_id, language) VALUES
(3101,'Spanish'),(3101,'French'),(3101,'Japanese'),   -- Soul
(3102,'Spanish'),(3102,'Italian'),(3102,'German'),    -- Luca
(3103,'Spanish'),(3103,'Korean'),(3103,'French'),     -- Turning Red
(3104,'French'), (3104,'German'), (3104,'Spanish'),   -- Togo
(3105,'Spanish'),(3105,'Malay'), (3105,'French');     -- Noelle

-- Series
INSERT IGNORE INTO content_language (content_id, language) VALUES
(3106,'Spanish'),(3106,'French'),(3106,'German'),(3106,'Japanese'),   -- The Mandalorian
(3107,'Spanish'),(3107,'French'),(3107,'Italian'),                   -- Loki
(3108,'Spanish'),(3108,'Italian'),(3108,'French'),                    -- Hawkeye
(3109,'Spanish'),(3109,'French'),(3109,'Portuguese'),(3109,'German'), -- Andor
(3110,'Spanish'),(3110,'Japanese'),(3110,'French');                   -- Ahsoka

select * from content_language;

INSERT INTO subscription_plan (plan_id, plan_name, price, max_profiles, max_devices, resolution) VALUES
(4001, 'Basic (Ads)',      9, 7, 2, 'HD 720p'),
(4002, 'Standard (Ads)',  13, 7, 4, 'Full HD 1080p'),
(4003, 'Standard',        16, 7, 4, 'Full HD 1080p'),
(4004, 'Premium',         24, 7, 4, '4K UHD + HDR'),
(4005, 'Annual Premium', 240, 7, 4, '4K UHD + HDR');

select * from subscription_plan;

INSERT INTO subscription_contract 
(contract_id, account_id, plan_id, start_date, end_date, billing_cycle, status, reason_code) VALUES
(6001, 1001, 4004, '2024-01-15', NULL, 1,  'active',   'NONE'),  -- Premium 4K
(6002, 1002, 4002, '2024-07-04', NULL, 1,  'active',   'NONE'),  -- Standard (Ads)
(6003, 1003, 4003, '2023-12-10', NULL, 1,  'active',   'NONE'),  -- Standard
(6004, 1004, 4004, '2025-04-18', NULL, 1,  'active',   'NONE'),  -- Premium 4K
(6005, 1005, 4001, '2023-02-09', '2024-04-30', 1, 'cancelled','user_cancelled'),
(6006, 1006, 4003, '2023-10-01', NULL, 1,  'active',   'NONE'),
(6007, 1007, 4002, '2024-01-09', NULL, 1,  'active',   'NONE'),
(6008, 1008, 4005, '2024-11-01', NULL, 12, 'active',   'NONE'),  -- Annual Premium
(6009, 1009, 4003, '2024-01-21', NULL, 1,  'active',   'NONE'),
(6010, 1010, 4002, '2022-07-01', '2024-06-30', 1, 'expired', 'term_ended');

select * from subscription_contract;

-- AD CAMPAIGNS
INSERT INTO ad_campaign
(campaign_id, advertiser_id, campaign_name, start_date, end_date, targeting_notes) VALUES
(7001, 2001, 'Coke Holiday 2025',     '2025-10-15 09:00:00', '2025-12-31 23:59:59', 'SG, 18-44, festive, OTT/TV'),
(7002, 2002, 'Toyota Hybrid Push',    '2025-06-01 00:00:00', '2025-11-30 23:59:59', 'SG, eco-friendly, in-market auto'),
(7003, 2003, 'Galaxy Fold Launch',    '2025-08-10 08:00:00', '2025-10-10 23:59:59', 'Tech enthusiasts, HHI 80k+, APAC'),
(7004, 2004, 'Apple TV+ Bundle',      '2025-09-01 00:00:00', NULL,                  'iOS users, streaming upsell'),
(7005, 2005, 'Run SG Marathon',       '2025-07-20 06:00:00', '2025-12-10 23:59:59', 'Runners, fitness interest, SG'),
(7006, 2006, 'McSpicy Comeback',      '2025-05-01 00:00:00', '2025-09-30 23:59:59', 'QSR intenders, lunch/dinner peaks'),
(7007, 2007, 'Prime Day 2025',        '2025-07-05 00:00:00', '2025-07-20 23:59:59', 'Deal seekers, cart abandoners'),
(7008, 2008, 'Sunsilk Summer',        '2025-03-01 00:00:00', '2025-06-30 23:59:59', 'Beauty/haircare, hot weather'),
(7009, 2009, 'HSBC Cashback',         '2025-01-15 00:00:00', '2025-12-31 23:59:59', 'Credit card switchers, SG'),
(7010, 2010, '5G Everywhere',         '2025-04-01 00:00:00', NULL,                  'Urban, heavy data users');

-- AD IMPRESSIONS (3 per campaign)
INSERT INTO ad_impression
(impression_id, campaign_id, impression_time, shown_at, skipped_flag) VALUES
-- 7001 Coca-Cola (within 2025-10-15 to 2025-12-31)
(9001, 7001, '2025-10-20 18:31:04', '2025-10-20 18:31:10', FALSE),
(9002, 7001, '2025-11-05 12:05:22', '2025-11-05 12:05:28', FALSE),
(9003, 7001, '2025-12-01 21:15:00', '2025-12-01 21:15:06', TRUE),

-- 7002 Toyota (within 2025-06-01 to 2025-11-30)
(9004, 7002, '2025-06-12 09:10:00', '2025-06-12 09:10:07', FALSE),
(9005, 7002, '2025-09-03 20:45:30', '2025-09-03 20:45:37', FALSE),
(9006, 7002, '2025-11-18 13:22:11', '2025-11-18 13:22:18', TRUE),

-- 7003 Samsung (within 2025-08-10 to 2025-10-10)
(9007, 7003, '2025-08-15 10:00:00', '2025-08-15 10:00:06', FALSE),
(9008, 7003, '2025-09-07 16:12:49', '2025-09-07 16:12:55', FALSE),
(9009, 7003, '2025-10-09 22:40:10', '2025-10-09 22:40:16', TRUE),

-- 7004 Apple (ongoing since 2025-09-01)
(9010, 7004, '2025-09-21 11:30:02', '2025-09-21 11:30:08', FALSE),
(9011, 7004, '2025-10-14 08:05:45', '2025-10-14 08:05:51', FALSE),
(9012, 7004, '2025-11-02 19:59:59', '2025-11-02 20:00:05', TRUE),

-- 7005 Nike (within 2025-07-20 to 2025-12-10)
(9013, 7005, '2025-07-28 06:45:00', '2025-07-28 06:45:06', FALSE),
(9014, 7005, '2025-09-19 18:22:22', '2025-09-19 18:22:28', FALSE),
(9015, 7005, '2025-11-30 07:10:12', '2025-11-30 07:10:18', TRUE),

-- 7006 McDonald’s (within 2025-05-01 to 2025-09-30)
(9016, 7006, '2025-05-11 12:12:12', '2025-05-11 12:12:18', FALSE),
(9017, 7006, '2025-08-03 19:00:00', '2025-08-03 19:00:06', FALSE),
(9018, 7006, '2025-09-29 22:33:40', '2025-09-29 22:33:46', TRUE),

-- 7007 Amazon (within 2025-07-05 to 2025-07-20)
(9019, 7007, '2025-07-06 10:05:00', '2025-07-06 10:05:06', FALSE),
(9020, 7007, '2025-07-12 15:45:35', '2025-07-12 15:45:41', FALSE),
(9021, 7007, '2025-07-19 23:58:00', '2025-07-19 23:58:06', TRUE),

-- 7008 Unilever (within 2025-03-01 to 2025-06-30)
(9022, 7008, '2025-03-21 14:40:10', '2025-03-21 14:40:16', FALSE),
(9023, 7008, '2025-05-02 09:30:00', '2025-05-02 09:30:06', FALSE),
(9024, 7008, '2025-06-28 20:20:20', '2025-06-28 20:20:26', TRUE),

-- 7009 HSBC (within 2025-01-15 to 2025-12-31)
(9025, 7009, '2025-02-08 08:10:00', '2025-02-08 08:10:06', FALSE),
(9026, 7009, '2025-06-18 13:05:33', '2025-06-18 13:05:39', FALSE),
(9027, 7009, '2025-10-22 21:47:11', '2025-10-22 21:47:17', TRUE),

-- 7010 Vodafone (ongoing since 2025-04-01)
(9028, 7010, '2025-04-15 12:00:00', '2025-04-15 12:00:06', FALSE),
(9029, 7010, '2025-08-09 17:22:33', '2025-08-09 17:22:39', FALSE),
(9030, 7010, '2025-10-31 23:59:50', '2025-11-01 00:00:00', TRUE);

INSERT INTO playback_event
(playback_event_id, account_id, profile_no, device_id, content_id, impression_id, start_time, end_time) VALUES
-- ===== Account 1001 (devices 5101–5104; profiles 1–3) =====
(8101, 1001, 1, 5101, 3101, 9001, '2025-10-20 18:45:00', '2025-10-20 20:20:00'),
(8102, 1001, 2, 5103, 3102, NULL,  '2025-10-29 17:10:00', '2025-10-29 18:30:00'),
(8103, 1001, 3, 5102, 3106, 9011, '2025-10-14 20:12:00', '2025-10-14 21:05:00'),
(8104, 1001, 1, 5104, 3103, NULL,  '2025-11-02 19:05:00', '2025-11-02 20:35:00'),
(8105, 1001, 2, 5101, 3107, 9010, '2025-09-21 11:40:00', '2025-09-21 12:25:00'),
(8106, 1001, 3, 5102, 3104, NULL,  '2025-10-05 10:00:00', '2025-10-05 11:42:00'),
(8107, 1001, 1, 5103, 3108, 9020, '2025-07-12 15:52:00', '2025-07-12 16:40:00'),
(8108, 1001, 2, 5104, 3109, 9027, '2025-10-22 21:50:00', '2025-10-22 22:46:00'),
(8109, 1001, 3, 5101, 3110, 9030, '2025-10-31 23:59:56', '2025-11-01 00:50:00'),
(8110, 1001, 1, 5102, 3105, NULL,  '2025-11-30 07:20:00', '2025-11-30 08:48:00'),

-- ===== Account 1002 (devices 5105–5108) =====
(8111, 1002, 1, 5106, 3106, 9005, '2025-09-03 21:00:00', '2025-09-03 21:45:00'),
(8112, 1002, 3, 5105, 3104, NULL,  '2025-10-25 12:00:00', '2025-10-25 13:45:00'),
(8113, 1002, 2, 5107, 3102, NULL,  '2025-10-10 18:05:00', '2025-10-10 19:25:00'),
(8114, 1002, 1, 5108, 3107, 9012, '2025-11-02 20:10:00', '2025-11-02 21:00:00'),
(8115, 1002, 2, 5106, 3101, NULL,  '2025-10-01 19:10:00', '2025-10-01 20:40:00'),
(8116, 1002, 3, 5105, 3108, 9004, '2025-06-12 09:15:00', '2025-06-12 10:00:00'),
(8117, 1002, 1, 5107, 3109, 9006, '2025-11-18 13:25:00', '2025-11-18 14:12:00'),
(8118, 1002, 2, 5108, 3110, NULL,  '2025-10-30 21:00:00', '2025-10-30 21:55:00'),
(8119, 1002, 3, 5106, 3103, NULL,  '2025-10-26 20:00:00', '2025-10-26 21:35:00'),
(8120, 1002, 1, 5105, 3105, 9015, '2025-11-30 07:22:00', '2025-11-30 08:45:00'),

-- ===== Account 1003 (devices 5109–5112) =====
(8121, 1003, 1, 5110, 3107, 9008, '2025-09-07 20:05:00', '2025-09-07 20:55:00'),
(8122, 1003, 2, 5109, 3103, NULL,  '2025-10-14 15:30:00', '2025-10-14 16:55:00'),
(8123, 1003, 3, 5111, 3106, NULL,  '2025-10-28 22:00:00', '2025-10-28 22:48:00'),
(8124, 1003, 1, 5112, 3102, NULL,  '2025-11-01 14:00:00', '2025-11-01 15:20:00'),
(8125, 1003, 2, 5110, 3108, 9007, '2025-08-15 10:10:00', '2025-08-15 10:58:00'),
(8126, 1003, 3, 5109, 3109, 9009, '2025-10-09 22:45:00', '2025-10-09 23:30:00'),
(8127, 1003, 1, 5111, 3110, NULL,  '2025-11-03 19:30:00', '2025-11-03 20:25:00'),
(8128, 1003, 2, 5112, 3101, NULL,  '2025-10-02 18:40:00', '2025-10-02 20:20:00'),
(8129, 1003, 3, 5109, 3105, NULL,  '2025-11-10 09:10:00', '2025-11-10 10:40:00'),
(8130, 1003, 1, 5110, 3104, NULL,  '2025-10-05 11:00:00', '2025-10-05 12:44:00'),

-- ===== Account 1004 (devices 5113–5116) =====
(8131, 1004, 1, 5113, 3106, 9011, '2025-10-14 20:12:00', '2025-10-14 21:02:00'),
(8132, 1004, 3, 5116, 3110, 9012, '2025-11-02 20:12:00', '2025-11-02 21:06:00'),
(8133, 1004, 2, 5114, 3101, NULL,  '2025-10-03 19:00:00', '2025-10-03 20:35:00'),
(8134, 1004, 1, 5115, 3107, 9010, '2025-09-21 11:45:00', '2025-09-21 12:30:00'),
(8135, 1004, 2, 5116, 3108, NULL,  '2025-10-29 21:00:00', '2025-10-29 21:48:00'),
(8136, 1004, 3, 5114, 3109, NULL,  '2025-11-05 20:10:00', '2025-11-05 21:00:00'),
(8137, 1004, 1, 5113, 3102, NULL,  '2025-10-20 08:30:00', '2025-10-20 09:50:00'),
(8138, 1004, 2, 5115, 3103, NULL,  '2025-10-22 17:20:00', '2025-10-22 18:55:00'),
(8139, 1004, 3, 5116, 3104, NULL,  '2025-10-25 12:10:00', '2025-10-25 13:50:00'),
(8140, 1004, 1, 5113, 3105, NULL,  '2025-11-30 07:25:00', '2025-11-30 08:52:00'),

-- ===== Account 1005 (devices 5117–5120) =====
(8141, 1005, 1, 5119, 3105, 9015, '2025-11-30 07:20:00', '2025-11-30 08:50:00'),
(8142, 1005, 2, 5118, 3101, NULL,  '2025-10-01 19:05:00', '2025-10-01 20:38:00'),
(8143, 1005, 3, 5117, 3106, NULL,  '2025-10-12 21:00:00', '2025-10-12 21:50:00'),
(8144, 1005, 1, 5120, 3102, NULL,  '2025-10-18 16:10:00', '2025-10-18 17:28:00'),
(8145, 1005, 2, 5119, 3107, NULL,  '2025-10-21 20:05:00', '2025-10-21 20:58:00'),
(8146, 1005, 3, 5118, 3108, NULL,  '2025-10-24 14:30:00', '2025-10-24 15:20:00'),
(8147, 1005, 1, 5117, 3109, 9014, '2025-09-19 18:25:00', '2025-09-19 19:15:00'),
(8148, 1005, 2, 5120, 3110, NULL,  '2025-10-31 22:00:00', '2025-10-31 22:55:00'),
(8149, 1005, 3, 5119, 3103, NULL,  '2025-10-27 19:40:00', '2025-10-27 21:10:00'),
(8150, 1005, 1, 5117, 3104, NULL,  '2025-10-05 09:50:00', '2025-10-05 11:35:00'),

-- ===== Account 1006 (devices 5121–5124) =====
(8151, 1006, 1, 5121, 3109, 9026, '2025-06-18 13:15:00', '2025-06-18 14:10:00'),
(8152, 1006, 3, 5123, 3108, NULL,  '2025-10-26 21:00:00', '2025-10-26 21:50:00'),
(8153, 1006, 2, 5122, 3106, 9017, '2025-08-03 19:02:00', '2025-08-03 19:50:00'),
(8154, 1006, 1, 5124, 3107, NULL,  '2025-10-02 20:30:00', '2025-10-02 21:20:00'),
(8155, 1006, 2, 5123, 3110, NULL,  '2025-10-29 22:05:00', '2025-10-29 22:58:00'),
(8156, 1006, 3, 5121, 3101, NULL,  '2025-10-11 18:00:00', '2025-10-11 19:38:00'),
(8157, 1006, 1, 5122, 3102, NULL,  '2025-10-15 12:00:00', '2025-10-15 13:20:00'),
(8158, 1006, 2, 5124, 3103, NULL,  '2025-10-20 21:10:00', '2025-10-20 22:45:00'),
(8159, 1006, 3, 5121, 3104, NULL,  '2025-10-23 09:00:00', '2025-10-23 10:40:00'),
(8160, 1006, 1, 5123, 3105, NULL,  '2025-11-02 08:05:00', '2025-11-02 09:30:00'),

-- ===== Account 1007 (devices 5125–5128) =====
(8161, 1007, 1, 5127, 3107, 9010, '2025-09-21 11:35:00', '2025-09-21 12:30:00'),
(8162, 1007, 2, 5126, 3102, NULL,  '2025-10-19 16:00:00', '2025-10-19 17:20:00'),
(8163, 1007, 3, 5125, 3106, NULL,  '2025-10-22 20:00:00', '2025-10-22 20:48:00'),
(8164, 1007, 1, 5128, 3108, NULL,  '2025-10-28 21:05:00', '2025-10-28 21:55:00'),
(8165, 1007, 2, 5127, 3109, NULL,  '2025-10-31 19:30:00', '2025-10-31 20:25:00'),
(8166, 1007, 3, 5126, 3110, 9011, '2025-10-14 20:15:00', '2025-10-14 21:02:00'),
(8167, 1007, 1, 5125, 3101, NULL,  '2025-10-03 18:40:00', '2025-10-03 20:18:00'),
(8168, 1007, 2, 5128, 3103, NULL,  '2025-10-09 13:00:00', '2025-10-09 14:35:00'),
(8169, 1007, 3, 5127, 3104, NULL,  '2025-10-12 09:20:00', '2025-10-12 11:05:00'),
(8170, 1007, 1, 5126, 3105, NULL,  '2025-11-02 07:55:00', '2025-11-02 09:20:00'),

-- ===== Account 1008 (devices 5129–5132) =====
(8171, 1008, 1, 5130, 3108, 9020, '2025-07-12 15:50:00', '2025-07-12 16:40:00'),
(8172, 1008, 3, 5132, 3103, NULL,  '2025-10-30 20:00:00', '2025-10-30 21:35:00'),
(8173, 1008, 2, 5129, 3106, NULL,  '2025-10-26 19:00:00', '2025-10-26 19:50:00'),
(8174, 1008, 1, 5131, 3102, NULL,  '2025-10-06 12:30:00', '2025-10-06 13:52:00'),
(8175, 1008, 2, 5132, 3107, NULL,  '2025-10-08 21:10:00', '2025-10-08 22:02:00'),
(8176, 1008, 3, 5130, 3109, 9021, '2025-07-19 23:58:30', '2025-07-20 00:48:00'),
(8177, 1008, 1, 5129, 3110, NULL,  '2025-10-31 21:00:00', '2025-10-31 21:55:00'),
(8178, 1008, 2, 5131, 3101, NULL,  '2025-10-02 17:05:00', '2025-10-02 18:40:00'),
(8179, 1008, 3, 5129, 3104, NULL,  '2025-10-05 08:55:00', '2025-10-05 10:35:00'),
(8180, 1008, 1, 5132, 3105, NULL,  '2025-11-01 09:05:00', '2025-11-01 10:28:00'),

-- ===== Account 1009 (devices 5133–5136) =====
(8181, 1009, 1, 5134, 3109, 9027, '2025-10-22 21:50:00', '2025-10-22 22:45:00'),
(8182, 1009, 2, 5135, 3104, NULL,  '2025-10-05 10:00:00', '2025-10-05 11:40:00'),
(8183, 1009, 3, 5133, 3106, NULL,  '2025-10-11 21:05:00', '2025-10-11 21:55:00'),
(8184, 1009, 1, 5136, 3107, NULL,  '2025-10-17 20:12:00', '2025-10-17 21:05:00'),
(8185, 1009, 2, 5135, 3108, NULL,  '2025-10-20 19:00:00', '2025-10-20 19:50:00'),
(8186, 1009, 3, 5134, 3110, NULL,  '2025-10-24 13:05:00', '2025-10-24 14:00:00'),
(8187, 1009, 1, 5133, 3101, NULL,  '2025-10-28 18:20:00', '2025-10-28 19:58:00'),
(8188, 1009, 2, 5136, 3102, NULL,  '2025-10-30 09:10:00', '2025-10-30 10:30:00'),
(8189, 1009, 3, 5135, 3103, NULL,  '2025-11-03 21:00:00', '2025-11-03 22:35:00'),
(8190, 1009, 1, 5134, 3105, NULL,  '2025-11-06 07:30:00', '2025-11-06 08:55:00'),

-- ===== Account 1010 (devices 5137–5140) =====
(8191, 1010, 1, 5137, 3110, 9030, '2025-10-31 23:59:55', '2025-11-01 00:50:00'),
(8192, 1010, 3, 5139, 3101, NULL,  '2025-10-26 20:10:00', '2025-10-26 21:45:00'),
(8193, 1010, 2, 5138, 3106, NULL,  '2025-10-20 21:00:00', '2025-10-20 21:50:00'),
(8194, 1010, 1, 5140, 3107, NULL,  '2025-10-22 19:30:00', '2025-10-22 20:25:00'),
(8195, 1010, 2, 5138, 3108, NULL,  '2025-10-24 18:05:00', '2025-10-24 18:55:00'),
(8196, 1010, 3, 5139, 3109, NULL,  '2025-10-27 20:20:00', '2025-10-27 21:15:00'),
(8197, 1010, 1, 5137, 3102, NULL,  '2025-10-29 12:00:00', '2025-10-29 13:20:00'),
(8198, 1010, 2, 5140, 3103, NULL,  '2025-11-01 14:30:00', '2025-11-01 16:05:00'),
(8199, 1010, 3, 5138, 3104, NULL,  '2025-11-03 09:15:00', '2025-11-03 10:55:00'),
(8200, 1010, 1, 5137, 3105, NULL,  '2025-11-05 07:40:00', '2025-11-05 09:05:00');

-- F01: total watch minutes and play events per movie/series episode title within a time period
-- Given the title of the movie or series episode and its content type (Movie or Episode), list the total minutes watched (computed from start time to end time) and the number of playback events during October 2025. The SQL statement for this query function is to return the Title, Content Type, Total Minutes Watched, and Number of Playback Events for all content played between 2025-10-01 00:00:00 and 2025-11-01 00:00:00. This query function would be useful for the content team to see which content was most popular in October 2025 for promotion and future planning.
SELECT 
    T.Title,
    T.ContentType,
    SUM(TIMESTAMPDIFF(MINUTE,
        PE.start_time,
        PE.end_time)) AS TotalMinutesWatched,
    COUNT(*) AS PlayEvents
FROM
    playback_event PE
        INNER JOIN
    (SELECT 
        m.content_id, m.movie_title AS Title, 'Movie' AS ContentType
    FROM
        movie m UNION ALL SELECT 
        e.content_id,
            e.series_title AS Title,
            'Episode' AS ContentType
    FROM
        episode e) AS T ON T.content_id = PE.content_id
WHERE
    PE.start_time >= '2025-10-01 00:00:00'
        AND PE.start_time < '2025-11-01 00:00:00'
GROUP BY T.Title, T.ContentType
ORDER BY TotalMinutesWatched DESC;

-- F02: per-title ad performance for a given campaign 
-- Given an Ad Campaign ID, list each title that served ads under that campaign and report the total impressions, skipped impressions, skip rate (%), and unique profiles reached. The SQL statement for this query function is to return the Title (movie title or series title), Impressions, Skipped, Skip Rate (%), and Unique Profiles for all ad impressions tied to the specified campaign. This query function would be useful for the advertising operations team and advertiser managers to evaluate delivery and engagement per title for a campaign.
SELECT
  AI.campaign_id,
  T.Title,
  COUNT(*) AS Impressions,
  SUM(CASE WHEN AI.skipped_flag = 1 THEN 1 ELSE 0 END) AS Skipped,
  ROUND(100 * SUM(CASE WHEN AI.skipped_flag = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS SkipRatePct,
  COUNT(DISTINCT PE.account_id, PE.profile_no) AS UniqueProfiles
FROM ad_impression AI
JOIN playback_event PE
  ON AI.impression_id = PE.impression_id       -- <-- correct FK (PE.impression_id)
JOIN (
  SELECT m.content_id, m.movie_title  AS Title FROM movie   m
  UNION ALL
  SELECT e.content_id, e.series_title AS Title FROM episode e
) AS T
  ON T.content_id = PE.content_id
GROUP BY AI.campaign_id, T.Title;

-- F03: Device Type Usage for a given period of time
-- Given all devices registered in the system, list each device type and report its usage activity during a given time period (October 2025).
-- The SQL statement for this query function is to return the Device Type, Total Playback Events, Total Unique Accounts, and Total Unique Profiles
-- for all playback activity that occurred between 2025-10-01 00:00:00 and 2025-11-01 00:00:00.
-- This query function would be useful for the technical operations team to identify which platforms are most frequently used 
-- and prioritize development and support resources accordingly.

SELECT
    D.device_type AS DeviceType,
    COUNT(PE.playback_event_id) AS PlayEvents,
    COUNT(DISTINCT PE.account_id) AS UniqueAccounts,
    COUNT(DISTINCT PE.profile_no) AS UniqueProfiles
FROM
    device D
    JOIN playback_event PE ON D.device_id = PE.device_id AND D.account_id = PE.account_id
WHERE
    PE.start_time >= '2025-10-01 00:00:00'
    AND PE.start_time < '2025-11-01 00:00:00'
GROUP BY D.device_type
ORDER BY PlayEvents DESC;

-- F04: Language Availability Count for Movies and Episodes
-- Given movies and episodes in the database, list each title with its content type and the total number of languages available for that content.
-- The SQL statement for this query function is to return the Title, Content Type (Movie or Episode), 
-- and Language Count for all content items by counting the languages in the content_language table.
-- This query is useful for the content team to monitor language availability per title and guide translation priorities.

SELECT
    T.Title,
    T.ContentType,
    COUNT(DISTINCT CL.language) AS LanguageCount
FROM (
    SELECT m.content_id, m.movie_title AS Title, 'Movie' AS ContentType FROM movie m
    UNION ALL
    SELECT e.content_id, e.series_title AS Title, 'Episode' AS ContentType FROM episode e
) AS T
    JOIN content_language CL ON T.content_id = CL.content_id
GROUP BY T.Title, T.ContentType
ORDER BY LanguageCount DESC, T.Title;
