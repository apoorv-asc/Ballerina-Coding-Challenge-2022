import ballerina/io;
import ballerina/http;

// # The exchange rate API base URL
configurable string apiUrl = "http://localhost:8080";


// # Convert provided salary to local currency
// #
// # + salary - Salary in source currency
// # + sourceCurrency - Soruce currency
// # + localCurrency - Employee's local currency
// # + return - Salary in local currency or error

public function convertSalary(decimal salary, string sourceCurrency, string localCurrency) returns decimal|error {
    http:Client dbClient = check new(apiUrl);
    json money = check dbClient->get("/rates/"+sourceCurrency);
    map<json> mp = <map<json>>check money.rates;
    io:println(mp[localCurrency]);
    
    decimal res = salary*<decimal>mp[localCurrency];
    return res;
}
public function main() returns error?{
    decimal x =check convertSalary(1000,"USD","GBP");
    io:println(x);
}