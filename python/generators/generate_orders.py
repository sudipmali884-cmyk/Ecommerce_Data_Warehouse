import random,pandas as pd
from faker import  Faker
fake=Faker("en_IN")
random.seed(100)
Faker.seed(100)

TOTAL_ORDERS=500000

# STEP-4 ORDER ID
def generate_order_id(number):
    return f"ORD{number:08d}"

# step 5 - read customers
customer_df=pd.read_csv("../../data/raw/customers.csv");

# ============================================================
# STEP 6 - CONVERT DATE
# ============================================================

customer_df["registration_date"] = pd.to_datetime(

    customer_df["registration_date"],

    errors="coerce"

)

# ============================================================
# STEP 7 - REMOVE INVALID CUSTOMER IDs
# ============================================================

valid_customer_df = customer_df[

    customer_df["customer_id"].notna()

].copy()

# ============================================================
# STEP 8 - CUSTOMER ID LIST
# ============================================================

customer_ids = (

    valid_customer_df["customer_id"]

    .drop_duplicates()

    .tolist()

)
# step 9 - customer lookup
# We do NOT search customer_df inside every order loop.
#
# This makes generation much faster.


customer_lookup = (

    valid_customer_df

    .drop_duplicates(

        subset=["customer_id"]

    )

    .set_index(

        "customer_id"

    )[

        [

            "registration_date",

            "customer_status",

            "state",

            "city"

        ]

    ]

    .to_dict(

        orient="index"

    )

)

# ============================================================
# STEP 10 - ORDER STATUS
# ============================================================

ORDER_STATUS = [

    "Pending",

    "Confirmed",

    "Shipped",

    "Delivered",

    "Cancelled",

    "Returned"

]


# ============================================================
# STEP 11 - PAYMENT STATUS
# ============================================================

PAYMENT_STATUS = [

    "Pending",

    "Paid",

    "Failed",

    "Refunded"

]


# ============================================================
# STEP 12 - SHIPPING METHODS
# ============================================================

SHIPPING_METHODS = [

    "Standard",

    "Express",

    "Same Day",

    "Economy"

]


# ============================================================
# STEP 13 - ROWS
# ============================================================

rows = []
# step 14 - generate records

for i in range(1,TOTAL_ORDERS + 1):
    order_id=generate_order_id(i)
    customer_id=random.choice(customer_ids)

    customer_info=customer_lookup[customer_id]
    registration_date = (customer_info["registration_date"])
    customer_status=(customer_info["customer_status"])
    #order date
    order_date = fake.date_between(
        start_date=registration_date,
        end_date="today"
    )
    order_date=pd.Timestamp(order_date)

#     order status

    if customer_status=="Active":
        order_status = random.choices(
            ORDER_STATUS,
            weights=[
                3,  # Pending

                8,  # Confirmed

                10,  # Shipped

                70,  # Delivered

                6,  # Cancelled

                3  # Returned
            ]
        )[0]

    else:
        order_status=random.choices(
            ORDER_STATUS,
            weights=[
                8,  # Pending

                8,  # Confirmed

                8,  # Shipped

                50,  # Delivered

                20,  # Cancelled

                6  # Returned
            ]
        )[0]

    if order_status=="Cancelled":
        payment_status=random.choice(
            ["Failed","Refunded","Pending"]
        )

    elif order_status=="Returned":
        payment_status="Refunded"
    elif order_status=="Pending":
        payment_status=random.choice(["Pending","Paid"])
    else:
        payment_status=random.choices(
            ["Paid","Failed"],
            weights=[98,2]
        )[0]

    shipping_method = random.choices(

        SHIPPING_METHODS,

        weights=[

            50,

            20,

            5,

            25

        ]

    )[0]

    #shipping date
    if order_status in ["Shipped","Delivered","Returned"]:
        shipping_date=(
            order_date + pd.Timedelta(days=random.randint(1,8))
        )
    else:
        shipping_date= None

    # Delivary date

    if order_status in ["Delivered","Returned"]:
        delivery_date=(
            shipping_date + pd.Timedelta(
            days=random.randint(1,7)
        )
        )
    else:
        delivery_date=None

    order_subtotal = round(

        random.uniform(

            200,

            100000

        ),

        2

    )
#     shipping charge
    if shipping_method == "Same Day":
        shipping_charge = round(
            random.uniform(50,500),2
        )
    elif shipping_method=="Express":
        shipping_charge=round(random.uniform(60,200),2)
    elif shipping_method == "Standard":

        shipping_charge = round(

            random.uniform(

                40,

                150

            ),

            2

        )


    else:

        shipping_charge = round(

            random.uniform(

                20,

                80

            ),

            2

        )

        # --------------------------------------------------------
        # TAX
        # --------------------------------------------------------

    tax_amount = round(

        order_subtotal * 0.18,

        2

    )

    # --------------------------------------------------------
    # ORDER TOTAL
    # --------------------------------------------------------

    order_total = round(


        order_subtotal+
        shipping_charge

        + tax_amount,

        2
    )

    # --------------------------------------------------------
    # ORDER RECORD
    # --------------------------------------------------------

    order = {

        "order_id": order_id,

        "customer_id": customer_id,

        "order_date": order_date,

        "order_status": order_status,

        "payment_status": payment_status,

        "shipping_method": shipping_method,

        "shipping_date": shipping_date,

        "delivery_date": delivery_date,

        "shipping_charge": shipping_charge,

        "tax_amount": tax_amount,

        "order_total": order_total

    }

    # --------------------------------------------------------
    # APPEND RECORD
    # --------------------------------------------------------

    rows.append(order)

# ============================================================
# STEP 15 - CREATE DATAFRAME
# ============================================================

order_df = pd.DataFrame(rows)

# ============================================================
# STEP 16 - DIRTY DATA
# ============================================================

print(

    "Adding dirty data..."

)


# ============================================================
# 16.1 - DUPLICATE ROWS
# ============================================================

duplicate_rows = order_df.sample(

    1000,

    random_state=100

)


order_df = pd.concat(

    [

        order_df,

        duplicate_rows

    ],

    ignore_index=True

)

# null customer id

null_id=random.sample(range(len(order_df)),1000)
order_df.loc[null_id,"customer_id"]=None

# invalid customer id
in_null_id=random.sample(range(len(order_df)),1000)
order_df.loc[in_null_id,"customer_id"]=random.choice([

            "CUST999999",

            "CUSTOMER123",

            "ABC123",

            "INVALID"

        ])

#  blamk order status
dirty_rows = random.sample(

    range(

        len(order_df)

    ),

    200

)


order_df.loc[

    dirty_rows,

    "order_status"

] = ""


# invalid order stat
in_order_status=random.sample(range(len(order_df)),1000)
order_df.loc[in_order_status,"order_status"]=random.choice(["Completed",
            "Enknoen","NOT delivered "])

# null payment status
payment_rows=random.sample(range(len(order_df)),2000)
order_df.loc[payment_rows,"payment_status"]=""



# ============================================================
# 16.7 - INVALID SHIPPING METHOD
# ============================================================

dirty_rows = random.sample(

    range(

        len(order_df)

    ),

    100

)


order_df.loc[

    dirty_rows,

    "shipping_method"

] = random.choice(

    [

        "Unknown",

        "Pickup",

        "Fast Delivery"

    ]

)


order_df.to_csv(
    "../../data/raw/orders.csv"
,index=False)
print("Orders Generated Successfully")
print(f" Total Records : {len(order_df)}")
