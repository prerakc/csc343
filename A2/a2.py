"""
A recommender for online shopping.
csc343, Fall 2021
University of Toronto.

--------------------------------------------------------------------------------
This file is Copyright (c) 2021 Diane Horton and Emily Franklin.
All forms of distribution, whether as given or with any changes, are
expressly prohibited.
--------------------------------------------------------------------------------
"""
from typing import List, Optional
import psycopg2 as pg
import psycopg2.extras

from ratings import RatingsTable

from time import sleep

class Recommender:
    """A simple recommender that can work with data conforming to the schema in
    schema.sql.

    === Instance Attributes ===
    dbConnection: Connection to a database of online purchases and product
        recommendations.

    Representation invariants:
    - The database to which dbConnection is connected conforms to the schema
      in schema.sql.
    """

    def __init__(self) -> None:
        """Initialize this Recommender, with no database connection yet.
        """
        self.db_conn = None

    def connect_db(self, url: str, username: str, pword: str) -> bool:
        """Connect to the database at url and for username, and set the
        search_path to "recommender". Return True iff the connection was made
        successfully.

        >>> rec = Recommender()
        >>> # This example will make sense if you change the arguments as
        >>> # appropriate for you.
        >>> rec.connect_db("csc343h-dianeh", "dianeh", "")
        True
        >>> rec.connect_db("test", "postgres", "password") # test doesn't exist
        False
        """
        try:
            self.db_conn = pg.connect(dbname=url, user=username, password=pword,
                                      options="-c search_path=recommender")
        except pg.Error:
            return False

        return True

    def disconnect_db(self) -> bool:
        """Return True iff the connection to the database was closed
        successfully.

        >>> rec = Recommender()
        >>> # This example will make sense if you change the arguments as
        >>> # appropriate for you.
        >>> rec.connect_db("csc343h-dianeh", "dianeh", "")
        True
        >>> rec.disconnect_db()
        True
        """
        try:
            self.db_conn.close()
        except pg.Error:
            return False

        return True

    def recommend_generic(self, k: int) -> Optional[List[int]]:
        """Return the item IDs of recommended items. An item is recommended if
        its average rating is among the top k average ratings for items in the
        PopularItems table.

        If there are not enough rated popular items, there may be fewer than
        k items in the returned list.  If there are ties among the highly
        rated popular items, there may be more than k items that could be
        returned. (This is similar to the hyperconsumers query in Part 1.)
        In that case, order these items by item ID (lowest to highest) and
        take the lowest k.  The net effect is that the number of items returned
        will be <= k.

        If an error is raised, return None.

        Preconditions:
        - Repopulate has been called at least once.
          (Do not call repopulate in this method.)
        - k > 0
        """
        accum = []
        try:
            # TODO: Complete this method.
            if (k <= 0):
                return None
            cur = self.db_conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
            #cur.execute("SET SEARCH_PATH TO Recommender;")
            #accum.append(cur.statusmessage)
            #sleep(5)
            #cur.execute("SHOW SEARCH_PATH;")
            #print(cur.statusmessage)
            #accum.append(cur.fetchall())
            #cur.execute("SELECT table_name FROM information_schema.tables WHERE table_schema = 'recommender';")
            #accum.append(cur.statusmessage)
            #accum.append(cur.fetchall())
            #cur.execute("SELECT * FROM Curator;")
            #accum.append(cur.statusmessage)
            #accum.append(cur.fetchall())
            #cur.execute("SELECT * FROM PopularItems;")
            #accum.append(cur.statusmessage)
            #accum.append(cur.fetchall())
            #cur.execute("SELECT * FROM DefinitiveRatings;")
            #accum.append(cur.statusmessage)
            #accum.append(cur.fetchall())
            cur.execute("DROP VIEW IF EXISTS AverageRatingOfRatedItems;")
            cur.execute("DROP VIEW IF EXISTS AverageRatingOfPopularItems;")
            cur.execute("DROP VIEW IF EXISTS TopKAverageRatingsOfPopularItems;")
            cur.execute("DROP VIEW IF EXISTS RecommendedItems;")
            #print(cur.statusmessage)
            #accum.append(cur.statusmessage)
            cur.execute(
                """
                CREATE VIEW AverageRatingOfRatedItems AS
                SELECT IID, avg(rating) as average
                FROM Review
                GROUP BY IID;
                """
            )
            cur.execute(
                """
                CREATE VIEW AverageRatingOfPopularItems AS
                SELECT IID, average
                FROM PopularItems JOIN AverageRatingOfRatedItems USING (IID);
                """
            )
            #print(cur.statusmessage)
            #accum.append(cur.statusmessage)
            #cur.execute("SELECT * FROM AverageRatings;")
            #accum.append(cur.statusmessage)
            #accum.append(cur.fetchall())
            # cur.execute(
            #     """
            #     SELECT IID
            #     FROM AverageRatings
            #     WHERE average IN (
            #         SELECT DISTINCT average
            #         FROM AverageRatings
            #         ORDER BY average DESC
            #         LIMIT %s
            #     )
            #     ORDER BY IID ASC
            #     LIMIT %s;
            #     """,
            #     (k,k)
            # )
            #print(cur.statusmessage)
            #accum.append(cur.statusmessage)
            #accum.append(cur.fetchall())
            cur.execute(
                """
                CREATE VIEW TopKAverageRatingsOfPopularItems AS
                SELECT DISTINCT average
                FROM AverageRatingOfPopularItems
                ORDER BY average DESC
                LIMIT %s;
                """,
                (k,)
            )
            cur.execute(
                """
                CREATE VIEW RecommendedItems AS
                SELECT IID
                FROM AverageRatingOfRatedItems
                WHERE average IN (SELECT average FROM TopKAverageRatingsOfPopularItems)
                """
            )
            # cur.execute(
            #     """
            #     SELECT IID
            #     FROM AverageRatings
            #     WHERE average IN (
            #         SELECT DISTINCT average
            #         FROM AverageRatings
            #         ORDER BY average DESC
            #         LIMIT %s
            #     )
            #     ORDER BY IID ASC
            #     LIMIT %s;
            #     """,
            #     (k,k)
            # )
            cur.execute('SELECT * FROM RecommendedItems;')
            for record in cur:
                #print(record, type(record), record['iid'], type(record['iid']))
                accum.append(record['iid'])
            cur.close()
            self.db_conn.commit()
            if len(accum) > k:
                accum.sort()
                return accum[0:k]
            return accum
            pass
        except pg.Error:
            #print(accum)
            return None

    def recommend(self, cust: int, k: int) -> Optional[List[int]]:
        """Return the item IDs of items that are recommended for the customer
        with customer ID cust.

        Choose the recommendations as follows:
        - Find the curator whose whose ratings of the 2 most-sold items in
          each category (according to PopularItems) are most similar to the
          customer’s own ratings on these same items.
          HINT: Fill a RatingsTable with the appropriate information and call
          function find_similar_curator.
        - Recommend products that this curator has rated highest. Include
          up to k items, and only items that cust has not bought.

        If there are not enough products rated by this curator, there may be
        fewer than k items in the returned list.  If there are ties among their
        top-rated items, there may be more than k items that could be
        returned. (This is similar to the hyperconsumers query in Part 1.)
        In that case, order these items by item ID (lowest to highest) and
        take the lowest k.  The net effect is that the number of items returned
        will be <= k.

        You will need to put the ratings of all curators on PopularItems into
        your RatingsTable. Get these ratings from the snapshot that is
        currently stored in table DefinitiveRatings.

        If the customer does not have any ratings in common with any of the
        curators (so no similar curator could be found), or if the customer
        has already bought all of the items that are highly recommended by
        their similar curator, then return generic recommendations.

        If an error is raised, return None.

        Preconditions:
        - Repopulate has been called at least once.
          (Do not call repopulate in this method.)
        - k > 0
        - cust is a CID that exists in the database.
        """
        try:
        #connect to db
            cur = self.db_conn.cursor(cursor_factory=psycopg2.extras.DictCursor)

        #get all popular items
            cur.execute(
                """
                select DISTINCT iid from Review;
                """
            )
            mostSold=(cur.fetchall())
            itemQuantity = len(mostSold)

        #get all raters
            cur.execute(
                """
                select DISTINCT cid from Review;
                """)
            raters = (cur.fetchall())

        #initiate RatingsTable
            RT = RatingsTable(len(raters), itemQuantity)

        #get all Ratings
            cur.execute(
                """
                select * from Review;
                """
            )
            ratings = (cur.fetchall())

        #update ratings table with definitive Ratings info
            for i in ratings:
                RT.set_rating(i[0], i[1], i[2])

        #find recommended curator
            listRaters = []
            for i in raters:
                listRaters.append(i[0])
            #remove customer from list of raters to find similar curator that isnt the customer himself
            print(listRaters)
            listRaters.remove(cust)
            similarCurator = find_similar_curator(RT, listRaters, cust)
            print("the similar curator is")
            print(similarCurator)

        #return generic recommendations if there are no similar curators
            if(similarCurator is None):
                return self.recommend_generic(k)

        #find the rated items by curator
            cur.execute(
                """
                SELECT IID FROM Review where CID = %s
                order by rating DESC;
                """,
                (similarCurator,)
            )
            
            rated = cur.fetchall()
            print("the rated is:")
            print(rated)
        #find all items the customer bought
            cur.execute(
                """
                SELECT DISTINCT IID FROM (LineItem natural join Purchase)
                where CID = %s;
                """,
                (cust,)
            )
            alreadyBought = cur.fetchall()
            print("the aleady bought is:")
            print(alreadyBought)

        #in-case there are more than k
            newRated = []
            for i in rated:
                newRated.append(i[0])
            print("the unsorted rated list is:")
            print(rated)
            rated = sorted(list(set(newRated)))
            print("the sorted rated list is:")
            print(rated)
        
        #case: where customer bought nothing
            if len(alreadyBought) == 0:
                return rated
            
        #normal case:
            # removing already bought items from the top rated items
            for i in alreadyBought:
                if(i[0] in rated):
                    rated.remove(i[0])
            print("without removed items")
            print(rated)
            
            #if there is noting new to buy, recommend generic
            length = len(rated)
            if length == 0:
                return self.recommend_generic(k)
            elif(length < k):
                return rated
            #if there is something new to buy, recommend those new items
            return rated[:k]
            
            pass
        except pg.Error:
            return None
            pass
        except pg.Error:
            return None

    def repopulate(self) -> int:
        """Repopulate the database tables that store a snapshot of information
        derived from the base tables: PopularItems and DefinitiveRatings.

        Remove all tuples from these tables and regenerate their content based
        on the current contents of the database. Return 0 if repopulate is
        successful and -1 if there are any errors.

        The meaning of the snapshot tables, and hence what should be in them:
        - PopularItems: The IID of the two items from each category that have
          sold the highest number of units among all items in that category.
        - DefinitiveRatings: The ratings given by curators on the items in the
          PopularItems table.
        """
        try:
            # TODO: Complete this method.
            cur = self.db_conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
            #cur.execute("SET SEARCH_PATH TO Recommender;")
            #print(cur.statusmessage)
            cur.execute("DROP VIEW IF EXISTS ItemQuantitiesBought;")
            #print(cur.statusmessage)
            cur.execute("DELETE FROM PopularItems;")
            #print(cur.statusmessage)
            cur.execute("DELETE FROM DefinitiveRatings;")
            #print(cur.statusmessage)
            cur.execute(
                """
                CREATE VIEW ItemQuantitiesBought AS
                SELECT Item.IID, Item.category, sum(quantity) as bought
                FROM Item JOIN LineItem ON Item.IID = LineItem.IID
                GROUP BY Item.IID;
                """
            )
            #print(cur.statusmessage)
            cur.execute(
                """
                INSERT INTO PopularItems
                (
                    SELECT IID
                    FROM ItemQuantitiesBought X
                    WHERE IID IN (
                        SELECT IID
                        FROM ItemQuantitiesBought Y
                        WHERE X.category = Y.category
                        ORDER BY bought DESC
                        LIMIT 2
                    )
                );
                """
            )
            #print(cur.statusmessage)
            cur.execute(
                """
                INSERT INTO DefinitiveRatings
                (
                    SELECT CID, IID, rating
                    FROM Review
                    WHERE CID IN (SELECT * FROM Curator)
                    AND IID IN (SELECT * FROM PopularItems)
                );
                """
            )
            #print(cur.statusmessage)
            cur.close()
            self.db_conn.commit()
            # for record in cur:
            #     pid = record['pid']
            #     cid = record['cid']
            #     d = record['d']
            #     cnumber = record['cnumber']
            #     card = record['card']
            #     print(f'{pid} | {cid} | {d} | {cnumber} | {card}')
            return 0
            pass
        except pg.Error as e:
            print(e)
            return -1


# NB: This is defined outside of the class, so it is a function rather than
# a method.
def find_similar_curator(ratings: RatingsTable,
                         curator_ids: List[int],
                         cust_id: int) -> Optional[int]:
    """Return the id of the curator who is most similar to the customer
    with iD cust_id based on their ratings, or None if the customer and curators
    have no ratings in common.

    The difference between two customers c1 anc c2 is determined as follows:
    For each pair of ratings by the two customers on the same item, we compute
    the difference between ratings. The overall difference between two customers
    is the average of these ratings differences.

    Preconditions:
    - ratings.get_all_ratings(cust_id) is not None
      That is, cust_id is in the ratings table.
    - For all cid in curator_ids, ratings.get_all_ratings(cid) is not None
      That is, all the curators are in the ratings table.
    """
    cust_rating = ratings.get_all_ratings(cust_id)

    min_curator = None
    min_diff = float('inf')

    for curator in curator_ids:
        cur_rating = ratings.get_all_ratings(curator)

        diff_sum = 0
        num_rtings = 0
        for i in range(len(cur_rating)):
            if cur_rating[i] is not None and cust_rating[i] is not None:
                diff_sum += abs(cur_rating[i] - cust_rating[i])
                num_rtings += 1

        if num_rtings != 0:
            diff = diff_sum / num_rtings
            if diff < min_diff:
                min_diff = diff
                min_curator = curator

    return min_curator


def sample_testing_function() -> None:
    print("Type 0 for Prerak and anything else for Jaak:")
    x= input()
    rec = Recommender()
    if x == '0':
        print("hello prerak")
        # TODO: Change this to connect to your own database:
        rec.connect_db("csc343h-chaud496", "chaud496", "")
        # TODO: Test one or more methods here.
        print(rec.repopulate())
        print(rec.recommend_generic(2))
        rec.disconnect_db()
    else: 
        print("hello jaak")
        # TODO: Change this to connect to your own database:
        rec.connect_db("csc343h-subeeth1", "subeeth1", "")
        # TODO: Test one or more methods here.
        print(rec.repopulate())
        print(rec.recommend(1599, 1))
        rec.disconnect_db()
    



if __name__ == '__main__':
    # TODO: Put your testing code here, or call testing functions such as
    # this one:
    sample_testing_function()
