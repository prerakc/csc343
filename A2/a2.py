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
            # TODO: Complete this method.
            pass
        except pg.Error:
            return None

    def recommend(self, cust: int, k: int) -> Optional[list[int]]:
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
            # TODO: Complete this method.
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
    rec = Recommender()
    # TODO: Change this to connect to your own database:
    rec.connect_db("csc343h-dianeh", "dianeh", "")
    # TODO: Test one or more methods here.


if __name__ == '__main__':
    # TODO: Put your testing code here, or call testing functions such as
    # this one:
    sample_testing_function()
