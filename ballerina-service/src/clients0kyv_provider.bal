import ballerina/http;

// Mock client to external KYC provider.
public function getKycData(string userId) returns json|error {
    http:Client kycClient = check new ("https://mock-kyc-provider.com");
    json response = check kycClient->get("/user/" + userId);
    return response;
}