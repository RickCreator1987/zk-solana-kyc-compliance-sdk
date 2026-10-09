module kyc_sdk

import net.http
import json

// KycClient is the main client for the KYC service.
pub struct KycClient {
    base_url string
}

// NewKycClient creates a new client with the given base URL.
pub fn new_kync_client(base_url string) &KycClient {
    return &KycClient{
        base_url: base_url
    }
}

// KycResult represents the result of a KYC check.
pub struct KycResult {
    status string
    risk_score int
    proof string
}

// CheckKyc submits a KYC request.
pub fn (c &KycClient) check_kyc(user_id string, name string, email string) !KycResult {
    payload := {
        "userId": user_id,
        "name": name,
        "email": email
    }
    resp := http.post_json(c.base_url + "/kyc/check", json.encode(payload))!
    if resp.status_code != 200 {
        return error("KYC service returned ${resp.status_code}")
    }
    data := json.decode(map[string]interface{}, resp.text)!
    return KycResult{
        status: data["status"].str()
        risk_score: data["riskScore"].int()
        proof: data["proof"].str()
    }
}