# ============================================================
# E-COMMERCE DATA WAREHOUSE
# CUSTOMER DATA GENERATOR
# ============================================================
import random

import pandas as pd

from faker import Faker
from datetime import timedelta

# ============================================================
# STEP 1 - CONFIGURATION
# ============================================================

TOTAL_CUSTOMERS = 500000
random.seed(100)
Faker.seed(100)

fake = Faker("en_IN")



# ============================================================
# STEP 2 - CUSTOMER SEGMENTS
# ============================================================

customer_segments = [
    "Bronze",
    "Silver",
    "Gold",
    "Platinum"
]

city_weights = {
    "Maharashtra": [30, 25, 15, 5, 10, 5, 6, 4],
    "Karnataka": [60, 15, 15, 10],
    "Gujarat": [40, 25, 20, 15],
    "Tamil Nadu": [50, 20, 15, 15],
    "Delhi": [70, 30],
    "Rajasthan": [45, 20, 20, 15],
    "Uttar Pradesh": [35, 20, 15, 15, 15],
    "West Bengal": [60, 20, 20],
    "Punjab": [40, 25, 20, 15],
    "Telangana": [60, 15, 15, 10]
}
# ============================================================
# STEP 3 - STATE → CITY MAPPING
# ============================================================
from utils.mapping import (
    state_city_map
)

#  customer id generator

def generate_customer_id(number):
    return f"CUST{number:06d}"

customer_status=["Active","Inactive"]

genders=["Male","Female"]


rows=[]

# ==================================
# step 9 - generate customer records
# ==========================

for i in range(1, TOTAL_CUSTOMERS + 1):

    customer_id=generate_customer_id(i)

    gender=random.choices(genders,
                          weights=[60,40])[0]

    if gender=="Male":
        first_name=fake.first_name_male()
    else:
        first_name=fake.first_name_female()

    last_name=fake.last_name()

    dob=fake.date_of_birth(
        minimum_age=18,
        maximum_age=80
    )

    # --------------------------------------------------------
    # registration date
    #
    # Customer should register after becoming an adult.
    # --------------------------------------------------------

    registration_date = fake.date_between(
        start_date=dob + timedelta(days= 5*30),
        end_date="today"
    )

    created_at=registration_date
    updated_at=fake.date_between(
        start_date=created_at,
        end_date="today"
    )
    state=random.choices(list(state_city_map.keys()),
             weights=[20,15,10,5,6,7,12,8,10,7])[0]

    city=random.choices(state_city_map[state], weights=city_weights[state])[0]



    country="India"

    postal_code=fake.postcode()
    phone=str(random.randint(6000000000,9999999999))

    email=(first_name+last_name+str(i)+"@gmail.com").lower()

    status=random.choices(
        customer_status,weights=[80,20]
    )[0]

    customer_segment=random.choices(
        customer_segments,weights=[40,30,20,10]
    )[0]

    customer= {
        "customer_id":customer_id,
        "first_name": first_name,

        "last_name": last_name,

        "gender": gender,

        "date_of_birth": dob,

        "phone_number": phone,

        "email": email,

        "address": fake.street_address(),

        "city": city,

        "state": state,

        "country": country,

        "postal_code": postal_code,

        "registration_date": registration_date,

        "customer_status": status,

        "customer_segment": customer_segment,

        "created_at": created_at,

        "updated_at": updated_at
    }

    # append
    rows.append(customer)

customer_df=pd.DataFrame(rows)

# step 11 - dirty date


print("Adding dirty date")

# duplicate customer records

duplicate_rows=customer_df.sample(1500,random_state=100)

customer_df=pd.concat([customer_df,duplicate_rows],ignore_index=True)


# null email
rows=random.sample(range(len(customer_df)),2000)
customer_df.loc[rows,"email"]=None

# blank email
rows=random.sample(range(len(customer_df)),2000)
customer_df.loc[rows,"email"]=""

#  invalid emails
bad_emails = [
    "abcgmail.com",
    "test@",
    "@gmail.com",
    "customer.com",
    "invalid-email"
]


rows = random.sample(
    range(
        len(customer_df)
    ),
    2000
)


customer_df.loc[
    rows,
    "email"
] = random.choice(
    bad_emails
)

print(customer_df["email"].dtype)

# blank city
rows=random.sample(range(len(customer_df)),2500)
customer_df.loc[rows,"city"]=""

print(customer_df["phone_number"].dtype)
bad_phone=["!@#$%^","123456","abcdefg",1234432,"sdaflkj932u4"]
rows=random.sample(range(len(customer_df)),2000)
customer_df.loc[rows,"phone_number"]= random.choice(bad_phone)

#  ectra spaces in first name

rows=random.sample(range(len(customer_df)),2000)
customer_df.loc[rows,"first_name"]=("  "+str(customer_df.loc[rows,"first_name"] )+ "  ")

# ectra spaces in last_name

rows=random.sample(range(len(customer_df)),2000)
customer_df.loc[rows,"last_name"]=("  "+ customer_df.loc[rows,"last_name"].astype(str)+ "  ")

# uppde case

case=random.sample(range(len(customer_df)),2000)
customer_df.loc[case,"state"]= (customer_df.loc[case,"state"]).astype(str).str.upper()
# blank customer segment
blank_rows=random.sample(range(len(customer_df)),2000)
customer_df.loc[blank_rows,"customer_segment"]=""

# save csv
customer_df.to_csv("../../data/raw/customers.csv",index=False)

print("Customers Generated Successfully")



# step 13 - validation
# ============================================================

print(
    "\nCustomers Generated Successfully"
)

print(
    f"Total Rows : "
    f"{len(customer_df):,}"
)

print(
    f"Unique Customer IDs : "
    f"{customer_df['customer_id'].nunique():,}"
)

