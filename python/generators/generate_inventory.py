

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

TOTAL_INVENTORY = 200000


# ============================================================
# STEP 4 - INVENTORY ID GENERATOR
# ============================================================

def generate_inventory_id(number):

    return f"INV{number:09d}"


# ============================================================
# STEP 5 - READ PRODUCTS
# ============================================================

product_df = pd.read_csv(

    "../../data/raw/products.csv"

)

#  step 6 - valid products

valid_product_df = product_df[product_df["product_id"].notna()].copy()


# step       7- remove duplicate product ids
valid_product_df = valid_product_df.drop_duplicates(subset=["product_id"])

#  step 8 - product lookup

product_lookup = (valid_product_df.set_index("product_id")[
    [
        "product_name","category","subcategory","brand","cost_price","selling_price"
    ]
].to_dict(orient="index"))


# step       9 - product id list

product_ids=list(product_lookup.keys())

# jstpe 10 - warehouse data
from utils.mapping import (
    WAREHOUSES
)

# warehouse id

warehouse_ids = list(WAREHOUSES.keys())

rows=[]
for i in range(1, TOTAL_INVENTORY + 1):
    inventory_id = generate_inventory_id(i)
    product_id = random.choice(product_ids)
    product_info=product_lookup[product_id]
    category = product_info["category"]
    subcategory=product_info["subcategory"]
    warehouse_id=random.choice(warehouse_ids)
    warehouse_info = WAREHOUSES[warehouse_id]
    if category =="Grocery":
        stock_quantity = random.randint(100,2000)
    elif category=="Fashion":
        stock_quantity=random.randint(50,800)
    elif category=="Beauty & Personal Care":
        stock_quantity=random.randint(50,1000)
    elif category=="Books":
        stock_quantity=random.randint(30,500)
    elif category =="Electronics":
        stock_quantity=random.randint(5,200)
    elif category =="Automotive":
        stock_quantity=random.randint(5,150)
    else:
        stock_quantity=random.randint(20,700)

    # reserved quantity
    maximum_reserved = max(0,int(stock_quantity * 0.30))
    reserved_quantity=random.randint(0,maximum_reserved)
    reserved_quantity = (stock_quantity - reserved_quantity)
    available_quantity = (stock_quantity - reserved_quantity)
    reorder_level = random.randint(10,max(10,int(stock_quantity * 0.30)))
    # --------------------------------------------------------
    # REORDER QUANTITY
    # --------------------------------------------------------

    reorder_quantity = random.randint(

        20,

        500

    )
    # STOCK STATUS
    # --------------------------------------------------------

    if available_quantity <= 0:

        stock_status = "Out of Stock"


    elif available_quantity <= reorder_level:

        stock_status = "Low Stock"


    else:

        stock_status = "In Stock"

        # STOCK MOVEMENT
        # --------------------------------------------------------

    stock_in_quantity = random.randint(

        0,

        500

    )

    stock_out_quantity = random.randint(

        0,

        min(

            300,

            max(

                1,

                stock_quantity

            )

        )

    )
    # --------------------------------------------------------
    # LAST RESTOCK DATE
    # --------------------------------------------------------

    last_restock_date = fake.date_between(

        start_date="-1y",

        end_date="today"

    )
    # --------------------------------------------------------
    # INVENTORY RECORD
    # --------------------------------------------------------

    inventory_record = {

        "inventory_id": inventory_id,

        "product_id": product_id,

        "warehouse_id": warehouse_id,

        "warehouse_name":
            warehouse_info[

                "warehouse_name"

            ],

        "warehouse_city":
            warehouse_info[

                "city"

            ],

        "warehouse_state":
            warehouse_info[

                "state"

            ],

        "stock_quantity": stock_quantity,

        "reserved_quantity":
            reserved_quantity,

        "available_quantity":
            available_quantity,

        "reorder_level": reorder_level,

        "reorder_quantity":
            reorder_quantity,

        "stock_status": stock_status,

        "stock_in_quantity":
            stock_in_quantity,

        "stock_out_quantity":
            stock_out_quantity,

        "last_restock_date":
            last_restock_date

    }

    # --------------------------------------------------------
    # APPEND
    # --------------------------------------------------------

    rows.append(

        inventory_record

    )

inventory_df=pd.DataFrame(rows)




# invalid stock status

iss=random.sample(range(len(inventory_df)),600)
inventory_df.loc[iss,"stock_status"]=[random.choice(["Unknown","Available","Error","aflkajf"])
                                      for _ in iss]

# 15.17 - EXTRA SPACES IN WAREHOUSE NAME

extra_spaces=random.sample(range(len(inventory_df)),500)

inventory_df.loc[extra_spaces,"warehouse_name"]=( "  "+ str(inventory_df.loc[extra_spaces,"warehouse_name"]  ) + "  ")




inventory_df.to_csv("../../data/raw/inventory.csv",index=False)

print("total records : ",len(inventory_df))

    