// Optimized KYC route with connection pooling and async dispatch.
import ballerina/http;
import ballerina/log;
import ballerina/time;
import ballerina/io;
import kyc_service.clients;
import kyc_service.clients.gleam_worker;

// Connection pool for Gleam worker.
http:Client gleamClient = check new ("http://localhost:9091", {
    poolConfig: { maxActiveConnections: 100, waitTimeout: 5 }
});

resource function post /kyc/check(http:Caller caller, http:Request req) returns error? {
    json payload = check req.getJsonPayload();
    string userId = payload.userId.toString();
    string name = payload.name.toString();
    string email = payload.email.toString();
    // ... other fields.

    // Async dispatch to Gleam worker.
    future<gleam_worker:KycResult> futureKyc = start gleam_worker:submitKycJob(userId, name, email);
    gleam_worker:KycResult kycResult = check wait futureKyc;

    // After successful KYC, generate proof if approved.
    string proof = "";
    string public_wallet = "";
    string commitment_root = "";
    if kycResult.status == "approved" {
        // Assume we have these values.
        string kyc_token_hash = "mock_token_hash";
        string user_wallet = userId;
        string provider_secret = "mock_secret";
        string public_wallet = userId;
        string commitment_root = "mock_root";
        // Call proof worker asynchronously.
        future<gleam_worker:ProofResult> futureProof = start gleam_worker:generateProof(
            kyc_token_hash, user_wallet, provider_secret, public_wallet, commitment_root
        );
        gleam_worker:ProofResult proofResult = check wait futureProof;
        proof = proofResult.proof;
        public_wallet = proofResult.public_wallet;
        commitment_root = proofResult.commitment_root;
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