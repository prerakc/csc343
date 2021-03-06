-- -- Small sample dataset for Assignment 2.

-- -- Item(IID, category, description, price)
-- INSERT INTO Item VALUES 
-- (1, 'Book', 'Cloud Atlas', 21.00),
-- (2, 'Shirt', 'A Thousand Splendid Suns', 14.00),
-- (3, 'Hat', 'Homegoing', 52.00);

-- -- Customer(CID, email, lastName, firstName, title)
-- INSERT INTO Customer VALUES
-- (100, 'g@g.com', 'Granger', 'Hermione', 'Ms'),
-- (200, 'p@p.com', 'Potter', 'Harry', 'Mr'),
-- (300, 'w@w.com', 'Weasley', 'Ron', 'Master');
      
-- -- Purchase(PID, CID, d, cNumber, card)
-- INSERT INTO Purchase VALUES
-- (1, 100, '2020-02-05', 12345, 'Visa'),
-- (2, 200, '2020-02-05', 12345, 'Visa'),
-- (3, 300, '2020-02-05', 12345, 'Visa');

-- -- LineItem(PID, IID, quantity)
-- INSERT INTO LineItem VALUES
-- (1, 1, 1),
-- (2, 1, 1),
-- (2, 2, 1),
-- (2, 3, 1),
-- (3, 2, 1);

-- -- Review(CID, IID, rating, comment)
-- INSERT INTO Review VALUES
-- (100, 1, 5, 'blah'),
-- (200, 1, 1, 'blah'),
-- (200, 2, 4, 'blah'),
-- (300, 2, 5, 'blah'),
-- (200, 3, 5, 'blah');

-- Helpfulness(reviewer, IID, observer, helpfulness)
-- INSERT INTO Helpfulness VALUES
-- ();

-- -- Small sample dataset for Assignment 2.

-- -- Item(IID, category, description, price)
-- INSERT INTO Item VALUES 
-- (1, 'Book', 'Cloud Atlas', 21.00),
-- (2, 'Book', 'A Thousand Splendid Suns', 14.00),
-- (3, 'Book', 'Homegoing', 22.00),
-- (4, 'Book', 'Trickster', 18.00),
-- (5, 'Toy', 'Lego Hogwarts School of Witchcraft and Wizardry', 99.00);

-- -- Customer(CID, email, lastName, firstName, title)
-- INSERT INTO Customer VALUES
-- (1599, 'g@g.com', 'Granger', 'Hermione', 'Ms'),
-- (1518, 'p@p.com', 'Potter', 'Harry', 'Mr'),
-- (1515, 'w@w.com', 'Weasley', 'Ron', 'Master'),
-- (1500, NULL, 'Dumbledor', 'Albus', 'Professor');
      
-- -- Purchase(PID, CID, d, cNumber, card)
-- INSERT INTO Purchase VALUES
-- (100, 1515, '2019-11-01', 12345, 'Amex'),
-- (101, 1500, '2019-11-01', 64210, 'Visa'),
-- (102, 1518, '2021-01-01', 99999, 'Mastercard');

-- -- LineItem(PID, IID, quantity)
-- INSERT INTO LineItem VALUES
-- (100, 4, 1),
-- (100, 1, 2),
-- (100, 5, 1),
-- (101, 2, 4),
-- (102, 3, 10);

-- -- Review(CID, IID, rating, comment)
-- INSERT INTO Review VALUES
-- (1515, 4, 5, 'Fantastic read!'),
-- (1518, 4, 5, 'Ron said it was fantastic and he was right!!!');

-- -- Helpfulness(reviewer, IID, observer, helpfulness)
-- INSERT INTO Helpfulness VALUES
-- (1515, 4, 1599, False),
-- (1515, 4, 1518, True),
-- (1515, 4, 1515, True),
-- (1515, 4, 1500, True),
-- (1518, 4, 1599, True),
-- (1518, 4, 1515, True),
-- (1518, 4, 1500, False);

-- Small sample dataset for Assignment 2.

-- Item(IID, category, description, price)
INSERT INTO Item VALUES 
(1, 'Book', 'Cloud Atlas', 21.00),
(2, 'Book', 'A Thousand Splendid Suns', 14.00),
(3, 'Book', 'Homegoing', 52.00),
(4, 'Book', 'Trickster', 8.00),
(5, 'Toy', 'Lego Hogwarts School of Witchcraft and Wizardry', 99.00),
(6, 'Toy', 'AR-15', 1000.00),
(7, 'Book', 'The Beast in the Veil', 1.00),
(8, 'Book', 'Prince of Glass', 2.00),
(9, 'Book', 'The Gold Painting', 3.00);

-- Customer(CID, email, lastName, firstName, title)
INSERT INTO Customer VALUES
(1599, 'g@g.com', 'Granger', 'Hermione', 'Ms'),
(1518, 'p@p.com', 'Potter', 'Harry', 'Mr'),
(1515, 'w@w.com', 'Weasley', 'Ron', 'Master'),
(1500, NULL, 'Dumbledor', 'Albus', 'Professor');
      
-- Purchase(PID, CID, d, cNumber, card)
INSERT INTO Purchase VALUES
(100, 1515, '2019-07-25', 12345, 'Amex'), -- change to current date
(101, 1500, '2020-11-01', 64210, 'Visa'),
(102, 1518, '2020-01-01', 99999, 'Mastercard'),
(103, 1515, '2020-11-02', 12345, 'Amex'),
(104, 1515, '2021-11-02 00:00:00', 12345, 'Amex'),
(105, 1515, '2021-11-02 00:00:01', 12345, 'Amex'),
(106, 1515, '2021-11-02 00:00:02', 12345, 'Amex'),
(107, 1515, '2021-11-02 00:00:03', 12345, 'Amex'),
(108, 1515, '2021-11-02 00:00:04', 12345, 'Amex'),
(109, 1515, '2021-11-02 00:00:05', 12345, 'Amex'),
(110, 1515, '2021-11-02 00:00:06', 12345, 'Amex'),
(111, 1515, '2021-11-02 00:00:07', 12345, 'Amex'),
(112, 1515, '2021-11-02 00:00:08', 12345, 'Amex');

-- LineItem(PID, IID, quantity)
INSERT INTO LineItem VALUES
(100, 4, 9),
(100, 1, 2),
(100, 5, 1),
(100, 2, 1),
(101, 2, 100),
(102, 3, 10),
(102, 1, 1),
(102, 2, 1),
(102, 4, 2),
(103, 6, 10),
(104, 6, 1),
(105, 6, 1),
(106, 6, 1),
(107, 6, 1),
(108, 6, 1),
(109, 6, 1),
(110, 6, 1),
(111, 6, 1),
(112, 6, 1),
(100, 7, 1),
(100, 8, 1),
(100, 9, 1);

-- Review(CID, IID, rating, comment)
INSERT INTO Review VALUES
(1515, 4, 5, 'Fantastic read!'),
(1518, 4, 5, 'Ron said it was fantastic and he was right!!!'),
(1515, 5, 1, 'I choked on a LEGO piece and nearly died.'),
(1599, 4, 5, 'Ron didn''t lie!'),
(1515, 6, 10, 'Fun for the whole family!'),
(1515, 2, 2, NULL);

-- Helpfulness(reviewer, IID, observer, helpfulness)
INSERT INTO Helpfulness VALUES
(1599, 4, 1500, True),
(1515, 4, 1518, True),
(1515, 5, 1500, True),
(1515, 6, 1500, True),
(1518, 4, 1515, True),
(1518, 4, 1500, True);