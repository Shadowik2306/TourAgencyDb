DROP TRIGGER IF EXISTS checkDate on tours;
DROP FUNCTION IF EXISTS checkDate();
CREATE OR REPLACE FUNCTION checkDate() RETURNS TRIGGER AS $$
    BEGIN
        if new.data_start > new.data_end then
            RAISE EXCEPTION 'Dates are incorrect';
        end if;
        RETURN new;
    end;
$$ language plpgsql;


CREATE TRIGGER checkDate
BEFORE INSERT OR UPDATE ON tours
FOR EACH ROW EXECUTE PROCEDURE checkDate();


DROP TRIGGER IF EXISTS checkPrice on tours_info;
DROP FUNCTION IF EXISTS checkPrice();
CREATE OR REPLACE FUNCTION checkPrice() RETURNS TRIGGER AS $$
    BEGIN
        if new.price <= 0 THEN
            RAISE EXCEPTION 'Price must be more then 0';
        end if;
        RETURN NEW;
    end;
$$ language plpgsql;


CREATE TRIGGER checkPrice BEFORE INSERT OR UPDATE ON tours_info
FOR EACH ROW EXECUTE PROCEDURE checkPrice();


DROP TRIGGER IF EXISTS checkAccountUser on users;
DROP TRIGGER IF EXISTS checkAccountCompany on companies;
DROP FUNCTION IF EXISTS checkAccount();
CREATE OR REPLACE FUNCTION checkAccount() RETURNS TRIGGER AS $$
    BEGIN
        if (new.email !~ '[a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+')  then
                RAISE EXCEPTION 'Email is incorrect';
        end if;
        RETURN NEW;
    end;
$$ language plpgsql;


CREATE TRIGGER checkAccountCompany
BEFORE INSERT OR UPDATE ON companies
FOR EACH ROW EXECUTE PROCEDURE checkAccount();

CREATE TRIGGER checkAccountUser
BEFORE INSERT OR UPDATE ON users
FOR EACH ROW EXECUTE PROCEDURE checkAccount();


DROP TRIGGER IF EXISTS checkDiscount on tours_statuses;
DROP FUNCTION IF EXISTS checkDiscount();
CREATE OR REPLACE FUNCTION checkDiscount() RETURNS TRIGGER AS $$
    BEGIN
        if new.discount <= 0 OR new.discount > 100 THEN
            RAISE EXCEPTION 'DISCOUNT MUST BE IN RANGE FROM 1 TO 100';
        end if;
        RETURN NEW;
    end;
$$ language plpgsql;


CREATE TRIGGER checkDiscount
BEFORE INSERT OR UPDATE ON tours_statuses
FOR EACH ROW EXECUTE PROCEDURE checkDiscount();


DROP TRIGGER IF EXISTS checkRating on user_tours;
DROP FUNCTION IF EXISTS checkRating();
CREATE OR REPLACE FUNCTION checkRating() RETURNS TRIGGER AS $$
    BEGIN
        if (new.rating is not null) AND (new.rating < 1 OR new.rating > 10) THEN
            RAISE EXCEPTION 'New rating is incorrect';
        end if;
        RETURN NEW;
    end;
$$ language plpgsql;


CREATE TRIGGER checkRating
BEFORE INSERT OR UPDATE ON user_tours
FOR EACH ROW EXECUTE PROCEDURE checkRating();


DROP TRIGGER IF EXISTS deleteUselessUserBuys on user_tours;
DROP FUNCTION IF EXISTS checkUselessInfo();
CREATE OR REPLACE FUNCTION checkUselessInfo() RETURNS TRIGGER AS $$
    BEGIN
        raise info '%', old.rating;
        if old.rating is not null THEN
            RAISE EXCEPTION 'THIS ROW HAVE RATING. IT EFFECTS ON RATING';
        end if;
        RETURN OLD;
    end;
$$ language plpgsql;


CREATE TRIGGER deleteUselessUserBuys
BEFORE DELETE ON user_tours
FOR EACH ROW EXECUTE PROCEDURE checkUselessInfo();
