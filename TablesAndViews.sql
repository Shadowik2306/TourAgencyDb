DROP VIEW IF EXISTS All_Tours, Real_Tours;

DROP TABLE IF EXISTS users, companies, tours, tours_info,
    User_Tours, Statuses, Tours_Statuses, User_Statuses, type_transport, transport_company;

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR NOT NULL,
    second_name VARCHAR NOT NULL,
    email VARCHAR NOT NULL UNIQUE,
    password VARCHAR NOT NULL
);

CREATE TABLE companies (
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    email VARCHAR NOT NULL,
    password VARCHAR NOT NULL
);

CREATE TABLE type_transport(
  id SERIAL PRIMARY KEY,
  name varchar
);


CREATE TABLE transport_company(
  id SERIAL PRIMARY KEY,
  name varchar,
  id_type INTEGER REFERENCES type_transport(id) ON DELETE CASCADE
);

CREATE TABLE tours_info (
  id SERIAL PRIMARY KEY,
  name varchar NOT NULL,
  price integer NOT NULL,
  description varchar,
  image varchar,
  id_company INTEGER REFERENCES companies(id) ON DELETE CASCADE,
  id_transport INTEGER REFERENCES transport_company(id) ON DELETE CASCADE
);

CREATE TABLE tours (
    id SERIAL PRIMARY KEY,
    data_start date NOT NULL,
    data_end date NOT NULL,
    country_start varchar NOT NULL,
    free_places INTEGER NOT NULL,
    id_tour_info INTEGER REFERENCES tours_info(id) ON DELETE CASCADE
);

CREATE TABLE User_Tours (
    UserID INTEGER REFERENCES users(id) ON DELETE CASCADE,
    TourID INTEGER REFERENCES tours(id) ON DELETE CASCADE,
    Date_Of_Creation timestamp DEFAULT now(),
    Rating int,
    PRIMARY KEY (UserID, TourID)
);

CREATE TABLE Statuses (
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL UNIQUE
);

CREATE TABLE Tours_Statuses (
    id_tour INTEGER REFERENCES tours_info(id) ON DELETE CASCADE,
    id_statuses INTEGER REFERENCES Statuses(id) ON DELETE CASCADE,
    discount integer NOT NULL,
    PRIMARY KEY (id_tour, id_statuses)
);

CREATE TABLE User_Statuses (
    id_user INTEGER REFERENCES users(id) ON DELETE CASCADE,
    id_statuses INTEGER REFERENCES Statuses(id) ON DELETE CASCADE,
    PRIMARY KEY (id_user, id_statuses)
);


DROP SEQUENCE IF EXISTS tour_info_seq, tour_seq, user_seq, companies_seq, status_seq, type_tr_seq, tr_company;
CREATE SEQUENCE tour_info_seq START WITH 1 INCREMENT BY 1 OWNED BY tours_info.id;
CREATE SEQUENCE tour_seq START WITH 1 INCREMENT BY 1 OWNED BY tours.id;
CREATE SEQUENCE user_seq START WITH 1 INCREMENT BY 1 OWNED BY users.id;
CREATE SEQUENCE companies_seq START WITH 1 INCREMENT BY 1 OWNED BY companies.id;
CREATE SEQUENCE status_seq START WITH 1 INCREMENT BY 1 OWNED BY statuses.id;
CREATE SEQUENCE type_tr_seq START WITH 1 INCREMENT BY 1 OWNED BY type_transport.id;
CREATE SEQUENCE tr_company START WITH 1 INCREMENT BY 1 OWNED BY transport_company.id;


CREATE OR REPLACE VIEW All_Tours AS
    SELECT tu.id, tu.name tour_name, c.name company_name, tc.name transport_name, tt.name type_transport,
           count(UT.Rating) Count_ratings, avg(UT.Rating)
    FROM tours_info tu
    JOIN companies c on c.id = tu.id_company
    JOIN transport_company tc on tc.id = tu.id_transport
    JOIN type_transport tt on tt.id = tc.id_type
    FULL OUTER JOIN tours t on tu.id = t.id_tour_info
    JOIN User_Tours UT on t.id = UT.TourID
    GROUP BY tu.id, tu.name, c.name, tc.name, tt.name
    ORDER BY tu.id;


CREATE OR REPLACE VIEW Real_Tours AS
    SELECT t.id, ti.name, c.name company_name, t.free_places places, data_start, data_end, ti.description, ti.image, price
    FROM tours t
    JOIN tours_info ti on ti.id = t.id_tour_info
    JOIN companies c on c.id = ti.id_company
    JOIN User_Tours UT on t.id = UT.TourID
