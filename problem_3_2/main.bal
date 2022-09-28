// ================================
//       Imported Libraries
// ===============================
import ims/billionairehub;
import ballerina/io;

// # Client ID and Client Secret to connect to the billionaire API
configurable string clientId = "V5bhO97JalSWqUMcItOuKzhf1pca";
configurable string clientSecret = "eeXDwSQOfX_WZ2PMaD2rvOjyCTga";


// ==================================
//       User-Defined Data Types
// ==================================
// Stores information about the billionaries
type Billionaire record {
    string name;
    float netWorth;
};


// ==================================
//       User-Defined Functions
// ==================================
// Returns list of top x billionaires from n countries
public function getTopXBillionaires(string[] countries, int x) returns string[]|error {
    // Create the client connector
    billionairehub:Client cl = check new ({auth: {clientId, clientSecret}});

    Billionaire[] richPeople = [];
    foreach string place in countries {
        Billionaire[] bill=check cl->getBillionaires(place);
        foreach Billionaire item in bill {
            richPeople.push({name:item.name,netWorth: item.netWorth});
        }
    }
    Billionaire[] topOnes = from var e in richPeople
                      order by e.netWorth descending
                      limit x
                      select e;

    string[] res=[];
    foreach Billionaire item in topOnes {
        res.push(item.name);
    }
    return res;
}


public function main()returns error? {
    string[] result =check getTopXBillionaires(["United States"],5);
    io:println(result);

}