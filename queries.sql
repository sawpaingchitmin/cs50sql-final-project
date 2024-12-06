-- Delete all records from the tables to start fresh
DELETE FROM "users";
DELETE FROM "categories";
DELETE FROM "payment_methods";
DELETE FROM "transactions";
DELETE FROM "budgets";
DELETE FROM "transaction_comments";

-- Insert new user data into the "users" table
INSERT INTO "users" ("username", "email", "password")
VALUES ('SawPaing', 'sawpaing@gmail.com', 'd0b3d852ad218f0cd42e01d503b1cfa1'),
       ('HenryMin', 'henry@gmail.com', 'd20e8eea62773a60820319487277c7f6');

-- Insert new category data into the "categories" table (income and expense categories)
INSERT INTO "categories" ("name", "type")
VALUES ('Salary', 'income'),
       ('Rent', 'expense'),
       ('Groceries', 'expense'),
       ('Profit', 'income');

-- Insert new payment method data into the "payment_methods" table
INSERT INTO "payment_methods" ("name")
VALUES ('Bank Transfer'),
       ('Cash'),
       ('Credit Card');

-- Insert transaction data into the "transactions" table (user transactions)
INSERT INTO "transactions" ("user_id", "category_id", "payment_method_id", "amount", "type", "description")
VALUES (1, 1, 1, 3000, 'income', 'November paycheck'),
       (1, 2, 2, 500, 'expense', 'Apartment rent'),
       (1, 3, 3, 700, 'expense', 'Grocery shopping'),
       (2, 1, 1, 4000, 'income', 'November profit'),
       (2, 2, 2, 1500, 'expense', 'House rent');

-- Insert budget data for each user and category into the "budgets" table
INSERT INTO "budgets" ("user_id", "category_id", "monthly_limit")
VALUES (1, 2, 500),
       (1, 3, 600),
       (2, 2, 1000),
       (2, 3, 800);

-- Insert comments for each transaction into the "transaction_comments" table
INSERT INTO "transaction_comments" ("transaction_id", "comment")
VALUES (1, "First salary from the job"),
       (2, "Paid the apartment rent for December"),
       (3, "Buy groceries for 10 days");
       
-- Get total spending by users for expenses and order them by the highest spending
SELECT "username", SUM("amount") AS "total_spent"
FROM "transaction_details" 
WHERE "type" = 'expense'
GROUP BY "user_id"
ORDER BY "total_spent" DESC;

-- List users and their total number of transactions, ordered by transaction count
SELECT * 
FROM "user_transaction_count"
ORDER BY "transaction_count" DESC;

-- Get users, their categories, and monthly budget limits, ordered by username and category
SELECT "username", "category_name", "monthly_limit"
FROM "user_budget_categories"
ORDER BY "username", "category_name";

-- Get categories that don't have any transactions
SELECT "category_name"
FROM "categories_without_transactions";

-- Get users who have budgets but no transactions, ordered by user ID
SELECT "username"
FROM "users_with_no_transactions"
ORDER BY "user_id";

-- Fix the email for user HenryMin
UPDATE "users"
SET "email" = 'henrymin@gmail.com'
WHERE "username" = 'HenryMin';

-- Adjust the amount of November paycheck for user SawPaing
UPDATE "transactions"
SET "amount" = 3500
WHERE "user_id" = (
       SELECT "id"
       FROM "users"
       WHERE "username" = 'SawPaing' 
       AND "description" = 'November paycheck'
);

-- Update the monthly budget for rent and groceries for user 1
UPDATE "budgets"
SET "monthly_limit" = CASE
    WHEN "category_id" = 2 THEN 700
    WHEN "category_id" = 3 THEN 800
END
WHERE "user_id" = 1 AND "category_id" IN (2, 3);

-- Delete the incorrect apartment rent transaction for user_id 1
DELETE FROM "transactions"
WHERE "user_id" = 1 AND "description" = 'Apartment rent';

-- Delete the unused 'Credit Card' payment method
DELETE FROM "payment_methods"
WHERE name = 'Credit Card';
















