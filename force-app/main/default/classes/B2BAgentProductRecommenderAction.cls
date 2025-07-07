/**
* @File Name : B2BAgentProductRecommenderAction.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : June 23, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | June 23, 2025 |   | Initial Version
**/

public with sharing class B2BAgentProductRecommenderAction {

    private static final Integer DEFAULT_MAX_RESULTS = 10;
    private static final Integer DEFAULT_PAGE_NUMBER = 0;

    @InvocableMethod(
        label='Recommend B2B Products (ID, Name, Desc, Image, Price)'
        description='Searches for B2B products based on a given term and returns a list of recommended product IDs, names, descriptions, main image URLs, and prices.'
        category='B2B Commerce'
    )
    public static List<List<RecommendedProductInfo>> recommendProductsBySearchTerm(List<ProductSearchRequest> requests) {
        List<List<RecommendedProductInfo>> allRecommendedProducts = new List<List<RecommendedProductInfo>>();

        if (requests == null || requests.isEmpty()) {
            System.debug('B2BAgentProductRecommenderAction: The request list is null or empty.');
            return allRecommendedProducts;
        }

        for (ProductSearchRequest request : requests) {
            List<RecommendedProductInfo> recommendedProductsForCurrentRequest = new List<RecommendedProductInfo>();

            if (String.isBlank(request.webStoreId) || String.isBlank(request.searchTerm) || String.isBlank(request.effectiveAccountId)) {
                System.debug('B2BAgentProductRecommenderAction: WebStoreId, SearchTerm, or EffectiveAccountId missing in a request. SearchTerm: ' + request.searchTerm);
                allRecommendedProducts.add(recommendedProductsForCurrentRequest);
                continue;
            }

            Integer maxResults = (request.maxResults != null && request.maxResults > 0) ? request.maxResults : DEFAULT_MAX_RESULTS;

            try {
                ConnectApi.ProductSearchInput searchInput = new ConnectApi.ProductSearchInput();
                searchInput.searchTerm = request.searchTerm;
                searchInput.page = DEFAULT_PAGE_NUMBER;
                searchInput.pageSize = maxResults;
                searchInput.fields = new List<String>{'Description'};
                searchInput.includePrices = true;

                ConnectApi.ProductSearchResults searchResults = ConnectApi.CommerceSearch.searchProducts(
                    request.webStoreId,
                    request.effectiveAccountId,
                    searchInput
                );

                if (searchResults != null &&
                    searchResults.productsPage != null &&
                    searchResults.productsPage.products != null &&
                    !searchResults.productsPage.products.isEmpty()) {

                    for (ConnectApi.ProductSummary productSummary : searchResults.productsPage.products) {
                        if (productSummary != null && String.isNotBlank(productSummary.id)) {
                            RecommendedProductInfo prodInfo = new RecommendedProductInfo();
                            prodInfo.productId = productSummary.id;
                            prodInfo.productName = productSummary.name;

                            if (productSummary.fields != null && productSummary.fields.containsKey('Description')) {
                                ConnectApi.FieldValue descriptionField = productSummary.fields.get('Description');
                                if (descriptionField != null && descriptionField.value != null) {
                                    prodInfo.productDescription = String.valueOf(descriptionField.value);
                                } else {
                                    prodInfo.productDescription = '';
                                }
                            } else {
                                prodInfo.productDescription = '';
                            }

                            if (productSummary.defaultImage != null && String.isNotBlank(productSummary.defaultImage.url)) {
                                prodInfo.mainImageUrl = productSummary.defaultImage.url;
                            } else {
                                prodInfo.mainImageUrl = '';
                            }
                            
                            // --- CORRECTION APPLIQUÉE ICI ---
                            try {
                                String jsonSummary = JSON.serialize(productSummary);
                                Map<String, Object> summaryMap = (Map<String, Object>)JSON.deserializeUntyped(jsonSummary);

                                // On cherche la clé "prices" identifiée dans le log
                                if (summaryMap.containsKey('prices') && summaryMap.get('prices') != null) {
                                    // On renomme la variable pour plus de clarté
                                    Map<String, Object> priceMap = (Map<String, Object>)summaryMap.get('prices');
                                    
                                    if (priceMap.containsKey('unitPrice') && priceMap.get('unitPrice') != null) {
                                        prodInfo.productPrice = String.valueOf(priceMap.get('unitPrice'));
                                    } else {
                                        prodInfo.productPrice = 'Price not available';
                                    }
                                } else {
                                    prodInfo.productPrice = 'Price not available';
                                }
                            } catch (Exception e) {
                                prodInfo.productPrice = 'Error getting price';
                                System.debug('B2BAgentProductRecommenderAction: Error processing price for Product ID ' + productSummary.id + '. Error: ' + e.getMessage());
                            }
                            // --- FIN DE LA CORRECTION ---
                            
                            recommendedProductsForCurrentRequest.add(prodInfo);
                        }
                    }
                } else {
                    System.debug('B2BAgentProductRecommenderAction: No products found for term: "' + request.searchTerm + '"');
                }

            } catch (Exception e) {
                 System.debug('B2BAgentProductRecommenderAction Generic Error: Failed to search products for term: "' + request.searchTerm +
                             '". Error: ' + e.toString() + ' Stacktrace: ' + e.getStackTraceString());
            }
            allRecommendedProducts.add(recommendedProductsForCurrentRequest);
        }
        return allRecommendedProducts;
    }

    public class ProductSearchRequest {
        @InvocableVariable(label='Web Store ID' description='ID of the web store where the search should be performed.' required=true)
        public String webStoreId;

        @InvocableVariable(label='Search Term' description='The term to search for products.' required=true)
        public String searchTerm;

        @InvocableVariable(label='Effective Account ID' description='ID of the account for contextual search (pricing, entitlements).' required=true)
        public Id effectiveAccountId;

        @InvocableVariable(label='Max Results' description='Maximum number of product recommendations to return. Defaults to 10.')
        public Integer maxResults;
    }
    
    public class RecommendedProductInfo {
        @InvocableVariable(label='Product ID' description='ID of the recommended product.')
        public String productId;

        @InvocableVariable(label='Product Name' description='Name of the recommended product.')
        public String productName;

        @InvocableVariable(label='Product Description' description='Description of the recommended product.')
        public String productDescription;

        @InvocableVariable(label='Main Image URL' description='URL of the main product image.')
        public String mainImageUrl;

        @InvocableVariable(label='Product Price' description='Unit price of the recommended product for the effective account.')
        public String productPrice;
    }
}