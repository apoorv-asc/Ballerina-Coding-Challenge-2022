import ballerina/sql;
import ballerinax/java.jdbc;
import ballerina/io;

sql:ConnectionPool connPool = {maxOpenConnections: 5};
function addEmployee(string dbFilePath, string name, string city, string department, int age) returns int {
    jdbc:Client|sql:Error dbClient = new (url = "jdbc:h2:file:"+dbFilePath, 
        user = "root", 
        password = "root",
        connectionPool = connPool
    );
    if(dbClient is jdbc:Client)
    {
        sql:ParameterizedQuery query =`INSERT INTO Employee(name,city,department,age)
                                    VALUES (${name}, ${city},${department},${age})`;
        sql:ExecutionResult|error result = dbClient->execute(query);
        if(result is sql:ExecutionResult){
            io:println(result);
            return <int>result.lastInsertId;
        }else{
            io:println(result);
            return -1;
        }
    }
    else{
        return -1;
    }
}
public function main() {
    int emp = addEmployee("./db/gofigure", "Alex", "Colombo", "Sales", 24);
    io:println(emp);
}
