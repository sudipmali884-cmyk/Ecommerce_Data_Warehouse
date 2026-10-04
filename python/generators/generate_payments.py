
# ============================================================
# STEP 1 - IMPORT LIBRARIES
# ============================================================

import random

import pandas as pd

from faker import Faker
# ============================================================
# STEP 2 - FAKE CONFIGURATION
# ============================================================

fake = Faker("en_IN")

random.seed(100)



Faker.seed(100)


# ============================================================
# STEP 3 - TOTAL DATA
# ============================================================

TOTAL_PAYMENTS = 500000

# step4 - payment id generator

def generate_payment_id(number):
    return  f"PAY{number:09d}"

# step 5 - read orders

order_df=pd.read_csv("../../data/raw/orders.csv")

# step 6 - convert order date
order_df["order_date"]=pd.to_datetime(
    order_df["order_date"],
    errors="coerce"
)
# step 7 - remove invlid ids
valid_order_df=order_df[
    order_df["order_id"].notna()
].copy()

# ============================================================
# STEP 8 - REMOVE DUPLICATE ORDER IDs
# ============================================================

valid_order_df = valid_order_df.drop_duplicates(

    subset=["order_id"]

)


# ============================================================
# STEP 9 - ORDER ID LIST
# ============================================================

order_ids = (

    valid_order_df["order_id"]

    .tolist()

)



# ============================================================
# STEP 10 - ORDER LOOKUP
# ============================================================

# IMPORTANT:
#
# We create the lookup once.
#
# No DataFrame filtering inside the loop.


order_lookup = (

    valid_order_df

    .set_index(

        "order_id"

    )[

        [

            "customer_id",

            "order_date",

            "order_status",

            "payment_status",

            "order_total"

        ]

    ]

    .to_dict(

        orient="index"

    )

)

from utils.mapping import (
    PAYMENT_METHODS,PAYMENT_GATEWAYS
)
# ============================================================
# STEP 13 - CURRENCY
# ============================================================

CURRENCY = "INR"


# ============================================================
# STEP 14 - ROWS
# ============================================================

rows = []

# step 15 - generate payments

for i in range(1, TOTAL_PAYMENTS + 1):
    payment_id=generate_payment_id(i)
    order_id = random.choice(order_ids)
    order_info=order_lookup[order_id]
    customer_id=order_info["customer_id"]
    order_date=order_info["order_date"]
    order_status=order_info["order_status"]
    order_total= order_info["order_total"]

    # --------------------------------------------------------
    # HANDLE INVALID ORDER TOTAL
    # --------------------------------------------------------

    if pd.isna(order_total):
        order_total = 500.00

    #payment status
    if order_status == "Returned":
        payment_status = "Refunded"
    elif order_status == "Cancelled":
        payment_status=random.choices(
        ["Failed","Refunded","Pending"],
        weights=[45,35,20]
        )[0]
    elif order_status =="Pending":
        payment_status=random.choices(
            ["Pending","Paid","Failed"],
            weights=[60,30,10]
        )[0]
    else:
        payment_status=random.choices(
            ["Paid","Failed"],
            weights=[98,2]
        )[0]

    #payment method
    payment_method = random.choices(
        PAYMENT_METHODS,
        weights=[
            35,20,15,8,12,7,3
        ]
    )[0]

    if payment_method == "Cash on Delivery":
        payment_gateway= "COD"
    else:
        payment_gateway= random.choice(
            PAYMENT_GATEWAYS
        )

    #payment date
    if order_date is not pd.NaT:
        payment_date = (
            order_date +  pd.Timedelta(
            days=random.randint(0,3)
        )
        )
    else:
        payment_date=pd.Timestamp.today()

    #payment amount
    if payment_status in [

        "Paid",

        "Refunded"

    ]:

        payment_amount = round(

            abs(order_total),

            2

        )


    elif payment_status == "Failed":

        payment_amount = random.choice(

            [

                0.00,

                round(

                    abs(order_total),

                    2

                )

            ]

        )


    else:

        payment_amount = round(

            abs(order_total),

            2

        )
    # --------------------------------------------------------
    # TRANSACTION ID
    # --------------------------------------------------------

    transaction_id = (f"TXN"
                      f"{fake.random_number(digits=12,

            fix_len=True

        )}"

    )
    # --------------------------------------------------------
    # PAYMENT RECORD
    # --------------------------------------------------------

    payment = {

        "payment_id": payment_id,

        "order_id": order_id,

        "customer_id": customer_id,

        "payment_date": payment_date,

        "payment_method": payment_method,

        "payment_gateway": payment_gateway,

        "payment_status": payment_status,

        "payment_amount": payment_amount,

        "currency": CURRENCY,

        "transaction_id": transaction_id

    }

    rows.append(payment)

#     step 16 - create dataframe
payment_df=pd.DataFrame(rows)

# ============================================================
# 17.1 - DUPLICATE PAYMENTS
# ============================================================

duplicate_rows = payment_df.sample(1200,random_state=100)
payment_df = pd.concat([payment_df,duplicate_rows],
    ignore_index=True
)
# null order id
null_order_id=random.sample(range(len(payment_df)),1200)
payment_df.loc[null_order_id,"order_id"]=None

# invali orde ids
invalid_oi=random.sample(range(len(payment_df)),1000)
payment_df.loc[invalid_oi,"order_id"]=[random.choice(
    ["ORDfw34234","ord32092@#","jowiu23","5424.2442"]
)
for _ in invalid_oi
]
# null payment status
null_payment_status=random.sample(range(len(payment_df)),1200)
payment_df.loc[null_payment_status,"payment_status"]=None

# null transaction ids
# ============================================================
# 17.13 - BAD TRANSACTION IDs
# ============================================================

dirty_rows = random.sample(

    range(

        len(payment_df)

    ),

    100

)


payment_df.loc[

    dirty_rows,

    "transaction_id"

] = [random.choice(

    [

        "",

        "ABC",

        "123",

        "INVALID_TXN"

    ]

)
    for _ in dirty_rows

]

# save csv
payment_df.to_csv("../../data/raw/payments.csv",index=False)

print("Data Generated Successfully")
print(f"Total Records : {len(payment_df)}")




# #Step 1 - import libraries
# import pandas as pd
# import random
# import uuid
# from faker import Faker
#
# #Step 2 - Faker
# fake=Faker("en_IN")
#
# #Step 3 - Total Records
#
# TOTAL_PAYMENTS=200000
# TOTAL_ORDERS= 200000
#
# #sTEP 4 - PAYMENT METHODS
#
# payment_methods=[
#     "UPI","Credit Card","Debit Card", "Net Banking","Wallet","Cash on Delivery"
# ]
#
#
# #Step 5 - Payment Gateways
# payment_gateways = [
#
#     "Razorpay",
#
#     "PayU",
#
#     "Stripe",
#
#     "PhonePe",
#
#     "Cashfree",
#
#     "Paytm",
#
#     "Google Pay"
#
# ]
#
# #step 6- Payments status
#
# '''payment_status = random.choices(
#
#     [
#
#         "Success",
#
#         "Failed",
#
#         "Pending",
#
#         "Refunded"
#
#     ],
#
#     weights=[90,5,3,2],# Suppose you generate 100 payments. success=90,failed=5 like this
#
#     k=1 #Return one random item
#
# )[0]'''
#
# #step 7 - banks
# banks = [
#
#     "State Bank of India",
#
#     "HDFC Bank",
#
#     "ICICI Bank",
#
#     "Axis Bank",
#
#     "Kotak Mahindra Bank",
#
#     "Punjab National Bank",
#
#     "Bank of Baroda",
#
#     "Canara Bank"
#
# ]
# #step 8  - Empty list
# payments= []
#
# #Step 9 - Generate Records
# for payment_id in range(1,TOTAL_PAYMENTS +1):
#     #sTEEP 11 - order_ID - each payment belong to one order
#     order_id=payment_id
#
#     #Step 11 - Transaction ID
#     transaction_id= str(uuid.uuid4())
#
#     #Payment Date
#     payment_date=fake.date_time_between( start_date="-3y",
#                                          end_date="now")
#     #Step 13 - Amount
#     amount=round(
#         random.uniform(500,100000),2
#     )
#
#     # Step 13.1 - Payment Method
#     payment_method = random.choice(payment_methods)
#
#     # Step 13.2 - Payment Status & Gateway
#
#     if payment_method == "Cash on Delivery":
#
#         payment_status = "Cash on Delivery"
#
#         payment_gateway = "Cash"
#
#     else:
#
#         payment_status = random.choices(
#
#             [
#                 "Success",
#                 "Failed",
#                 "Pending",
#                 "Refunded"
#             ],
#
#             weights=[90, 5, 3, 2],
#
#             k=1
#
#         )[0]
#
#         payment_gateway = random.choice(payment_gateways)
#
#
#     #Step 14 - create Dictionary
#     payment = {
#
#         "payment_id": payment_id,
#
#         "order_id": order_id,
#
#         "payment_date": payment_date,
#
#         # "payment_method":
#         #     random.choice(payment_methods),
#         "payment_method":payment_method,
#
#         "payment_gateway":payment_gateway,
#         "payment_status":payment_status,
#         # "payment_gateway":
#         #     random.choice(payment_gateways),
#         #
#         # "payment_status":
#         #     payment_status,
#
#         "transaction_id":
#             transaction_id,
#
#         "bank_name":
#             random.choice(banks),
#
#         "amount":
#             amount,
#
#         "currency":
#             "INR",
#
#         "created_at":
#             fake.date_time_between(
#                 start_date=payment_date,
#                 end_date="now"
#             )
#
#     }
#     #Step 15 - Append
#     payments.append(payment)
#
# #Step 16 - Dataframe
# df=pd.DataFrame(payments)
#
# #step 17 save
# df.to_csv("../../data/raw/payments.csv",index=False)
#
# #Step 18 - Print
# print("Payments data generated successfully!")
# print(f"Total Records : {len(df)}")
#
