// import ballerina/http; // For handling http request
import ballerina/io; // From printing output in console

public function main() {
    io:print("Hello love");
}

// service /greetings on new http:Listener(8000) {
//     resource function get hello(http:Request req) returns string {
//         return "Hello World";
//     }
// }
