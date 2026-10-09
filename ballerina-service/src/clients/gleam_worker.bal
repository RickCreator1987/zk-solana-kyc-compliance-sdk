import ballerina/http;
import ballerina/log;

public type KycResult record {|
    string status;
    int riskScore;
    string proof;
|};

// Submit a KYC job to the Gleam worker.
public function submitKycJob(string userId, string name, string email) returns KycResult|error {
    http:Client gleamClient = check new ("http://localhost:9091");
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