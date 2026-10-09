// Optimized client with connection pooling.
import ballerina/http;

http:Client gleamClient = check new ("http://localhost:9091", {
    poolConfig: { maxActiveConnections: 100, waitTimeout: 5 }
});

public type KycResult record {|
    string status;
    int riskScore;
    string proof;
|};

public type ProofResult record {|
    string proof;
    string public_wallet;
    string commitment_root;
|};

public function submitKycJob(string userId, string name, string email) returns KycResult|error {
    json payload = {
        userId: userId,
        name: name,
        email: email
    };
    http:Response response = check gleamClient->post("/kyc", payload);
    json body = check response.getJsonPayload();
    return {
        status: body.status.toString(),
        riskScore: check body.riskScore.toInt(),
        proof: body.proof.toString()
    };
}

public function generateProof(string kyc_token_hash, string user_wallet, string provider_secret, string public_wallet, string commitment_root) returns ProofResult|error {
    json payload = {
        kyc_token_hash: kyc_token_hash,
        user_wallet: user_wallet,
        provider_secret: provider_secret,
        public_wallet: public_wallet,
        commitment_root: commitment_root
    };
    http:Response response = check gleamClient->post("/proof", payload);
    json body = check response.getJsonPayload();
    return {
        proof: body.proof.toString(),
        public_wallet: body.public_wallet.toString(),
        commitment_root: body.commitment_root.toString()
    };
}