

# ============================================================
# STEP 1 - IMPORT LIBRARIES
# ============================================================

import random

import numpy as np

import pandas as pd

from faker import Faker
# ============================================================
# STEP 2 - FAKE CONFIGURATION
# ============================================================

fake = Faker("en_IN")

random.seed(100)

np.random.seed(100)

Faker.seed(100)


# ============================================================
# STEP 3 - TOTAL DATA
# ============================================================

TOTAL_RETURNS = 150000


# ============================================================
# STEP 4 - RETURN ID GENERATOR
# ============================================================

def generate_return_id(number):

    return f"RET{number:09d}"


# ============================================================
# STEP 5 - READ ORDERS
# ============================================================

order_df = pd.read_csv(

    "../../data/raw/orders.csv"

)


# ============================================================
# STEP 6 - READ ORDER ITEMS
# ============================================================

order_item_df = pd.read_csv(

    "../../data/raw/order_items.csv"

)


# ============================================================
# STEP 7 - READ PRODUCTS
# ============================================================

product_df = pd.read_csv(

    "../../data/raw/products.csv"

)

# ============================================================
# STEP 8 - CONVERT ORDER DATE
# ============================================================

order_df["order_date"] = pd.to_datetime(

    order_df["order_date"],

    errors="coerce" #Pandas can throw an error when it encounters an invalid date.

)
# step 9 - valid orders
valid_order_df=order_df[order_df["order_id"].notna()].copy()

# step 10 - valid order items
valid_order_item_df=order_item_df[order_item_df["order_id"].notna()
        &

         order_item_df["product_id"].notna()].copy()

# valid products step 11
valid_product_df=product_df[product_df["product_id"].notna()].copy()

# remove deduplicate ids
valid_order_df=valid_order_df.drop_duplicates(subset=["order_id"])

# step 13 - remove duplicate order/product pairs

valid_order_item_df=valid_order_item_df.drop_duplicates(
    subset=["order_id","product_id"]
)

# step 14 - order lookup

order_lookup = (
    valid_order_df.set_index("order_id")
[[
    "customer_id","order_date","order_status"
]].to_dict(
    orient="index"
)

)
# product lookeup step 15
product_lookup=(
    valid_product_df.drop_duplicates(subset=["product_id"])
    .set_index(
        "product_id"
    )[[
        "product_name","category","subcategory","brand","selling_price"
    ]].to_dict(orient="index")
)


# ============================================================
# STEP 16 - BUILD ORDER → PRODUCT LOOKUP
#
# This guarantees that a returned product actually
# belongs to the selected order.
# ============================================================

order_product_lookup = {}


for row in valid_order_item_df.itertuples(

    index=False

):

    order_id = row.order_id

    product_id = row.product_id


    if order_id not in order_lookup:

        continue


    if product_id not in product_lookup:

        continue


    if order_id not in order_product_lookup:

        order_product_lookup[

            order_id

        ] = []


    order_product_lookup[

        order_id

    ].append(

        product_id

    )


# ============================================================
# STEP 17 - RETURNABLE ORDERS
#
# We mainly choose orders that reached the customer.
# ============================================================

RETURNABLE_STATUSES = [

    "Delivered",

    "Completed",

    "Returned"

]


returnable_orders = [

    order_id

    for order_id in order_product_lookup

    if order_lookup[

        order_id

    ][

        "order_status"

    ] in RETURNABLE_STATUSES

]
from utils.mapping import (
    RETURN_REASONS,RETURN_CONDITIONS,RETURN_STATUSES,REFUND_METHODS
)

# STEP 23 - ROWS
rows=[]

for i in range(1,TOTAL_RETURNS + 1):
    return_id  = generate_return_id(i)
    order_id=random.choice(returnable_orders)
    order_info = order_lookup[order_id]
    customer_id = order_info["customer_id"]
    order_date = order_info["order_date"]
    order_status = order_info["order_status"]
    product_id = random.choice(order_product_lookup[order_id])
    product_info = product_lookup[product_id]
    # PRODUCT PRICE
    # --------------------------------------------------------

    selling_price = product_info[

        "selling_price"

    ]

    if pd.isna(selling_price):
        selling_price = 500.00
    # RETURN QUANTITY
    # --------------------------------------------------------

    return_quantity = random.randint(

        1,

        3

    )

    return_reason = random.choices(
        RETURN_REASONS,
        weights=[10,8,15,12,8,6,10,12,5,3,4,7]
    )[0]

    return_condition = random.choice(RETURN_CONDITIONS)
#     RETURN DATE
    if pd.isna(order_date):
        return_date = pd.Timestamp.today()
    else:
        return_date = (
            order_date  + pd.Timedelta(
            days=random.randint(3,30)
        )
        )

    return_status = random.choices(
        RETURN_STATUSES,
        weights=[10,15,5,10,15,20,25]
    )[0]

    refund_amount =  round(abs(selling_price) * return_quantity,2)
    refund_method = random.choice(
        REFUND_METHODS
    )

    #refund date
    if return_status in ["Completed","Refunded"]:
        refund_date = (
            return_date + pd.Timedelta(days=random.randint(1,7))
        )
    else:
        refund_date= pd.NaT

    if return_condition in ["New","Opened"]:
        restock_flag = random.choices(
            [True,False],
            weights=[80,20]
        )[0]
    else:
        restock_flag = random.choices(
            [True,False],
            weights=[
                20,80
            ]
        )[0]

  # --------------------------------------------------------
    # RETURN RECORD
    # --------------------------------------------------------

    return_record = {

        "return_id": return_id,

        "order_id": order_id,

        "customer_id": customer_id,

        "product_id": product_id,

        "return_date": return_date,

        "return_quantity": return_quantity,

        "return_reason": return_reason,

        "return_condition": return_condition,

        "return_status": return_status,

        "refund_amount": refund_amount,

        "refund_method": refund_method,

        "refund_date": refund_date,

        "restock_flag": restock_flag

    }


    # --------------------------------------------------------
    # APPEND
    # --------------------------------------------------------

    rows.append(return_record)


# ============================================================
# STEP 25 - CREATE DATAFRAME
# ============================================================

return_df = pd.DataFrame(rows)

# duplicate rows
duplicate_rows=return_df.sample(500,random_state=100)
return_df=pd.concat([return_df,duplicate_rows],ignore_index=True)

# null order is

null_order_id=random.sample(range(len(return_df)),1000)
return_df.loc[null_order_id,"order_id"]=None

# invalid order id

ioi=random.sample(range(len(return_df)),1200)
return_df.loc[ioi,"order_id"]=[random.choice(
    ["ORD99999999","INVALID_ORDER","ORDER!@#"]
)
for _ in ioi
]
# null return reasons

null_rr=random.sample(range(len(return_df)),1500)
return_df.loc[null_rr,"return_reason"]=None

# invalid return reraason

irr=random.sample(range(len(return_df)),400)
return_df.loc[irr,"return_reason"]=[random.choice(
    ["Unknown","RAte kamin zalay","timepass"]
)
    for _ in irr

]

# invalid return quantity
rq=random.sample(range(len(return_df)),1100)
return_df.loc[rq,"return_quantity"]=0

# zero refund
rq=random.sample(range(len(return_df)),900)
return_df.loc[rq,"refund_amount"]=0
# invalid return method

irm=random.sample(range(len(return_df)),400)
return_df.loc[irm,"refund_method"]=[random.choice(
    ["Unknown","cheque","phonepe"]
)
    for _ in irm
]

# extra spaces

es=random.sample(range(len(return_df)),2000)
for r in es:
    if pd.notna(
        return_df.loc[r,"return_reason"]):
        return_df.loc[r,"return_reason"] = ("  " + str(return_df.loc[r,"return_reason"]) + "  "

)

return_df.to_csv("../../data/raw/returns.csv",index=False)
print("Return Generated Suuccessfully")
print("Total records : ",len(return_df))




