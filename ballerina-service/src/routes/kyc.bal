import ballerina/http;
import ballerina/log;
import ballerina/time;
import kyc_service.clients;
import kyc_service.clients.gleam_worker;

// Route for initiating KYC check.
resource function post /kyc/check(http:Caller caller, http:Request req) returns error? {
    json payload = check req.getJsonPayload();
    // Extract user data.
    string userId = payload.userId.toString();
    string name = payload.name.toString();
    string email = payload.email.toString();
    // ... other fields.

    // Call Gleam worker to perform KYC verification.
    gleam_worker:KycResult kycResult = check gleam_worker:submitKycJob(userId, name, email);
    // Return result.
    json response = {
        userId: userId,
        status: kycResult.status,
        riskScore: kycResult.riskScore,
        proof: kycResult.proof
    };
    check caller->respond(response);
}

// Route for submitting a ZK proof for on-chain verification.
resource function post /submit-proof(http:Caller caller, http:Request req) returns error? {
    json payload = check req.getJsonPayload();
    string proof = payload.proof.toString();
    string userId = payload.userId.toString();

    // Optionally, submit to Solana via a transaction. For now, just log.
    log:printInfo(string `Proof received for user ${userId}: ${proof}`);
    json response = { status: "received" };
    check caller->respond(response);
}