state_city_map = {

    "Maharashtra": [
        "Mumbai",
        "Pune",
        "Nagpur",
        "Solapur",
        "Nashik", "Sangli",
        "Aurangabad",
        "Kolhapur"
    ],

    "Karnataka": [
        "Bengaluru",
        "Mysuru",
        "Mangaluru",
        "Hubballi"
    ],

    "Gujarat": [
        "Ahmedabad",
        "Surat",
        "Vadodara",
        "Rajkot"
    ],

    "Tamil Nadu": [
        "Chennai",
        "Coimbatore",
        "Madurai",
        "Salem"
    ],

    "Delhi": [
        "Delhi",
        "New Delhi"
    ],

    "Rajasthan": [
        "Jaipur",
        "Jodhpur",
        "Udaipur",
        "Kota"
    ],

    "Uttar Pradesh": [
        "Lucknow",
        "Kanpur",
        "Agra",
        "Varanasi",
        "Noida"
    ],

    "West Bengal": [
        "Kolkata",
        "Howrah",
        "Durgapur"
    ],

    "Punjab": [
        "Ludhiana",
        "Amritsar",
        "Jalandhar",
        "Patiala"
    ],

    "Telangana": [
        "Hyderabad",
        "Warangal",
        "Nizamabad",
        "Karimnagar"
    ]
}
# for products


# ============================================================
# step 5 - categories
# ============================================================

CATEGORIES = [

    "Electronics",

    "Fashion",

    "Home & Kitchen",

    "Beauty & Personal Care",

    "Grocery",

    "Sports & Fitness",

    "Books",

    "Toys & Games",

    "Automotive",

    "Accessories"
]




# ============================================================
# step 6 - category → subcategory mapping
# ============================================================

CATEGORY_SUBCATEGORY_MAPPING = {

    "Electronics": [

        "Mobiles",

        "Laptops",

        "Televisions",

        "Headphones",

        "Cameras",

        "Smart Watches",

        "Speakers"
    ],


    "Fashion": [

        "T-Shirts",

        "Shirts",

        "Jeans",

        "Trousers",

        "Dresses",

        "Sarees",

        "Shoes"
    ],


    "Home & Kitchen": [

        "Cookware",

        "Furniture",

        "Kitchen Appliances",

        "Bedsheets",

        "Storage",

        "Decor"
    ],


    "Beauty & Personal Care": [

        "Skincare",

        "Haircare",

        "Makeup",

        "Perfumes",

        "Personal Care"
    ],


    "Grocery": [

        "Rice",

        "Flour",

        "Snacks",

        "Beverages",

        "Spices",

        "Dry Fruits"
    ],


    "Sports & Fitness": [

        "Cricket",

        "Football",

        "Gym Equipment",

        "Running",

        "Yoga",
    ],


    "Books": [

        "Fiction",

        "Non Fiction",

        "Education",

        "Technology",

        "Children Books"
    ],


    "Toys & Games": [

        "Board Games",

        "Action Figures",

        "Educational Toys",

        "Puzzles",

        "Outdoor Toys"
    ],


    "Automotive": [

        "Car Accessories",

        "Bike Accessories",

        "Cleaning",

        "Lighting",

        "Tools"
    ],


    "Accessories": [

        "Bags",

        "Wallets",

        "Belts",

        "Watches",

        "Sunglasses"
    ]
}


# ============================================================
# step 7 - subcategory price mapping
# ============================================================

SUBCATEGORY_PRICE_MAPPING = {

    # --------------------------------------------------------
    # Electronics
    # --------------------------------------------------------

    "Mobiles": (
        5000,
        100000
    ),

    "Laptops": (
        25000,
        200000
    ),

    "Televisions": (
        15000,
        250000
    ),

    "Headphones": (
        500,
        30000
    ),

    "Cameras": (
        20000,
        300000
    ),

    "Smart Watches": (
        1000,
        50000
    ),

    "Speakers": (
        1000,
        50000
    ),


    # --------------------------------------------------------
    # Fashion
    # --------------------------------------------------------

    "T-Shirts": (
        200,
        3000
    ),

    "Shirts": (
        400,
        5000
    ),

    "Jeans": (
        800,
        6000
    ),

    "Trousers": (
        600,
        5000
    ),

    "Dresses": (
        700,
        8000
    ),

    "Sarees": (
        500,
        25000
    ),

    "Shoes": (
        500,
        15000
    ),


    # --------------------------------------------------------
    # Home & Kitchen
    # --------------------------------------------------------

    "Cookware": (
        300,
        10000
    ),

    "Furniture": (
        3000,
        100000
    ),

    "Kitchen Appliances": (
        1000,
        50000
    ),

    "Bedsheets": (
        400,
        5000
    ),

    "Storage": (
        300,
        10000
    ),

    "Decor": (
        200,
        20000
    ),


    # --------------------------------------------------------
    # Beauty & Personal Care
    # --------------------------------------------------------

    "Skincare": (
        100,
        5000
    ),

    "Haircare": (
        100,
        5000
    ),

    "Makeup": (
        100,
        10000
    ),

    "Perfumes": (
        500,
        25000
    ),

    "Personal Care": (
        100,
        10000
    ),


    # --------------------------------------------------------
    # Grocery
    # --------------------------------------------------------

    "Rice": (
        40,
        3000
    ),

    "Flour": (
        40,
        1000
    ),

    "Snacks": (
        20,
        1000
    ),

    "Beverages": (
        20,
        1000
    ),

    "Spices": (
        30,
        2000
    ),

    "Dry Fruits": (
        200,
        5000
    ),


    # --------------------------------------------------------
    # Sports & Fitness
    # --------------------------------------------------------

    "Cricket": (
        200,
        30000
    ),

    "Football": (
        300,
        10000
    ),

    "Gym Equipment": (
        500,
        100000
    ),

    "Running": (
        500,
        15000
    ),

    "Yoga": (
        200,
        10000
    ),


    # --------------------------------------------------------
    # Books
    # --------------------------------------------------------

    "Fiction": (
        100,
        2000
    ),

    "Non Fiction": (
        100,
        3000
    ),

    "Education": (
        150,
        5000
    ),

    "Technology": (
        200,
        10000
    ),

    "Children Books": (
        50,
        2000
    ),


    # --------------------------------------------------------
    # Toys & Games
    # --------------------------------------------------------

    "Board Games": (
        300,
        5000
    ),

    "Action Figures": (
        200,
        10000
    ),

    "Educational Toys": (
        200,
        10000
    ),

    "Puzzles": (
        100,
        3000
    ),

    "Outdoor Toys": (
        300,
        15000
    ),


    # --------------------------------------------------------
    # Automotive
    # --------------------------------------------------------

    "Car Accessories": (
        300,
        30000
    ),

    "Bike Accessories": (
        200,
        15000
    ),

    "Cleaning": (
        100,
        5000
    ),

    "Lighting": (
        200,
        10000
    ),

    "Tools": (
        200,
        20000
    ),


    # --------------------------------------------------------
    # Accessories
    # --------------------------------------------------------

    "Bags": (
        300,
        15000
    ),

    "Wallets": (
        200,
        10000
    ),

    "Belts": (
        200,
        5000
    ),

    "Watches": (
        500,
        100000
    ),

    "Sunglasses": (
        300,
        30000
    )
}

# ============================================================
# step 8 - category markup mapping
# ============================================================

CATEGORY_MARKUP_MAPPING = {

    "Electronics": (
        1.08,
        1.30
    ),

    "Fashion": (
        1.30,
        2.00
    ),

    "Home & Kitchen": (
        1.20,
        1.60
    ),

    "Beauty & Personal Care": (
        1.30,
        2.20
    ),

    "Grocery": (
        1.05,
        1.25
    ),

    "Sports & Fitness": (
        1.20,
        1.70
    ),

    "Books": (
        1.10,
        1.40
    ),

    "Toys & Games": (
        1.20,
        1.70
    ),

    "Automotive": (
        1.15,
        1.60
    ),

    "Accessories": (
        1.25,
        1.80
    )
}


# ============================================================
# step 7 - brands
# ============================================================

BRANDS = [

    "Samsung",

    "Apple",

    "OnePlus",

    "Sony",

    "LG",

    "HP",

    "Dell",

    "Lenovo",

    "Nike",

    "Adidas",

    "Puma",

    "Levi's",

    "Allen Solly",

    "Boat",

    "Noise",

    "Titan",

    "Prestige",

    "Philips",

    "Havells",

    "Bajaj",

    "Lakme",

    "Maybelline",

    "Loreal",

    "Nestle",

    "Tata",

    "Amul",

    "Britannia",

    "Decathlon",

    "Wildcraft",

    "Parker"
]


# for order

# ============================================================
# step 7 - order status
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
# step 8 - payment status
# ============================================================

PAYMENT_STATUS = [

    "Pending",

    "Paid",

    "Failed",

    "Refunded"

]


# ============================================================
# step 9 - shipping method
# ============================================================

SHIPPING_METHODS = [

    "Standard",

    "Express",

    "Same Day",

    "Economy"

]


#  for order items


CATEGORY_QUANTITY_MAPPING = {

    "Electronics": (

        1,

        2

    ),

    "Fashion": (

        1,

        5

    ),

    "Home & Kitchen": (

        1,

        4

    ),

    "Beauty & Personal Care": (

        1,

        6

    ),

    "Grocery": (

        1,

        10

    ),

    "Sports & Fitness": (

        1,

        4

    ),

    "Books": (

        1,

        5

    ),

    "Toys & Games": (

        1,

        5

    ),

    "Automotive": (

        1,

        3

    ),

    "Accessories": (

        1,

        5

    )

}

# FOR PAYMENTS

# ============================================================
# STEP 11 - PAYMENT METHODS
# ============================================================

PAYMENT_METHODS = [

    "UPI",

    "Credit Card",

    "Debit Card",

    "Net Banking",

    "Cash on Delivery",

    "Wallet",

    "EMI"

]


PAYMENT_GATEWAYS = [

    "Razorpay",

    "PayU",

    "Cashfree",

    "Stripe",

    "PhonePe",

    "Paytm"

]
#  for reviews


# ============================================================
# STEP 15 - REVIEW TITLES
# ============================================================

POSITIVE_TITLES = [

    "Excellent Product",

    "Very Good Product",

    "Worth the Money",

    "Highly Recommended",

    "Amazing Quality",

    "Great Purchase",

    "Loved It",

    "Good Quality",

    "Satisfied With Purchase"

]


NEUTRAL_TITLES = [

    "Average Product",

    "Good But Can Improve",

    "Okay Product",

    "Decent Purchase",

    "Not Bad",

    "Average Quality"

]


NEGATIVE_TITLES = [

    "Not Satisfied",

    "Poor Quality",

    "Disappointed",

    "Not Worth the Money",

    "Bad Product",

    "Very Poor Quality",

    "Would Not Recommend"

]


# ============================================================
# STEP 16 - REVIEW TEXT
# ============================================================

POSITIVE_REVIEWS = [

    "The product quality is excellent and I am very satisfied.",

    "Very good product and worth the money.",

    "The quality is better than expected.",

    "Good product. Delivery was also fast.",

    "I am happy with this purchase.",

    "Excellent quality and good value for money.",

    "Product works perfectly and looks good.",

    "Really satisfied with the purchase.",

    "Highly recommended product."

]


NEUTRAL_REVIEWS = [

    "The product is okay for the price.",

    "Average quality but usable.",

    "The product is decent but can be improved.",

    "Not bad, but I expected slightly better quality.",

    "Product is as described.",

    "Overall an average experience.",

    "The product is fine for regular use."

]


NEGATIVE_REVIEWS = [

    "The quality was not good.",

    "I am disappointed with the product.",

    "Product quality is below expectations.",

    "Not worth the money.",

    "The product stopped working quickly.",

    "I would not recommend this product.",

    "Very poor quality compared with expectations."

]

#  for returns

# ============================================================
# STEP 19 - RETURN REASONS
# ============================================================

RETURN_REASONS = [

    "Damaged Product",

    "Wrong Product",

    "Product Not as Described",

    "Quality Issue",

    "Size Issue",

    "Color Difference",

    "Changed Mind",

    "Received Defective Product",

    "Missing Parts",

    "Late Delivery",

    "Duplicate Order",

    "Other"

]


# ============================================================
# STEP 20 - RETURN CONDITION
# ============================================================

RETURN_CONDITIONS = [

    "Damaged",

    "Used",

    "New",

    "Opened",

    "Defective",

    "Wrong Item",

    "Missing Parts"

]


# ============================================================
# STEP 21 - RETURN STATUSES
# ============================================================

RETURN_STATUSES = [

    "Requested",

    "Approved",

    "Rejected",

    "Picked Up",

    "Received",

    "Refunded",

    "Completed"

]


# ============================================================
# STEP 22 - REFUND METHODS
# ============================================================

REFUND_METHODS = [

    "Original Payment Method",

    "Bank Transfer",

    "UPI",

    "Wallet",

    "Store Credit"

]
# for inventory

WAREHOUSES = {

    "WH001": {

        "warehouse_name": "Mumbai Central Warehouse",

        "city": "Mumbai",

        "state": "Maharashtra"

    },

    "WH002": {

        "warehouse_name": "Pune Distribution Center",

        "city": "Pune",

        "state": "Maharashtra"

    },

    "WH003": {

        "warehouse_name": "Bengaluru Fulfillment Center",

        "city": "Bengaluru",

        "state": "Karnataka"

    },

    "WH004": {

        "warehouse_name": "Hyderabad Warehouse",

        "city": "Hyderabad",

        "state": "Telangana"

    },

    "WH005": {

        "warehouse_name": "Delhi NCR Warehouse",

        "city": "Delhi",

        "state": "Delhi"

    },

    "WH006": {

        "warehouse_name": "Ahmedabad Warehouse",

        "city": "Ahmedabad",

        "state": "Gujarat"

    },

    "WH007": {

        "warehouse_name": "Chennai Fulfillment Center",

        "city": "Chennai",

        "state": "Tamil Nadu"

    },

    "WH008": {

        "warehouse_name": "Kolkata Warehouse",

        "city": "Kolkata",

        "state": "West Bengal"

    }

}