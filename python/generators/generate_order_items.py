# #step import libraries

import  random
import pandas as pd
from faker import Faker

# STEP 2 - FAKE CONFIGURATION
# ============================================================

fake = Faker("en_IN")

random.seed(100)
Faker.seed(100)


from utils.mapping import (
    CATEGORY_QUANTITY_MAPPING
)
# STEP 4 - ORDER ITEM ID GENERATOR
# ============================================================

def generate_order_item_id(number):

    return f"ITEM{number:09d}"


# ============================================================
# STEP 5 - READ ORDERS
# ============================================================

order_df = pd.read_csv(

    "../../data/raw/orders.csv"

)


# ============================================================
# STEP 6 - READ PRODUCTS
# ============================================================

product_df = pd.read_csv(

    "../../data/raw/products.csv"

)

# ============================================================
# STEP 3 - TOTAL DATA
# ============================================================

TOTAL_ORDER_ITEMS = 800000


# ============================================================
# STEP 7 - CLEAN REQUIRED COLUMNS FOR LOOKUPS
# ============================================================

order_df = order_df[

    order_df["order_id"].notna()

].copy()


product_df = product_df[

    product_df["product_id"].notna()

].copy()
# ============================================================
# STEP 8 - ORDER ID LIST
# ============================================================

order_ids = (

    order_df["order_id"]

    .drop_duplicates()

    .tolist()

)

# ============================================================
# STEP 9 - PRODUCT ID LIST
# ============================================================

product_ids = (

    product_df["product_id"]

    .drop_duplicates()

    .tolist()

)

# ============================================================
# STEP 10 - PRODUCT LOOKUP
# ============================================================

# We create the lookup ONCE.
#
# We do NOT search product_df inside every loop.
#
# This is important because we are generating
# 350,000+ records.


product_lookup = (

    product_df

    .drop_duplicates(

        subset=["product_id"]

    )

    .set_index(

        "product_id"

    )[

        [

            "product_name",

            "category",

            "subcategory",

            "brand",

            "cost_price",

            "selling_price",

            "discount_percentage",

            "final_price"

        ]

    ]

    .to_dict(

        orient="index"

    )

)

# ============================================================
# STEP 11 - ORDER LOOKUP
# ============================================================

order_lookup = (

    order_df

    .drop_duplicates(

        subset=["order_id"]

    )

    .set_index(

        "order_id"

    )[

        [

            "customer_id",

            "order_date",

            "order_status"

        ]

    ]

    .to_dict(

        orient="index"

    )

)
# STEP 13 - ROWS
# ============================================================

rows = []

# ============================================================
# STEP 14 - GENERATE ORDER ITEMS
# ============================================================
for i  in range(1, TOTAL_ORDER_ITEMS + 1):
    order_item_id = generate_order_item_id(i)

    #select real order
    order_id=random.choice(order_ids)
    product_id=random.choice(product_ids)
    product_info=product_lookup[product_id]
    category=product_info["category"]
    unit_price=product_info["selling_price"]
    # --------------------------------------------------------
    # HANDLE INVALID PRODUCT PRICE
    # --------------------------------------------------------

    if pd.isna(unit_price):
        unit_price = 500.00

        # --------------------------------------------------------
        # QUANTITY
        #
        # Quantity depends on category.
        # --------------------------------------------------------

    if category in CATEGORY_QUANTITY_MAPPING:

        minimum_quantity, maximum_quantity = (

            CATEGORY_QUANTITY_MAPPING[

                category

            ]

        )

    else:

        minimum_quantity = 1

        maximum_quantity = 5

    quantity = random.randint(

        minimum_quantity,

        maximum_quantity

    )

    # ITEM DISCOUNT
    # --------------------------------------------------------

    discount_percentage = random.choice(

        [

            0,

            5,

            10,

            15,

            20,

            25,

            30

        ]

    )

    # --------------------------------------------------------
    # GROSS AMOUNT
    # --------------------------------------------------------

    gross_amount = round(

        unit_price

        * quantity,

        2

    )

    # --------------------------------------------------------
    # DISCOUNT AMOUNT
    # --------------------------------------------------------

    discount_amount = round(

        gross_amount

        *

        discount_percentage

        /

        100,

        2

    )


    # --------------------------------------------------------
    # TAX
    # --------------------------------------------------------

    taxable_amount = round(

        gross_amount

        -

        discount_amount,

        2

    )


    tax_amount = round(

        taxable_amount

        * 0.18,

        2

    )


    # --------------------------------------------------------
    # LINE TOTAL
    # --------------------------------------------------------

    line_total = round(

        taxable_amount

        + tax_amount,

        2

    )

    # --------------------------------------------------------
    # ORDER ITEM RECORD
    # --------------------------------------------------------

    order_item = {

        "order_item_id": order_item_id,

        "order_id": order_id,

        "product_id": product_id,

        "quantity": quantity,

        "unit_price": unit_price,

        "discount_percentage":
            discount_percentage,

        "gross_amount": gross_amount,

        "discount_amount": discount_amount,

        "tax_amount": tax_amount,

        "line_total": line_total

    }

    # --------------------------------------------------------
    # APPEND
    # --------------------------------------------------------

    rows.append(

        order_item

    )

# ============================================================
# STEP 15 - CREATE DATAFRAME
# ============================================================

order_item_df = pd.DataFrame(

    rows

)


# ============================================================
# 16.1 - DUPLICATE ROWS
# ============================================================

duplicate_rows = order_item_df.sample(

    500,

    random_state=100

)


order_item_df = pd.concat(

    [

        order_item_df,

        duplicate_rows

    ],

    ignore_index=True

)

# ============================================================
# 16.2 - NULL ORDER IDs
# ============================================================

dirty_rows = random.sample(

    range(

        len(order_item_df)

    ),

    200

)




order_item_df.loc[

    dirty_rows,

    "order_id"

] = None

# ============================================================
# 16.3 - INVALID ORDER IDs
# ============================================================

dirty_rows = random.sample(

    range(

        len(order_item_df)

    ),

    100

)




order_item_df.loc[

    dirty_rows,

    "order_id"

] = random.choice(

    [

        "ORD99999999",

        "INVALID_ORDER",

        "ORDER123",

        "ABC"

    ]

)


# ============================================================
# 16.4 - NULL PRODUCT IDs
# ============================================================

dirty_rows = random.sample(

    range(

        len(order_item_df)

    ),

    200

)
order_item_df.loc[

    dirty_rows,

    "product_id"

] = None


# ============================================================
# 16.5 - INVALID PRODUCT IDs
# ============================================================

dirty_rows = random.sample(

    range(

        len(order_item_df)

    ),

    100

)
order_item_df.loc[

    dirty_rows,

    "product_id"

] = random.choice(

    [

        "PROD999999",

        "INVALID_PRODUCT",

        "PRODUCT123",

        "ABC"

    ]

)


# ============================================================
# 16.10 - WRONG GROSS AMOUNT
# ============================================================

dirty_rows = random.sample(

    range(

        len(order_item_df)

    ),

    150

)
order_item_df.loc[

    dirty_rows,

    "gross_amount"

] = [random.choice(

    [

        -100,

        0,


        9999999

    ]

)
    for _ in dirty_rows]

# save csv
order_item_df.to_csv(
    "../../data/raw/order_items.csv",index=False
)

print("Order items generated successfully ")
print("Total records : ",len(order_item_df))
