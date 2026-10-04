import random
import pandas as pd
from faker import Faker



fake=Faker("en_IN")
random.seed(100)
Faker.seed(100)


TOTAL_PRODUCTS=30000

def generate_product_id(number):
    return f"PROD{number:06d}"

from utils.mapping import (
    CATEGORIES,CATEGORY_SUBCATEGORY_MAPPING,BRANDS,
    SUBCATEGORY_PRICE_MAPPING,CATEGORY_MARKUP_MAPPING
)

PRODUCT_STATUS = [
    "Active","Inactive","Discontinued"
]


rows=[]

# step 10 - generate product records
for i in range(1, TOTAL_PRODUCTS+1):
    product_id=generate_product_id(i)

    category=random.choice(CATEGORIES)

    subcategory = random.choice(CATEGORY_SUBCATEGORY_MAPPING[
        category
    ])

    brand=random.choice(BRANDS)

    product_name=(brand+" "+ subcategory + " "+ fake.word().capitalize())

    # --------------------------------------------------------
    # cost price depends on subcategory
    # --------------------------------------------------------

    minimum_price, maximum_price = (
        SUBCATEGORY_PRICE_MAPPING[
            subcategory
        ]
    )


    cost_price = round(
        random.uniform(
            minimum_price,
            maximum_price
        ),
        2
    )

    # --------------------------------------------------------
    # selling price depends on category markup
    # --------------------------------------------------------

    minimum_markup, maximum_markup = (
        CATEGORY_MARKUP_MAPPING[
            category
        ]
    )

    markup_percentage = random.uniform(
        minimum_markup,
        maximum_markup
    )

    selling_price = round(
        cost_price
        * markup_percentage,
        2
    )
    # --------------------------------------------------------
    # selling price depends on category markup
    # --------------------------------------------------------

    minimum_markup, maximum_markup = (
        CATEGORY_MARKUP_MAPPING[
            category
        ]
    )
    markup_percentage = random.uniform(
        minimum_markup,
        maximum_markup
    )

    selling_price = round(
        cost_price
        * markup_percentage,
        2
    )

    discount_percentage=random.choice([0,5,10,15,20,25,30])

    final_price=round(
        selling_price - (selling_price * discount_percentage/100),2
    )

    product_status= random.choices(
        PRODUCT_STATUS,
        weights=[85,10,5]
    )[0]

    rating = round(
        random.uniform(2.5,5.0),1
    )

    # --------------------------------------------------------
    # SKU
    # --------------------------------------------------------

    sku = (

        "SKU"

        + str(i).zfill(8)

    )

    # --------------------------------------------------------
    # product created date
    # --------------------------------------------------------

    created_at = fake.date_between(

        start_date="-10y",

        end_date="today"

    )

    # --------------------------------------------------------
    # product record
    # --------------------------------------------------------

    product = {

        "product_id": product_id,

        "sku": sku,

        "product_name": product_name,

        "category": category,

        "subcategory": subcategory,

        "brand": brand,

        "cost_price": cost_price,

        "selling_price": selling_price,

        "discount_percentage":
            discount_percentage,

        "final_price": final_price,

        "rating": rating,

        "product_status": product_status,

        "created_at": created_at

    }

    rows.append(product)

product_df=pd.DataFrame(rows)



# ============================================================
# 13.1 - duplicate rows
# ============================================================

duplicate_rows = product_df.sample(300,random_state=100)


product_df = pd.concat([product_df,duplicate_rows],ignore_index=True)

# null product name

null_product_name=random.sample(range(len(product_df)),300)
product_df.loc[null_product_name,"product_name"]=None

# blank product name

blank_rows=random.sample(range(len(product_df)),300)
product_df.loc[blank_rows,"product_name"]=""


# null brands
null_brands=random.sample(range(len(product_df)),350)
product_df.loc[null_brands,"brand"]=""

# blank categories
category_rows=random.sample(range(len(product_df)),500)
product_df.loc[category_rows,"category"]=None

# negative cost prices
rows=random.sample(range(len(product_df)),200)
product_df.loc[rows,"cost_price"]= - abs(product_df.loc[
    rows,"cost_price"])

# invalid rating
rows=random.sample(range(len(product_df)),199)
product_df.loc[rows,"rating"]=random.choice([-1,00,-100,-100000000])
# extra spaces in product name
es= random.sample(range(len(product_df)),200)
product_df.loc[es,"product_name"]=( "  " + product_df.loc[es,"product_name"].fillna("").astype(str) + "  ")

# wrong case
wrong_case=random.sample(range(len(product_df)),250)
product_df.loc[wrong_case,"category"]=(product_df.loc[wrong_case,"category"].fillna("").astype(str).str.upper())


# null rating
rows=random.sample(range(len(product_df)),100)
product_df.loc[rows,"rating"]=None

product_df.to_csv("../../data/raw/products.csv",index=False)

print("Products Generated Suuccessfully")
print(f"Total Records : {len(product_df)}")
print(

    f"Duplicate Rows : "
    f"{product_df.duplicated().sum():,}"

)
print(f"total wrong case : {len(wrong_case)}")
print(f"total blank rows: {len(blank_rows)}")
print(f"total null brands rows: {len(null_brands)}")
print(f" Total null rating : {len(rows)}")
print(f"Null product name:{len(null_product_name)}")












# # step 1 - import libraries
# from operator import index
#
# import  pandas as pd




# import random
# from faker import  Faker
#
# # Step 2 - Faker
# fake=Faker("en_IN")
#
# #Step 3 - record count
#
# TOTAL_PRODUCTS = 20000
#
# #  STEP 4 - CATEGORIES
# categories = {
#
#     "Electronics": [
#         "Mobile","Laptop","Tablet", "Smart Watch", "Headphones","TV"
#     ],
#
#     "Fashion": [
#         "T-Shirt", "Jeans",
#         "Shoes", "Jacket", "Shirt"
#     ],
#
#     "Home & Kitchen": ["Mixer",
#         "Microwave","Dining Table",
#         "Chair", "Cookware"
#     ],
#
#     "Beauty": [
#         "Face Wash", "Perfume", "Lipstick","Shampoo", "Cream"
#     ],
#
#     "Sports": [
#         "Cricket Bat",
#         "Football",
#         "Tennis Racket",
#         "Gym Bag",
#         "Yoga Mat"
#     ],
#
#     "Books": [
#         "Novel",
#         "Biography",
#         "Dictionary",
#         "Programming Book",
#         "Comics"
#     ]
#
# }
#
# # step 5 - brands
#
# brands = [
#
#     "Apple",
#
#     "Samsung",
#
#     "Sony",
#
#     "LG",
#
#     "Dell",
#
#     "HP",
#
#     "Lenovo",
#
#     "Nike",
#
#     "Adidas",
#
#     "Puma",
#
#     "Boat",
#
#     "OnePlus",
#
#     "Mi",
#
#     "Philips",
#
#     "Havells"
#
# ]
#
# #  step 6 - suppliers
# suppliers = [
#
#     "Flipkart",
#
#     "Amazon",
#
#     "Meesho",
#
#     "Myntra",
#
#     " Offline Shop "
# ]
# # step 7 - colors
# colours = [
#
#     "Black",
#
#     "White",
#
#     "Blue",
#
#     "Red",
#
#     "Silver",
#
#     "Grey",
#
#     "Green"
#
# ]
#
# #  step 8 - size
# sizes = [
#
#     "XS",
#
#     "S",
#
#     "M",
#
#     "L",
#
#     "XL",
#
#     "XXL"
#
# ]
#
# #  step 9 - stock status
# stock_status = [
#
#     "In Stock",
#
#     "Low Stock",
#
#     "Out of Stock"
#
# ]
# #  step 10 - empty list
# products = []
#
# #  step 11  - generate products
# for product_id in range (1, TOTAL_PRODUCTS + 1):
#     #     step 12 - select category
#     category = random.choice(list(categories.keys()))
#     sub_category= random.choice(categories[category])
#
#     #  step 13 - generate prices
#     cost_price = round(
#         random.uniform(500,100000),2
#     )
#     selling_price = round(
#         cost_price * random.uniform(1.10,1.60),
#         2
#     )
#     profit= round(
#         selling_price - cost_price,2
#     )
#
#     #  step 14 - create product
#     product = {
#
#         "product_id": product_id,
#
#         "product_name":
#             f"{random.choice(brands)} {sub_category}",
#
#         "brand":
#             random.choice(brands),
#
#         "category":
#             category,
#
#         "sub_category":
#             sub_category,
#
#         "cost_price":
#             cost_price,
#
#         "selling_price":
#             selling_price,
#
#         "profit":
#             profit,
#
#         "supplier":
#             random.choice(suppliers),
#
#         "stock_status":
#             random.choice(stock_status),
#
#         "rating":
#             round(random.uniform(3.0,5.0),1),
#
#         "weight_kg":
#             round(random.uniform(0.20,20),2),
#
#         "colour":
#             random.choice(colours),
#
#         "size":
#             random.choice(sizes),
#
#         "warranty_months":
#             random.choice(
#                 [0,6,12,24,36]
#             ),
#
#         "launch_date":
#             fake.date_between(
#                 start_date="-5y",
#                 end_date="today"
#             ),
#
#         "is_active":
#             random.choice([True,False])
#
#     }
#
#     # step 15 append
#
#     products.append(product)
#
# # step 16 - DAta Frame
#
# df=pd.DataFrame(products)
# #step 17 - save csv
#
# df.to_csv("../../data/raw/products.csv",index=False)
#
# #  step 18 - print
# print("product data generated successfullu!")
# print(f"Total Products : {len(df)}")
#
