// Optimized client with binary proof decoding.
module KycClient = {
  type kycResult = {
    status: string,
    riskScore: int,
    proof: array<int>, // binary proof as bytes
    publicWallet: array<int>,
    commitmentRoot: array<int>,
  }

  let newKycClient = (baseUrl: string) => {
    {
      checkKyc: async (userId, name, email) => {
        let payload = {
          "userId": userId,
          "name": name,
          "email": email,
        }
        let response = await Fetch.fetch(baseUrl ++ "/kyc/check", {
          method: Post,
          body: payload->Js.Json.stringify,
          headers: {"Content-Type": "application/json"},
        })
        let json = await response->Fetch.Response.json
        // Decode JSON fields.
        let status = json["status"]->Js.Json.decodeString->Option.getExn
        let riskScore = json["riskScore"]->Js.Json.decodeNumber->Option.getExn->int_of_float
        // Proof is base64 string; decode to bytes.
        let proofBase64 = json["proof"]->Js.Json.decodeString->Option.getExn
        let proof = Base64.decode(proofBase64)->Option.getExn
        let publicWalletBase64 = json["public_wallet"]->Js.Json.decodeString->Option.getExn
        let publicWallet = Base64.decode(publicWalletBase64)->Option.getExn
        let commitmentRootBase64 = json["commitment_root"]->Js.Json.decodeString->Option.getExn
        let commitmentRoot = Base64.decode(commitmentRootBase64)->Option.getExn
        {status, riskScore, proof, publicWallet, commitmentRoot}
      }
    }
  }
}