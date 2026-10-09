module kyc_sdk

import net.http
import json
import strings

pub struct KycClient {
    base_url string
    http_client http.Client
}

pub fn new_kyc_client(base_url string) &KycClient {
    return &KycClient{
        base_url: base_url
        http_client: http.new_client()
    }
}

pub struct KycResult {
    status string
    risk_score int
    proof []u8   // binary proof
    public_wallet []u8
    commitment_root []u8
}

// check_kyc with binary transport for proofs.
pub fn (c &KycClient) check_kyc(user_id string, name string, email string) !KycResult {
    payload := {
        "userId": user_id,
        "name": name,
        "email": email
    }
    resp := c.http_client.post_json(c.base_url + "/kyc/check", json.encode(payload))!
    if resp.status_code != 200 {
        return error("KYC service returned ${resp.status_code}")
    }
    // Decode JSON for metadata, but proof is base64 encoded.
    data := json.decode(map[string]interface{}, resp.text)!
    proof_str := data["proof"].str()
    public_wallet_str := data["public_wallet"].str()
    commitment_root_str := data["commitment_root"].str()
    return KycResult{
        status: data["status"].str()
        risk_score: data["riskScore"].int()
        proof: proof_str.bytes()
        public_wallet: public_wallet_str.bytes()
        commitment_root: commitment_root_str.bytes()
    }
}