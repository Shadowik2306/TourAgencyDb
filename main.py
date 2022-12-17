import random
import datetime

import psycopg2 as ps
from mimesis import Person, Address
from mimesis.enums import Gender
import lorem

conn = ps.connect(
    host="localhost",
    database="TourAgency",
    user="postgres",
    password="123$qaz"
)


cur = conn.cursor()

for item in "Student_Pensioner_Veteran_Liquidator_Disabled 1_Pupil_Large Family".split('_'):
    cur.execute(f"INSERT INTO statuses (name) VALUES ('{item}')")

for item in "Plane_Ship_Train_Bus".split('_'):
    cur.execute(f"INSERT INTO type_transport (name) VALUES ('{item}')")

for i in range(50):
    pr = Person('en')
    command = "INSERT INTO transport_company VALUES (DEFAULT, '{}', {})".format(pr.username('U'), random.randint(1, 4))
    cur.execute(command)
conn.commit()


for i in range(1000):
    pr = Person('en')
    command = "INSERT INTO users (first_name, second_name, email, password) VALUES " \
              "('{}'," \
              "'{}'," \
              "'{}'," \
              "'{}')".format(pr.name(gender=Gender.MALE if pr == 0 else Gender.FEMALE),
                               pr.surname(gender=Gender.MALE  if pr == 0 else Gender.FEMALE).replace("'", '"'),
                               pr.email(),
                               pr.password().replace("'", ''))
    cur.execute(command)
    conn.commit()
    if random.randint(1, 10) > 8:
        id_status = random.randint(1, 7)
        command = f"INSERT INTO user_statuses VALUES ({i + 1}, {id_status})"
        cur.execute(command)
        if random.randint(1, 10) > 9:
            id_statusg = random.randint(1, 7)
            if (id_statusg != id_status):
                command = f"INSERT INTO user_statuses VALUES ({i + 1}, {id_statusg})"
                cur.execute(command)
            conn.commit()

for i in range(500):
    pr = Person('en')
    nickname = pr.username("U")
    email = pr.email()
    password = pr.password().replace("'", '"')

    command = f"INSERT INTO companies VALUES (DEFAULT, '{nickname}', '{email}', '{password}')"
    cur.execute(command)

places = ['Гонконг, Китай', 'Бангкок, Таиланд', 'Лондон, Великобритания', 'Сингапур', 'Макао, Китай',
          'Дубай, Объединенные Арабские Эмираты', 'Париж, Франция', 'Нью-Йорк, США', 'Шэньчжэнь, Китай',
          ' Куала-Лумпур, Малайзия', ' Пхукет, Таиланд', ' Рим, Италия', ' Токио, Япония', ' Тайбэй, Китай',
          ' Стамбул, Турция', ' Сеул, Южная Корея', ' Гуанчжоу, Китай', ' Прага, Чехия', ' Мекка, Саудовская Аравия',
          ' Майами, США', ' Дели, Индия', ' Мумбаи, Индия', ' Барселона, Испания', ' Паттайя, Таиланд',
          ' Шанхай, Китай', ' Лас-Вегас, США', ' Милан, Италия', ' Амстердам, Нидерланды', ' Анталия, Турция',
          ' Вена, Австрия', ' Лос-Анджелес, США', ' Канкун, Мексика', ' Осака, Япония', ' Берлин, Германия',
          ' Агра, Индия', ' Хошимин, Вьетнам', ' Йоханнесбург, Южная Африка', ' Венеция, Италия', ' Мадрид, Испания',
          ' Орландо, США', ' Эр-Рияд, Саудовская Аравия', ' Джохор Бахру, Малайзия',
          ' Дублин, Ирландия', ' Флоренция, Италия', ' Ченнаи, Индия', ' Москва, Россия',
          ' Афины, Греция', ' Джайпур, Индия', ': Пекин, Китай', ' Денпасар, Индонезия',
          ' Торонто, Канада', ' Ханой, Вьетнам', ' Сидней, Австралия', ' Сан-Франциско, США',
          ' Будапешт, Венгрия', ' Ха Лонг, Вьетнам', ' Пунта Кана, Доминиканская Республика',
          ' Даммам Сити, Саудовская Аравия', ' Мюнхен, Германия', ' Чжухай, Китай', ' Лиссабон, Португалия',
          ' Каир, Египет', ' Остров Пенанг, Малайзия', ' Доха, Катар', ' Копенгаген, Дания', ' Ираклион, Греция',
          ' Иерусалим, Израиль', ' Эдирне, Турция', ' Пномпень, Камбоджа', ' Санкт-Петербург, Россия',
          ' Чеджу, Южная Корея', ' Киото, Япония', ' Чиангмай, Таиланд', ' Варшава, Польша', ' Краков, Польша',
          ' Гонолулу, США', ' Мельбурн, Австралия', ' Тель-Авив, Израиль', ' Марракеш, Марокко', ' Брюссель, Бельгия',
          ' Окленд, Новая Зеландия', ' Ванкувер, Канада', ' Джакарта, Индонезия', ' Франкфурт, Германия',
          ' Артвин, Турция', ' Гуйлинь, Китай', ' Стокгольм, Швеция', ' Рио-де-Жанейро, Бразилия', ' Калькутте, Индия',
          ' Буэнос-Айрес, Аргентина', ' Тиба, Япония', ' Сием-Рип, Камбоджа', ' Ницца, Франция', ' Мехико, Мексика',
          ' Лима, Перу', ' Тайчжун, Тайвань', ' Родос, Греция', ' Вашингтон, округ Колумбия, США',
          ' Абу-Даби, Объединенные Арабские Эмираты', '0 Коломбо, Шри-Ланка']

for i in range(3000):
    place = random.choice(places)[1:].split(', ')
    city = place[0]
    try:
        county = place[1]
    except Exception:
        county = None

    description = lorem.paragraph().replace(random.choice(lorem.paragraph()), " " + city + " ", 5) if random.randint(0, 10) > 3 else None
    if (description is not None) and (county is not None):
        description.replace(random.choice(lorem.paragraph()), " " + county + " ", 5)

    command = "INSERT INTO tours_info VALUES (DEFAULT," \
              "'{}'," \
              "{}," \
              "'{}'," \
              "'{}'," \
              "{}, {})".format(", ".join(place), random.randint(50000, 1000000), description,
                                "image.img" if random.randint(0, 10) > 3 else None, random.randint(1, 500), random.randint(1, 50))

    cur.execute(command)
    conn.commit()
    if random.randint(1, 10) > 8:
        id_status = random.randint(1, 7)
        discount = random.randint(5, 20)
        command = f"INSERT INTO tours_statuses VALUES ({i + 1}, {id_status}, {discount})"
        cur.execute(command)
        if random.randint(1, 10) > 9:
            id_statusg = random.randint(1, 7)
            if (id_statusg != id_status):
                discount = random.randint(5, 20)
                command = f"INSERT INTO tours_statuses VALUES ({i + 1}, {id_statusg}, {discount})"
                cur.execute(command)
            conn.commit()


for i in range(3000):
    id_tour = random.randint(1, 3000)
    real_date = datetime.datetime.now()
    start_date = real_date + datetime.timedelta(days=random.randint(-720, 720))
    end_date = start_date + datetime.timedelta(days=random.randint(5, 30))
    pr = Address()
    city = pr.city().replace("'", '"')
    command = f"INSERT INTO tours VALUES (DEFAULT, '{start_date}', '{end_date}', '{city}', {random.randint(50, 120)}, {id_tour})"
    cur.execute(command)
    conn.commit()
    if random.randint(1, 10) > 6:
        id_user = random.randint(1, 1000)
        rating = random.randint(1, 10) if random.randint(1, 10) > 4 else 'null'
        command = f"INSERT INTO user_tours VALUES ({id_user}, {i + 1}, '{start_date - datetime.timedelta(days=random.randint(-30, -10))}', {rating})"
        cur.execute(command)
        conn.commit()





conn.commit()

