// Client to call the V SDK or directly Ballerina.
// We'll directly call Ballerina for simplicity.
module KycClient = {
  type kycResult = {
    status: string,
    riskScore: int,
    proof: string,
  }

  let newKycClient = (baseUrl: string) => {
    // Return a record with functions.
    {
      checkKyc: (userId, name, email) => {
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
        let status = json["status"]->Js.Json.decodeString->Option.getExn
        let riskScore = json["riskScore"]->Js.Json.decodeNumber->Option.getExn->int_of_float
        let proof = json["proof"]->Js.Json.decodeString->Option.getExn
        {status, riskScore, proof}
      }
    }
  }
}