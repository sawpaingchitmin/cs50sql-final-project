-- Enable checking for foreign key relationships
PRAGMA foreign_keys = ON;

-- Drop existing tables before recreating them
DROP TABLE IF EXISTS "transaction_comments";
DROP TABLE IF EXISTS "budgets";
DROP TABLE IF EXISTS "transactions";
DROP TABLE IF EXISTS "payment_methods";
DROP TABLE IF EXISTS "categories";
DROP TABLE IF EXISTS "users";

-- Drop existing views before recreating them
DROP VIEW IF EXISTS "transaction_details";
DROP VIEW IF EXISTS "user_transaction_count";
DROP VIEW IF EXISTS "user_budget_categories";
DROP VIEW IF EXISTS "categories_without_transactions";
DROP VIEW IF EXISTS "users_with_no_transactions";

-- Table for storing user information, including username, email, and password
CREATE TABLE "users" (
    "id" INTEGER,
    "username" TEXT NOT NULL UNIQUE,
    "email" TEXT NOT NULL UNIQUE,
    "password" TEXT NOT NULL,
    PRIMARY KEY("id")
);

-- Table for storing categories (e.g., income/expense categories)
CREATE TABLE "categories" (
    "id" INTEGER,
    "name" TEXT NOT NULL UNIQUE,
    "type" TEXT NOT NULL CHECK(type IN ('income', 'expense')),
    PRIMARY KEY("id")
);

-- Table for storing payment methods (e.g., cash, credit, etc.)
CREATE TABLE "payment_methods" (
    "id" INTEGER,
    "name" TEXT NOT NULL UNIQUE,
    PRIMARY KEY("id")
);

-- Table for storing transactions made by users
CREATE TABLE "transactions" (
    "id" INTEGER,
    "user_id" INTEGER NOT NULL,
    "category_id" INTEGER NOT NULL,  
    "payment_method_id" INTEGER,     
    "amount" NUMERIC NOT NULL,
    "type" TEXT NOT NULL CHECK(type IN ('income', 'expense')),
    "description" TEXT,
    "date" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id") ON DELETE CASCADE,
    FOREIGN KEY("category_id") REFERENCES "categories"("id") ON DELETE CASCADE,
    FOREIGN KEY("payment_method_id") REFERENCES "payment_methods"("id") ON DELETE SET NULL
);

-- Table for storing budget limits for users on specific categories
CREATE TABLE "budgets" (
    "id" INTEGER,
    "user_id" INTEGER NOT NULL,
    "category_id" INTEGER NOT NULL,  
    "monthly_limit" INTEGER NOT NULL,
    UNIQUE(user_id, category_id),  
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id") ON DELETE CASCADE,
    FOREIGN KEY("category_id") REFERENCES "categories"("id") ON DELETE CASCADE
);

-- Table for storing comments for individual transactions
CREATE TABLE "transaction_comments" (
    "id" INTEGER,
    "transaction_id" INTEGER NOT NULL,  
    "comment" TEXT,                  
    PRIMARY KEY("id"),
    FOREIGN KEY("transaction_id") REFERENCES "transactions"("id") ON DELETE CASCADE
);

-- Indexes for improved performance
CREATE INDEX "transactions_user_id" ON "transactions" ("user_id");
CREATE INDEX "transactions_category_id" ON "transactions" ("category_id");
CREATE INDEX "budgets_user_id" ON "budgets" ("user_id");
CREATE INDEX "budgets_category_id" ON "budgets" ("category_id");
CREATE INDEX "transactions_user_category" ON "transactions" ("user_id", "category_id");
CREATE INDEX "budgets_user_category" ON "budgets" ("user_id", "category_id");
CREATE INDEX "transactions_payment_method_id" ON "transactions" ("payment_method_id");
CREATE INDEX "transaction_comments_transaction_id" ON "transaction_comments" ("transaction_id");

--  View for Transaction Details with User and Category Information
CREATE VIEW "transaction_details" AS
SELECT "transactions"."id", 
       "transactions"."user_id", 
       "transactions"."category_id", 
       "transactions"."payment_method_id", 
       "transactions"."amount", 
       "transactions"."type", 
       "transactions"."description", 
       "transactions"."date", 
       "users"."username", 
       "categories"."name" AS "category_name"
FROM "transactions"
JOIN "users" 
ON "transactions"."user_id" = "users"."id"
JOIN "categories" 
ON "transactions"."category_id" = "categories"."id";

-- View for Users and Their Transaction Counts
CREATE VIEW "user_transaction_count" AS
SELECT "users"."id", 
       "users"."username", 
       COUNT("transactions"."id") AS "transaction_count"
FROM "users"
JOIN "transactions" 
ON "users"."id" = "transactions"."user_id"
GROUP BY "users"."id";

-- View for Users with Budgets and Their Associated Categories
CREATE VIEW "user_budget_categories" AS
SELECT "users"."id" AS "user_id", 
       "categories"."id" AS "category_id",
       "users"."username", 
       "categories"."name" AS "category_name", 
       "budgets"."monthly_limit"
FROM "users"
JOIN "budgets" 
ON "users"."id" = "budgets"."user_id"
JOIN "categories" 
ON "budgets"."category_id" = "categories"."id";

-- View for Categories Without Transactions
CREATE VIEW "categories_without_transactions" AS
SELECT "categories"."name" AS "category_name"
FROM "categories"
LEFT JOIN "transactions" ON "categories"."id" = "transactions"."category_id"
WHERE "transactions"."id" IS NULL;

-- View for Users with Budgets But No Transactions
CREATE VIEW "users_with_no_transactions" AS
SELECT  DISTINCT "users"."id" AS "user_id", "users"."username"
FROM "users"
JOIN "budgets" 
ON "users"."id" = "budgets"."user_id"
LEFT JOIN "transactions" 
ON "budgets"."user_id" = "transactions"."user_id"
AND "budgets"."category_id" = "transactions"."category_id"
WHERE "transactions"."id" IS NULL;


