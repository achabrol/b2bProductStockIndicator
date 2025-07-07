**Component Overview**

The B2B Product Stock Indicator is a custom Lightning Web Component (LWC) designed to be placed on product pages within a Salesforce B2B Commerce storefront. Its primary purpose is to provide a clear and immediate visual representation of a product's inventory status to the buyer. The component dynamically displays whether a product is "In Stock," "Low Stock," or "Out of Stock" based on its available quantity.

**Functionality**

The component operates based on the available inventory of a product and a configurable threshold:

In Stock: When the product's quantity is above a predefined "low stock" threshold, the component displays a green indicator with the text "In Stock."

Low Stock: When the quantity is greater than zero but at or below the threshold, it shows an orange indicator with the text "Low Stock" to create a sense of urgency.

Out of Stock: If the quantity is zero, a red indicator with "Out of Stock" is displayed.

In addition to the status, the component also shows the exact number of units currently in stock (e.g., (25 units in stock)), providing precise information to the buyer.

**Configuration**
This component is designed for easy administration directly within the Experience Builder:

Stock Quantity (stockCount): This property is intended to be dynamically bound to the product's inventory. The default binding is 
{!Product.Inventory.details.availableToOrder}, which automatically retrieves real-time inventory data from Salesforce B2B Commerce. 

Low Stock Threshold (lowStockThreshold): An administrator can easily set an integer value for this property. This number defines the inventory level at which the component switches from the "In Stock" status to the "Low Stock" warning. The default is set to 10 units.

This component can be placed on any community page, but it is specifically designed for Product Detail Pages where product inventory context is available.
