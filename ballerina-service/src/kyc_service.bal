import ballerina/http;
import ballerina/log;
import kyc_service.routes;
import kyc_service.clients;

// The main service for KYC compliance.
service / on new http:Listener(9090) {
    // Include routes from the routes module.
    function init() returns error? {
        log:printInfo("KYC Service started on port 9090");
    }
}

// Resource functions are defined in routes/kyc.bal.