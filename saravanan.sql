CREATE TABLE saravanan (
    id INT PRIMARY KEY,                -- Unique identifier for each record
    first_name VARCHAR(50),           -- First name of the person
    last_name VARCHAR(50),            -- Last name of the person
    email VARCHAR(100),               -- Email address
    phone_number VARCHAR(15),         -- Phone number
    department VARCHAR(50),           -- Department where the person works
    hire_date DATE,                   -- Date when the person was hired
    salary DECIMAL(10, 2),            -- Salary with two decimal points
);
