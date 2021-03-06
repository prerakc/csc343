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
        
        try:
            # list to store IIDs of recommended items
            accum = []

            # set up cursor
            cur = self.db_conn.cursor(cursor_factory=psycopg2.extras.DictCursor)

            # drop intermediate views
            cur.execute("DROP VIEW IF EXISTS AverageRatingOfPopularItems;")

            # get average rating of every popular item
            cur.execute(
                """
                CREATE VIEW AverageRatingOfPopularItems AS
                SELECT IID, avg(rating) AS average
                FROM PopularItems JOIN Review USING (IID)
                GROUP BY IID;
                """
            )

            # order popular item average ratings in descending order
            # in case of ties, order IIDs in ascending order
            # get top k rows
            cur.execute(
                """                
                SELECT IID
                FROM AverageRatingOfPopularItems
                ORDER BY average DESC, IID ASC
                LIMIT %s;
                """,
                (k,)
            )

            # store IIDs of recommended items
            for record in cur:
                accum.append(record['iid'])

            # close cursor and commit changes
            cur.close()
            self.db_conn.commit()

            # return IIDs of recommended items
            return accum
            pass
        except pg.Error:
            return None

    def recommend(self, cust: int, k: int) -> Optional[List[int]]:
        """Return the item IDs of items that are recommended for the customer
        with customer ID cust.

        Choose the recommendations as follows:
        - Find the curator whose whose ratings of the 2 most-sold items in
          each category (according to PopularItems) are most similar to the
          customer???s own ratings on these same items.
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
            # set up cursor
            cur = self.db_conn.cursor(cursor_factory=psycopg2.extras.DictCursor)

            # get popular items
            cur.execute('SELECT * FROM PopularItems;')
            popularItems = [record['iid'] for record in cur.fetchall()]
            numPopularItems = len(popularItems)

            # get curators
            cur.execute('SELECT * FROM Curator;')
            curators = [record['cid'] for record in cur.fetchall()]
            numCurators = len(curators)

            # initalize ratings table
            ratingsTable = RatingsTable(numCurators + 1, numPopularItems)

            # get curators' ratings on popular items
            cur.execute('SELECT * FROM DefinitiveRatings;')
            curatorRatings = cur.fetchall()

            # get customer's ratings on popular items
            cur.execute(
                """
                SELECT IID, rating
                FROM Review
                WHERE CID = %s AND IID IN (
                    SELECT *
                    FROM PopularItems
                );
                """,
                (cust,)
            )
            customerRatings = cur.fetchall()

            # add curator ratings to ratings table
            for i in curatorRatings:
                ratingsTable.set_rating(i[0], i[1], i[2])

            # add customer ratings to ratings table
            for i in customerRatings:
                ratingsTable.set_rating(cust, i[0], i[1])

            # find curator most similar to customer
            mostSimilarCurator = find_similar_curator(ratingsTable, curators, cust)

            # if no similar curator is found, return the generic recommendations
            if mostSimilarCurator == None:
                return self.recommend_generic(k)
            
            # items bought by customer
            cur.execute("DROP VIEW IF EXISTS ItemsBoughtByCustomer;")

            cur.execute(
                """
                CREATE VIEW ItemsBoughtByCustomer AS
                SELECT DISTINCT IID
                FROM Purchase JOIN LineItem USING (PID)
                WHERE CID = %s;
                """,
                (cust,)
            )

            # for the items rated by the most similar curator
            # that have not already been purchased by the customer,
            # order the reviews in descending order of rating and
            # in the event of ties, by ascending order of IID
            cur.execute(
                """
                SELECT IID
                FROM Review
                WHERE CID = %s AND IID NOT IN (
                    SELECT *
                    FROM ItemsBoughtByCustomer
                )
                ORDER BY rating DESC, IID ASC
                LIMIT %s;
                """,
                (mostSimilarCurator, k)
            )
            recommendedItems = [record['iid'] for record in cur.fetchall()]

            # close cursor and commit changes
            cur.close()
            self.db_conn.commit()

            # if the customer has bought all the recommended items,
            # return the generic recommendations
            if recommendedItems == []:
                return self.recommend_generic(k)

            # otherwise, return the recommended items 
            return recommendedItems
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
            # set up cursor
            cur = self.db_conn.cursor(cursor_factory=psycopg2.extras.DictCursor)

            # drop intermediate view and purge effected tables
            cur.execute("DROP VIEW IF EXISTS ItemQuantitiesBought;")
            cur.execute("DELETE FROM PopularItems;")
            cur.execute("DELETE FROM DefinitiveRatings;")

            # for each item, get its category and total quantity bought
            cur.execute(
                """
                CREATE VIEW ItemQuantitiesBought AS
                SELECT Item.IID, Item.category, sum(quantity) as bought
                FROM Item JOIN LineItem ON Item.IID = LineItem.IID
                GROUP BY Item.IID;
                """
            )

            # get the top 2 most bought items in each category
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

            # get the curators' ratings on these popular items
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

            # close cursor and commit changes
            cur.close()
            self.db_conn.commit()
            
            # return success code
            return 0
            pass
        except pg.Error:
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
        #print(rec.recommend_generic(2))
        rec.disconnect_db()
    else: 
        print("hello jaak")
        # TODO: Change this to connect to your own database:
        #rec.connect_db("csc343h-subeeth1", "subeeth1", "")
        rec.connect_db("csc343h-chaud496", "chaud496", "")
        # TODO: Test one or more methods here.
        print(rec.repopulate())
        print(rec.recommend(1599, 2))
        rec.disconnect_db()
    

if __name__ == '__main__':
    # TODO: Put your testing code here, or call testing functions such as
    # this one:
    sample_testing_function()
