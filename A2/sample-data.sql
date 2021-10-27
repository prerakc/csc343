-- Small sample dataset for Assignment 2.

-- Item(IID, category, description, price)
INSERT INTO Item VALUES 
(1, 'Book', 'Cloud Atlas', 21.00),
(2, 'Book', 'A Thousand Splendid Suns', 14.00),
(3, 'Book', 'Homegoing', 22.00),
(4, 'Book', 'Trickster', 18.00),
(5, 'Toy', 'Lego Hogwarts School of Witchcraft and Wizardry', 99.00),
(6, 'Toy', 'AR-15', 999.99);

-- Customer(CID, email, lastName, firstName, title)
INSERT INTO Customer VALUES
(1599, 'g@g.com', 'Granger', 'Hermione', 'Ms'),
(1518, 'p@p.com', 'Potter', 'Harry', 'Mr'),
(1515, 'w@w.com', 'Weasley', 'Ron', 'Master'),
(1500, NULL, 'Dumbledor', 'Albus', 'Professor');
      
-- Purchase(PID, CID, d, cNumber, card)
INSERT INTO Purchase VALUES
(100, 1515, '2019-11-01', 12345, 'Amex'),
(101, 1500, '2020-11-01', 64210, 'Visa'),
(102, 1518, '2020-01-01', 99999, 'Mastercard'),
(103, 1515, '2020-11-02', 12345, 'Amex');

-- LineItem(PID, IID, quantity)
INSERT INTO LineItem VALUES
(100, 4, 1),
(100, 1, 2),
(100, 5, 1),
(101, 2, 100),
(102, 3, 10),
(102, 1, 1),
(102, 2, 1),
(102, 4, 1),
(103, 6, 1);

-- Review(CID, IID, rating, comment)
INSERT INTO Review VALUES
(1515, 4, 5, 'Fantastic read!'),
(1518, 4, 5, 'Ron said it was fantastic and he was right!!!'),
(1515, 5, 1, 'I choked on a LEGO piece and nearly died.'),
(1518, 1, 7, NULL),
(1599, 4, 5, 'Ron didn''t lie!'),
(1515, 6, 10, 'Fun for the whole family!');

-- Helpfulness(reviewer, IID, observer, helpfulness)
INSERT INTO Helpfulness VALUES
(1515, 4, 1599, False),
(1515, 4, 1518, True),
(1515, 4, 1515, True),
(1515, 4, 1500, True),
(1518, 4, 1599, True),
(1518, 4, 1515, True),
(1518, 4, 1500, False);

