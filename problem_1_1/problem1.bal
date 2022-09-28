import ballerina/http; // For handling http request
import ballerina/io; // From printing output in console

public function main() {
    int[] request = [5, 6, 18,56,18,8,1];
    allocateCubicles(request);
    io:print("Hello love");
}


function allocateCubicles(int[] requests) {
    // Write your code here
    int[] req = requests.sort();
    int[] res=[];
    int cv=-1;

    foreach int x in req {
        if(x>cv){
            res.push(x);
            cv=x;
        }
    }
    
    foreach int x in res{
        io:print(x," ");
    }
}

service /greetings on new http:Listener(8000) {
    resource function get hello(http:Request req) returns string {
        // int[] request = [5, 6, 18,56,18,8,1];
        // allocateCubicles(request);
        return "Printed";
    }
}
