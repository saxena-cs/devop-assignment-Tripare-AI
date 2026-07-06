INSERT INTO hotel_bookings (
    id,
    org_id,
    hotel_id,
    city,
    checkin_date,
    checkout_date,
    amount,
    status,
    created_at
)
SELECT
    gen_random_uuid(),
    CASE
        WHEN gs % 4 = 0 THEN '11111111-1111-1111-1111-111111111111'::uuid
        WHEN gs % 4 = 1 THEN '22222222-2222-2222-2222-222222222222'::uuid
        WHEN gs % 4 = 2 THEN '33333333-3333-3333-3333-333333333333'::uuid
        ELSE '44444444-4444-4444-4444-444444444444'::uuid
    END,
    CONCAT('HOTEL-', (gs % 10) + 1),
    CASE
        WHEN gs % 5 = 0 THEN 'delhi'
        WHEN gs % 5 = 1 THEN 'mumbai'
        WHEN gs % 5 = 2 THEN 'bangalore'
        WHEN gs % 5 = 3 THEN 'pune'
        ELSE 'hyderabad'
    END,
    CURRENT_DATE + ((gs % 20) || ' days')::interval,
    CURRENT_DATE + (((gs % 20) + 2) || ' days')::interval,
    ROUND((1000 + random() * 15000)::numeric, 2),
    CASE
        WHEN gs % 4 = 0 THEN 'confirmed'
        WHEN gs % 4 = 1 THEN 'cancelled'
        WHEN gs % 4 = 2 THEN 'pending'
        ELSE 'completed'
    END,
    NOW() - ((gs % 60) || ' days')::interval
FROM generate_series(1, 120) AS gs;

INSERT INTO booking_events (
    booking_id,
    event_type,
    payload,
    created_at
)
SELECT
    id,
    'booking_created',
    jsonb_build_object(
        'source', 'seed_script',
        'city', city,
        'status', status
    ),
    created_at
FROM hotel_bookings
WHERE id IN (
    SELECT id
    FROM hotel_bookings
    ORDER BY created_at DESC
    LIMIT 60
);

INSERT INTO booking_events (
    booking_id,
    event_type,
    payload,
    created_at
)
SELECT
    id,
    'payment_updated',
    jsonb_build_object(
        'amount', amount,
        'payment_status', CASE WHEN status = 'confirmed' THEN 'paid' ELSE 'not_paid' END
    ),
    created_at + INTERVAL '1 hour'
FROM hotel_bookings
WHERE status IN ('confirmed', 'completed')
LIMIT 40;
