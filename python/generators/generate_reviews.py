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

TOTAL_REVIEWS = 50000


# ============================================================
# STEP 4 - REVIEW ID GENERATOR
# ============================================================

def generate_review_id(number):

    return f"REV{number:09d}"


# ============================================================
# STEP 5 - READ ORDERS
# ============================================================

order_df=pd.read_csv("../../data/raw/orders.csv")

order_item_df=pd.read_csv("../../data/raw/order_items.csv")


# ============================================================
# STEP 7 - CONVERT ORDER DATE
# ============================================================

order_df["order_date"] = pd.to_datetime(

    order_df["order_date"],

    errors="coerce"

)

# ============================================================
# STEP 8 - VALID ORDERS
# ============================================================

valid_order_df = order_df[

    order_df["order_id"].notna()

].copy()

# ============================================================
# STEP 9 - VALID ORDER ITEMS
# ============================================================

valid_order_item_df = order_item_df[

    order_item_df["order_id"].notna()

    &

    order_item_df["product_id"].notna()

].copy()

# ============================================================
# STEP 10 - REMOVE DUPLICATE ORDER IDS
# ============================================================

valid_order_df = valid_order_df.drop_duplicates(

    subset=["order_id"]

)

# step 11 - remove duplicate orde/product paiirs
valid_order_item_df=valid_order_item_df.drop_duplicates(
    subset=["order_id","product_id"]
)

# step 12 - order lookup
order_lookup = (valid_order_df.set_index("order_id")[[
    "customer_id","order_date","order_status"]
    ].to_dict(orient="index")
)




# ============================================================
# STEP 13 - BUILD PURCHASE LOOKUP
#
# order_id
#     ↓
# customer_id
# product_id
#
# This guarantees that a review is for a product
# actually present in that order.
# ============================================================

purchase_lookup = {}


for row in valid_order_item_df.itertuples(

    index=False

):

    order_id = row.order_id

    product_id = row.product_id


    if order_id not in order_lookup:

        continue


    customer_id = order_lookup[

        order_id

    ][

        "customer_id"

    ]


    if pd.isna(customer_id):

        continue


    if order_id not in purchase_lookup:

        purchase_lookup[

            order_id

        ] = []


    purchase_lookup[

        order_id

    ].append(

        product_id

    )

# step 14 - valid order list

reviewable_orders = list(
    purchase_lookup.keys()
)

# step 15 - review titles

from utils.mapping import (
    POSITIVE_TITLES,NEUTRAL_TITLES,NEGATIVE_TITLES,POSITIVE_REVIEWS,NEUTRAL_REVIEWS
    ,NEGATIVE_REVIEWS
)

# STEP 17 -verified purchase values
VERIFIED_VALUES=[
    True,False
]
# step 18 rows
rows=[]
# step 19 - generate reviews
for i in range(1, TOTAL_REVIEWS + 1):
    review_id = generate_review_id(i)

    order_id=random.choice(
        reviewable_orders
    )
    order_info = order_lookup[order_id]

    customer_id=order_info["customer_id"]

    order_date = order_info["order_date"]

    order_status=order_info["order_status"]

    product_id=random.choice(purchase_lookup[order_id])

    rating=random.choices(
        [1,2,3,4,5],
        weights=[10,20,30,25,15]
    )[0]

    if rating >=4:
        review_title=random.choice(POSITIVE_TITLES)
        review_text=random.choice(POSITIVE_REVIEWS)
    elif rating==3:
        review_title=random.choice(NEUTRAL_TITLES)
        review_text=random.choice(NEUTRAL_REVIEWS)
    else:
        review_text=random.choice(NEUTRAL_REVIEWS)
        review_title=random.choice(NEUTRAL_TITLES)

    #     review date

    if pd.isna(order_date):
        review_date = pd.Timestamp.today()
    else:
        review_date=(order_date + pd.Timedelta(
            days=random.randint(1,30)))

    #     verified purchase
    verified_purchase=True





    # --------------------------------------------------------
    # REVIEW RECORD
    # --------------------------------------------------------

    review = {

    "review_id": review_id,

    "order_id": order_id,

    "customer_id": customer_id,

    "product_id": product_id,

    "rating": rating,

    "review_title": review_title,

    "review_text": review_text,

    "review_date": review_date,

    "verified_purchase": verified_purchase,


    }
    rows.append(review)

# step 20 - create dataframe

review_df=pd.DataFrame(rows)

# ============================================================
# 21.1 - DUPLICATE REVIEWS
# ============================================================

duplicate_rows = review_df.sample(

    500,

    random_state=100

)


review_df = pd.concat(

    [

        review_df,

        duplicate_rows

    ],

    ignore_index=True

)
# ============================================================
# 21.2 - NULL ORDER IDs
# ============================================================

dirty_rows = random.sample(

    range(

        len(review_df)

    ),

    200

)


review_df.loc[

    dirty_rows,

    "order_id"

] = None

# incalid order id
invalid_order_id=random.sample(range(len(review_df)),200)
review_df.loc[invalid_order_id,"order_id"]=random.choice(
    ["oiewrufksj","34978invalid","order1234"]
)

# null customerids

null_customer_id=random.sample(range(len(review_df)),300)
review_df.loc[null_customer_id,"customer_id"]=None

# blannk review titla
blank_review=random.sample(range(len(review_df)),250)
review_df.loc[blank_review,"review_title"]=""

# extra spaces
extra_spaces=random.sample(range(len(review_df)),300)
for r in extra_spaces:
    if pd.notna(review_df.loc[r,"review_text"]):
        review_df.loc[r,"review_text"]=( "  " + str(review_df.loc[
            r,"review_text"])
                + "  "
    )

# save
review_df.to_csv("../../data/raw/review.csv",index=False)

print("Review Generated Successfully")
print("Total records : ",len(review_df))



# #Step 1 - import libraries
# import  pandas as pd
# import random
# from faker import Faker
#
# #Step 2 - Faker
# fake=Faker("en_IN")
#
# #Step 3 - Total Records
#
# TOTAL_REVIEWS = 10000
# TOTAL_CUSTOMERS=100000
# TOTAL_PRODUCTS=20000
#
# #STEP 4 - RATING DISTRIBUTION
# rating = random.choices(
#
#     [1,2,3,4,5],
#
#     weights=[5,10,15,35,35],
#
#     k=1
#
# )[0]
#
# #Step 5 - Review Tables
# titles = {
#
# 1:[
# "Very Bad",
#
# "Poor Quality",
#
# "Not Recommended",
#
# "Chuna Lagaya"
#
# ],
#
# 2:[
# "Average",
#
# "Needs Improvement",
#
# "Could Be Better"
#
# ],
#
# 3:[
# "Good",
#
# "Worth Buying",
#
# "Nice Product"
#
# ],
#
# 4:[
# "Very Good",
#
# "Excellent",
#
# "Loved It"
#
# ],
#
# 5:[
# "Outstanding",
#
# "Highly Recommended",
#
# "Best Purchase"
#
# ]
#
# }
#
# #Step 6 - review comments
# comments = {
#
# 1:[
# "Product quality is very poor.",
#
# "Completely disappointed.",
#
# "Money wasted."
#
# ],
#
# 2:[
# "Average experience.",
#
# "Expected better quality.",
#
# "Packaging was not good."
#
# ],
#
# 3:[
# "Good value for money.",
#
# "Works as expected.",
#
# "Happy with the purchase."
#
# ],
#
# 4:[
# "Excellent quality.",
#
# "Fast delivery.",
#
# "Very satisfied."
#
# ],
#
# 5:[
# "Absolutely amazing!",
#
# "Best product I've purchased.",
#
# "Highly recommended to everyone."
#
# ]
#
# }
#
# #Sep 7- empty list
# reviews=[]
#
# #Generate Reviews
#
# for review_id in range( 1, TOTAL_REVIEWS + 1):
#     #Step 9 - customer
#     customer_id=random.randint(1,TOTAL_CUSTOMERS)
#     #sTEP 10- PRODUCT
#     product_id=random.randint(1,TOTAL_PRODUCTS)
#     # STEP 11 - Rating
#     rating = random.choices(
#
#         [1, 2, 3, 4, 5],
#
#         weights=[5, 10, 15, 35, 35],
#
#         k=1
#
#     )[0]
#     #Sstep 12 - review
#     review_title=random.choice(titles[rating])
#     review_text=random.choice(comments[rating])
#
#     #Step 13- verified purchase
#     verified_purchase = random.choices(
#
#         [True, False],
#
#         weights=[90, 10],
#
#         k=1
#
#     )[0]
#     #Review Date
#     review_date=fake.date_between(
#         start_date="-3y",end_date="today"
#     )
#
#     #Step 16 - Dictionary
#
#     review={
#         "review_id": review_id,
#
#         "customer_id": customer_id,
#
#         "product_id": product_id,
#
#         "rating": rating,
#
#         "review_title": review_title,
#
#         "review_text": review_text,
#
#         "verified_purchase": verified_purchase,
#
#         "review_date": review_date
#     }
#     #Step 17 - append
#     reviews.append(review)
#
# #step 18 - DataFrame
# df=pd.DataFrame(reviews)
#
# #step 19 - save cv
#
# df.to_csv("../../data/raw/reviews.csv",index=False)
#
# #Step 20 - print
# print("Reviews Generated Successfully!")
# print(f"Total Records : {len(df)}")
#
#
