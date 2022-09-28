import ballerina/sql;
import ballerinax/java.jdbc;
import ballerina/io;

type Payment record {
    int employee_id;
    decimal amount;
    string reason;
    string date;
};

function addPayments(string dbFilePath, string paymentFilePath) returns error|int[] {
    jdbc:Client dbClient =check new (url = "jdbc:h2:file:"+dbFilePath, 
        user = "root", 
        password = "root"
    );
    if(dbClient is jdbc:Client){
        json readJson = check io:fileReadJson(paymentFilePath);
        Payment[] recordPayments = check readJson.cloneWithType();
        
        int[] res=[];
        foreach Payment item in recordPayments {
            sql:DateValue x = new(item.date);
            sql:ParameterizedQuery query =`INSERT INTO Payment(employee_id,reason,date,amount)
                                    VALUES (${item.employee_id}, ${item.reason},${x},${item.amount})`;
            sql:ExecutionResult result =check dbClient->execute(query);
            res.push(<int>result.lastInsertId);
        }
        return res;
    }

}

public function main() returns error? {
    int[] a=check addPayments("./db/gofigure", "tests/resources/payments.json");
    io:println(a[0]);
}