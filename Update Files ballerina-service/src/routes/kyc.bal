import ballerina/http;
import ballerina/log;
import ballerina/time;
import kyc_service.clients;
import kyc_service.clients.gleam_worker;

resource function post /kyc/check(http:Caller caller, http:Request req) returns error? {
    json payload = check req.getJsonPayload();
    string userId = payload.userId.toString();
    string name = payload.name.toString();
    string email = payload.email.toString();
    // ... other fields.

    // Call Gleam worker to perform KYC verification.
    gleam_worker:KycResult kycResult = check gleam_worker:submitKycJob(userId, name, email);
    
    // After successful KYC, generate a proof (if approved).
    // For demonstration, we'll generate proof with placeholder inputs.
    string proof = "";
    string public_wallet = "";
    string commitment_root = "";
    if kycResult.status == "approved" {
        // In reality, these would be derived from the KYC provider and registry.
        string kyc_token_hash = "mock_token_hash";
        string user_wallet = userId; // Placeholder.
        string provider_secret = "mock_secret";
        string public_wallet = userId;
        string commitment_root = "mock_root";
        (proof, public_wallet, commitment_root) = gleam_worker:generateProof(kyc_token_hash, user_wallet, provider_secret, public_wallet, commitment_root);
    }
    
    json response = {
        userId: userId,
        status: kycResult.status,
        riskScore: kycResult.riskScore,
        proof: proof,
        public_wallet: public_wallet,
        commitment_root: commitment_root
    };
    check caller->respond(response);
}