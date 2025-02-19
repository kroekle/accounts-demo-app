-- Create the manager table
CREATE TABLE manager (
    manager_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    us BOOLEAN NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create the account table
CREATE TABLE account (
    account_id SERIAL PRIMARY KEY,
    holder_name VARCHAR(100) NOT NULL,
    balance INT NOT NULL,
    manager_id INT,
    region VARCHAR(20) NOT NULL CHECK (region IN ('WEST', 'NORTH', 'SOUTH', 'EAST', 'ASIA', 'AFRICA', 'AUSTRALIA', 'EUROPE', 'NA', 'SA')),
    account_status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (account_status IN ('ACTIVE', 'INACTIVE')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (manager_id) REFERENCES manager(manager_id)
);

-- Insert mock data into the manager table
INSERT INTO manager (name, us) VALUES
('Alice Doe', true),
('Kurt Doe', true),
('Charlie Brown', true),
('Tim Doe', true),
('Sue Doe', false),
('Ethan Hunt', false),
('George Clooney', false),
('Hannah Montana', false),
('Ian Somerhalder', false),
('Jack Sparrow', false);

-- Insert mock data into the account table with higher balances and regions
INSERT INTO account (holder_name, balance, manager_id, region) VALUES
('John Doe', 21021000, 1, 'WEST'),
('Jane Doe', 4004000, 2, 'NORTH'),
('Jim Beam', 26026000, 3, 'SOUTH'),
('Jack Daniels', 29450, 4, 'EAST'),
('Johnny Walker', 31200, 5, 'ASIA'),
('Jill Valentine', 34800, 6, 'AFRICA'),
('Jake Peralta', 40200, 7, 'AUSTRALIA'),
('Amy Santiago', 45700, 1, 'EUROPE'),
('Terry Jeffords', 50300, 9, 'NA'),
('Rosa Diaz', 55800, 10, 'SA'),
('Michael Scott', 1005000, 1, 'WEST'),
('Dwight Schrute', 2002000, 2, 'NORTH'),
('Jim Halpert', 3003000, 3, 'SOUTH'),
('Pam Beesly', 4004000, 4, 'EAST'),
('Stanley Hudson', 5005000, 5, 'ASIA'),
('Kevin Malone', 6006000, 6, 'AFRICA'),
('Angela Martin', 7007000, 7, 'AUSTRALIA'),
('Oscar Martinez', 8008000, 1, 'EUROPE'),
('Phyllis Vance', 27800, 9, 'NA'),
('Meredith Palmer', 10010000, 10, 'SA'),
('Creed Bratton', 11011000, 1, 'WEST'),
('Ryan Howard', 12012000, 2, 'NORTH'),
('Kelly Kapoor', 13013000, 3, 'SOUTH'),
('Toby Flenderson', 14014000, 4, 'EAST'),
('Darryl Philbin', 15015000, 5, 'ASIA'),
('Andy Bernard', 16016000, 6, 'AFRICA'),
('Erin Hannon', 17017000, 7, 'AUSTRALIA'),
('Gabe Lewis', 18018000, 1, 'EUROPE'),
('Holly Flax', 19019000, 9, 'NA'),
('Jan Levinson', 20020000, 10, 'SA'),
('David Wallace', 21021000, 1, 'WEST'),
('Roy Anderson', 22022000, 2, 'NORTH'),
('Karen Filippelli', 23023000, 3, 'SOUTH'),
('Charles Miner', 24024000, 4, 'EAST'),
('Jo Bennett', 25025000, 5, 'ASIA'),
('Robert California', 26026000, 6, 'AFRICA'),
('Nellie Bertram', 27027000, 7, 'AUSTRALIA'),
('Clark Green', 28028000, 8, 'EUROPE'),
('Pete Miller', 29029000, 9, 'NA'),
('Nate Nickerson', 30030000, 10, 'SA'),
('Deangelo Vickers', 31031000, 1, 'WEST'),
('Todd Packer', 32032000, 2, 'NORTH'),
('Josh Porter', 33033000, 3, 'SOUTH'),
('Hunter Raymond', 34034000, 4, 'EAST'),
('Danny Cordray', 35035000, 5, 'ASIA'),
('Katy Moore', 36036000, 6, 'AFRICA'),
('Lonny Collins', 37037000, 7, 'AUSTRALIA'),
('Madge Madsen', 38038000, 8, 'EUROPE'),
('Glenn', 39039000, 9, 'NA'),
('Jordan Garfield', 40040000, 10, 'SA'),
('Val Johnson', 41041000, 1, 'WEST'),
('Brenda Matlowe', 42042000, 2, 'NORTH'),
('Sadiq', 43043000, 3, 'SOUTH'),
('Billy Merchant', 44044000, 4, 'EAST'),
('Hidetoshi Hasagawa', 45045000, 5, 'ASIA'),
('Tony Gardner', 46046000, 6, 'AFRICA'),
('Martin Nash', 47047000, 7, 'AUSTRALIA'),
('Hannah Smoterich-Barr', 48048000, 8, 'EUROPE'),
('Rolando', 49049000, 9, 'NA'),
('Cathy Simms', 50050000, 10, 'SA');

-- Update the first 15 accounts to ACTIVE
UPDATE account
SET account_status = 'ACTIVE'
WHERE account_id <= 12;

-- Update 20% of the remaining accounts to INACTIVE
UPDATE account
SET account_status = 'INACTIVE'
WHERE account_id > 15
AND account_id % 5 = 0;