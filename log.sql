-- Keep a log of any SQL queries you execute as you solve the mystery.

-- All you know is that the theft took place on July 28, 2024 and that it took place on Humphrey Street.

-- To understand all tables, drew a table map (seperately) with connections:
.schema

-------------------------------------------------------------------------------------------------------------------------------

-- Overview of Crimes:
SELECT * FROM crime_scene_reports;


-- Crimes on the day of theft:
SELECT * FROM crime_scene_reports WHERE year = 2024 AND month = 7 AND day = 28;


-- Interviewes on the day of crime:
SELECT * FROM interviews WHERE year = 2024 AND month = 7 AND day = 28;


-------------------------------------------------------------------------------------------------------------------------------


-- As per interview: ATM withdrawal by theif, then theft, then call of less than a minute, then exit by car, then earliest flight
-- the next morning.


-- Transactions on the day of the crime on Leggett Street:
SELECT * FROM atm_transactions WHERE year = 2024 AND month = 7 AND day = 28 AND atm_location = 'Leggett Street';


-- Names of the people who had transactions on Leggett Street ATMM on July 28, 2024:
SELECT name
FROM people
WHERE id IN (
    SELECT person_id FROM bank_accounts WHERE account_number IN (
        SELECT account_number FROM atm_transactions
        WHERE year = 2024 AND month = 7 AND day = 28 AND atm_location = 'Leggett Street'
    )
);


-- Names of People who withdrew money from Leggett Street ATM on July 28, 2024:
SELECT name
FROM people
WHERE id IN (
    SELECT person_id FROM bank_accounts WHERE account_number IN (
        SELECT account_number FROM atm_transactions
        WHERE year = 2024 AND month = 7 AND day = 28
        AND atm_location = 'Leggett Street' AND transaction_type = 'withdraw'
    )
);


----------------------- SUSPECTS: Kenney, Iman, Benista, Taylor, Brooke, Luca, Diana and Bruce -----------------------



--  Calls on July 28, 2024 that lasted a mintue or less:
SELECT * FROM phone_calls WHERE year = 2024 AND month = 7 AND day = 28 AND duration <= 60;


-- Names of the people who called for a mintue or less on July 28, 2024:
SELECT name
FROM people
WHERE phone_number IN (
    SELECT caller FROM phone_calls WHERE year = 2024 AND month = 7 AND day = 28 AND duration <= 60
);


----------------------- SUSPECTS: Kenney, Benista, Taylor, Diana and Bruce -----------------------



-- Names of the people who recieved for a mintue or less on July 28, 2024:
SELECT name
FROM people
WHERE phone_number IN (
    SELECT receiver FROM phone_calls
    WHERE year = 2024 AND month = 7 AND day = 28 AND duration <= 60
);


-- Who called who on July 28, 2024:
SELECT caller_person.name AS caller, receiver_person.name AS receiver
FROM phone_calls AS c
JOIN people AS caller_person ON c.caller = caller_person.phone_number
JOIN people AS receiver_person ON c.receiver = receiver_person.phone_number
WHERE c.year = 2024 AND c.month = 7 AND c.day = 28 AND c.duration <= 60;


----------------------- SUSPECTS (Accomplice): Doris, Anna, James, Philip and Robin -----------------------



-- All those who exited the bakery from the time of the theft
SELECT * FROM bakery_security_logs
WHERE year = 2024 AND month = 7 AND day = 28 AND hour = 10 AND minute >=15 AND activity = 'exit';


-- Names of those who exited bakery from time of theft.
SELECT name FROM people WHERE license_plate IN (
    SELECT license_plate FROM bakery_security_logs
    WHERE year = 2024 AND month = 7 AND day = 28 AND hour = 10 AND minute >=15 AND activity = 'exit'
);


-- "within ten minutes" of the theft as per interview of Ruth
SELECT name FROM people WHERE license_plate IN (
    SELECT license_plate FROM bakery_security_logs
    WHERE year = 2024 AND month = 7 AND day = 28 AND hour = 10
    AND minute >=15 AND minute <=25 AND activity = 'exit'
);


----------------------- SUSPECTS: Diana and Bruce -----------------------




-- overview of airports table
SELECT * FROM airports;
-- 8, CSF, Fiftyville Regional Airport --


-- For flights on the 29th, as per interview of Raymond
SELECT * FROM flights WHERE year = 2024  AND month = 7 AND day = 29;


-- NOTE: Earliest flights: id 4 and id 1, could be id 11 also..


-- Those on flight 4 ad 1:
SELECT passport_number FROM passengers WHERE flight_id IN (
    SELECT id FROM flights
    WHERE year = 2024  AND month = 7 AND day = 29
    AND (destination_airport_id = 4 OR destination_airport_id = 1));


-- Names of those on flight 4:
SELECT name FROM people WHERE passport_number IN (
    SELECT passport_number FROM passengers WHERE flight_id IN (
        SELECT id FROM flights
        WHERE year = 2024  AND month = 7 AND day = 29 AND destination_airport_id = 4));


-- Names of those on flight 1:
SELECT name FROM people WHERE passport_number IN (
    SELECT passport_number FROM passengers WHERE flight_id IN (
        SELECT id FROM flights
        WHERE year = 2024  AND month = 7 AND day = 29 AND destination_airport_id = 1));


-- 4 is the earlier flight


----------------------- SUSPECTS: Bruce -----------------------



-- Criminal: Bruce and Robin. PROOF:

-------------- Info of both --------------
SELECT * FROM people WHERE name = 'Bruce' OR name = 'Robin';

-- +--------+-------+----------------+-----------------+---------------+
-- |   id   | name  |  phone_number  | passport_number | license_plate |
-- +--------+-------+----------------+-----------------+---------------+
-- | 686048 | Bruce | (367) 555-5533 | 5773159633      | 94KL13X       |
-- | 864400 | Robin | (375) 555-8161 | NULL            | 4V16VO0       |
-- +--------+-------+----------------+-----------------+---------------+



-------------- Their entries and exits --------------
 SELECT * FROM bakery_security_logs WHERE license_plate = '94KL13X' or license_plate = '4V16VO0';

-- +-----+------+-------+-----+------+--------+----------+---------------+
-- | id  | year | month | day | hour | minute | activity | license_plate |
-- +-----+------+-------+-----+------+--------+----------+---------------+
-- | 232 | 2024 | 7     | 28  | 8    | 23     | entrance | 94KL13X       |
-- | 248 | 2024 | 7     | 28  | 8    | 50     | entrance | 4V16VO0       |
-- | 249 | 2024 | 7     | 28  | 8    | 50     | exit     | 4V16VO0       |
-- | 261 | 2024 | 7     | 28  | 10   | 18     | exit     | 94KL13X       |
-- +-----+------+-------+-----+------+--------+----------+---------------+



-------------- Withdrawal on Leggett Street on July 28, 2024 --------------
SELECT name
FROM people
WHERE id IN (
    SELECT person_id FROM bank_accounts
    WHERE account_number IN (
        SELECT account_number FROM atm_transactions
        WHERE year = 2024  AND month = 7 AND day = 28 AND atm_location = 'Leggett Street' AND transaction_type = 'withdraw'
        ));

-- +---------+
-- |  name   |
-- +---------+
-- | Kenny   |
-- | Iman    |
-- | Benista |
-- | Taylor  |
-- | Brooke  |
-- | Luca    |
-- | Diana   |
-- | Bruce   |
-- +---------+



-------------- Exit within ten minutes of theft --------------
SELECT name FROM people WHERE license_plate IN (
    SELECT license_plate FROM bakery_security_logs
    WHERE year = 2024 AND month = 7 AND day = 28 AND hour = 10
    AND minute >=15 AND minute <=25
    AND activity = 'exit'
);

-- +---------+
-- |  name   |
-- +---------+
-- | Vanessa |
-- | Barry   |
-- | Iman    |
-- | Sofia   |
-- | Luca    |
-- | Diana   |
-- | Kelsey  |
-- | Bruce   |
-- +---------+



-------------- Bruce calls Robin for 45 seconds --------------
SELECT name FROM people WHERE phone_number IN (
    SELECT caller FROM phone_calls
    WHERE year = 2024 AND month = 7 AND day = 28 AND duration <= 60
    AND receiver = '(375) 555-8161'
);



-------------- Earliest flight on 29th --------------
SELECT name FROM people
WHERE passport_number IN (
    SELECT passport_number FROM passengers WHERE flight_id IN (
        SELECT id FROM flights WHERE year = 2024 AND month = 7 AND day = 29 AND hour < 9
    ));


-------------------------------------------------------------------------------------------------------------------------------
-- Hence: On the morning of 28th July, 2024 Bruce was spotted by Eugene (162) withdraw cash from the ATM on Leggett Street.
-- At 10:15am the CS50 duck was stolen by Bruce, who then called Robin instructing him to buy the flight ticket for the earliest
-- flight out of fifftyville for the next morning, the call lasted 45 seconds, Bruce then exited the bakery by car at 10:18
-- corresponding with the interview of Ruth - the car of Bruce had entered at 8:23 earlier, and the car of Robin had entered
-- and swiftly exited at 8:50 perhaps to set the plan in motion. The day after Bruce took the earliest flight taking off
-- at 8:20 from fifftyville, with the id of 36, to LaGuardia Airport in New York City.
