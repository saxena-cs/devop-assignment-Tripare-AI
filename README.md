# devop-assignment-Tripare-AI
Tripare AI assignment 

The main query filters by city and created_at, then groups by org_id and status while calculating SUM(amount).

Index used:

CREATE INDEX idx_hotel_bookings_city_created_org_status
ON hotel_bookings (city, created_at, org_id, status)
INCLUDE (amount);

Reason:
- city is used as an equality filter.
- created_at is used as a range filter for the last 30 days.
- org_id and status are used in GROUP BY.
- amount is included to help PostgreSQL read the aggregate value from the index where possible.
