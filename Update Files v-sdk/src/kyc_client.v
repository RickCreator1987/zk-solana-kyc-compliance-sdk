module kyc_sdk

import net.http
import json

pub struct KycClient {
    base_url string
}

pub fn new_kyc_client(base_url string) &KycClient {
    return &KycClient{
        base_url: base_url
    }
}

pub struct KycResult {
    status string
    risk_score int
    proof string
    public_wallet string
    commitment_root string
}

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
        public_wallet: data["public_wallet"].str()
        commitment_root: data["commitment_root"].str()
    }
}