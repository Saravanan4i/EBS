-- Drop the table if it already exists (optional)
DROP TABLE IF EXISTS Members;

-- Create the Members table
CREATE TABLE Members (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary DECIMAL(10, 2),
    hire_date DATE
);

-- Insert sample data into Members table
INSERT INTO Members (employee_id, first_name, last_name, department, salary, hire_date)
VALUES 
(1, 'John', 'Doe', 'IT', 75000.00, '2023-06-15'),
(2, 'Jane', 'Smith', 'HR', 68000.50, '2022-09-01'),
(3, 'Emily', 'Johnson', 'Finance', 80000.00, '2021-01-12'),
(4, 'Michael', 'Williams', 'Marketing', 72000.75, '2020-04-20'),
(5, 'David', 'Brown', 'Operations', 67000.25, '2019-11-05');