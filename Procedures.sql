DROP PROCEDURE IF EXISTS TourBoughtByUser(user_id int, tour_id int);
CREATE OR REPLACE PROCEDURE TourBoughtByUser(user_id int, tour_id int) AS $$
DECLARE
    last_busy_days date := (SELECT MAX(t.data_end) FROM user_tours
        JOIN tours t on t.id = user_tours.tourid where userid = user_id);
    start_day_of_tour date := (SELECT data_start FROM tours WHERE id = tour_id);

BEGIN
RAISE INFO '% %', last_busy_days, start_day_of_tour;
if last_busy_days > start_day_of_tour THEN
    RAISE EXCEPTION 'USER IS BUSY IN THAT DAYS';
end if;
RAISE INFO '%', get_free_places(tour_id);
if get_free_places(tour_id) <= 0 THEN
    RAISE EXCEPTION 'NO MORE FREE PLACES';
end if;
INSERT INTO user_tours
VALUES (user_id, tour_id, now(), DEFAULT);
end;
$$ language plpgsql;

-- CALL TourBoughtByUser(16, 3002);

DROP PROCEDURE IF EXISTS makeRating(user_id int, mark int);
CREATE OR REPLACE PROCEDURE makeRating(user_id int, mark int) AS $$
    DECLARE
        tour_id int := (SELECT tourid FROM user_tours ut
        JOIN tours t on t.id = ut.tourid WHERE userid = user_id AND
                (t.data_end < now() AND extract(day FROM date_of_creation - data_end) < 30) AND ut.rating is null);
    BEGIN
        if (tour_id is null) THEN
            RAISE EXCEPTION 'Last tour is undefined or expired';
        end if;
        UPDATE user_tours ut
        SET rating = mark
        WHERE tourid = tour_id AND userid = user_id;
    end;
$$ language plpgsql;

-- call makeRating(1, 5);

DROP PROCEDURE IF EXISTS delete_bad_marks(id_tour INT, mark INT);
CREATE OR REPLACE PROCEDURE delete_bad_marks(id_tour INT, mark INT) AS $$
    BEGIN
        SET session_replication_role = replica;
        DELETE FROM user_tours ut
               WHERE ut.tourid IN (SELECT id FROM tours WHERE tours.id_tour_info = id_tour);
    end;
$$ language plpgsql;

-- call delete_bad_marks(144, 4);

