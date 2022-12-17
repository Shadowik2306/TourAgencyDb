DROP FUNCTION IF EXISTS get_Tours_With_Discount(user_id int);
CREATE OR REPLACE FUNCTION get_Tours_With_Discount(user_id int)
    RETURNS TABLE (id_tour int, name_tour varchar, date_start date, date_end date, discount int, price int) AS
$$
    DECLARE
        status_user INTEGER := (SELECT id_statuses FROM user_statuses WHERE id_user = user_id);
    BEGIN
        if (status_user is null) then
            RAISE WARNING 'User % doesn`t have statuses', user_id;
            RETURN NEXT;
        end if;
        RETURN QUERY
            SELECT t.id, ti.name, t.data_start, t.data_end, MAX(ts.discount), (ti.price / 100) * (100 - MAX(ts.discount))
                FROM tours t
                JOIN tours_info ti on ti.id = t.id_tour_info
                JOIN tours_statuses ts on ti.id = ts.id_tour
                WHERE ts.id_statuses IN (status_user)
                AND now() < data_start
                GROUP BY t.id, ti.name, ti.price;
    end;
$$ language plpgsql;


-- SELECT * FROM get_Tours_With_Discount(5);

DROP FUNCTION IF EXISTS get_Price_Of_Tour(user_id int, tour_id int);
CREATE OR REPLACE FUNCTION get_Price_Of_Tour(user_id int, tour_id int)
    RETURNS numeric AS
$$
    DECLARE
        res numeric;
    BEGIN
        res = (SELECT (ti.price / 100) * (100 - MAX(ts.discount)) FROM tours
            JOIN tours_info ti on ti.id = tours.id_tour_info
            LEFT JOIN tours_statuses ts on ti.id = ts.id_tour
            WHERE tours.id = tour_id
            GROUP BY ti.price);
        RETURN res;
    end;
$$ language plpgsql;


-- SELECT get_Price_Of_Tour(5, 10);

DROP FUNCTION IF EXISTS get_Free_Places(id_tour int);
CREATE OR REPLACE FUNCTION get_Free_Places(id_tour int) RETURNS INTEGER AS
$$
    BEGIN
        return (SELECT free_places FROM tours WHERE id = id_tour) -
                      (SELECT count(userid) FROM user_tours WHERE tourid = id_tour);
    end;
$$ language plpgsql;


-- SELECT get_Free_Places(5);




