// Main app component.
module App = {
  @react.component
  let make = () => {
    let (kycResult, setKycResult) = React.useState(() => None)
    let handleKyc = async (_) => {
      let client = KycClient.newKycClient("http://localhost:9090")
      let result = await client.checkKyc("user123", "John Doe", "john@example.com")
      setKycResult(_ => Some(result))
    }
    <div>
      <button onClick={handleKyc}> "Check KYC"->React.string </button>
      {switch kycResult {
      | None => React.null
      | Some(r) => 
        <div>
          <p> {"Status: " ++ r.status}->React.string </p>
          <p> {"Risk Score: " ++ string_of_int(r.riskScore)}->React.string </p>
          <p> {"Proof: " ++ r.proof}->React.string </p>
        </div>
      }}
    </div>
  }
}