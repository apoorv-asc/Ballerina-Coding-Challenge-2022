import ballerina/log;
import ballerina/http;

map<EOrderStatus> orderStatus = {};

listener http:Listener cakeStationListener = new (port);

service class RequestInterceptor {
    *http:RequestInterceptor;
    resource function 'default [string... path](http:RequestContext ctx, 
                        http:Request req) returns http:NextService|error? {
        json|error payload = req.getJsonPayload();

        if payload is error {
            log:printInfo(string `${req.method} ${req.rawPath}`);
            return ctx.next();
        }
        
        log:printInfo(string `${req.method} ${req.rawPath}`, payload = payload);
        return ctx.next();
    }
}

@http:ServiceConfig {
    interceptors: [new RequestInterceptor()]
}
service / on cakeStationListener {

    private int id = 0;

    function init() {
        log:printInfo("Cake Station Service started successfully!", port = port);
    }

    resource function get menu() returns map<int> {
        return menu;
    }

    resource function post 'order(@http:Payload OrderRequest orderRequest) returns http:BadRequest|http:Created {
        if !validateOrderPayload(orderRequest) {
            return <http:BadRequest>{body: {message: "Invalid Order Payload."}};
        }
        string orderId = int:toHexString(self.id);
        orderStatus[orderId] = "pending";
        self.id += 1;

        return <http:Created>{body: {order_id: orderId, total: calculateTotal(orderRequest.order_items)}};
    }

    resource function get 'order/[string orderId]() returns http:NotFound|http:Ok {
        string? status = orderStatus[orderId];
        if status is () {
            return <http:NotFound>{};
        }

        return <http:Ok>{body: {order_id: orderId, status}};
    }

    resource function put 'order/[string orderId](@http:Payload record {|OrderItem[] order_items;|} order_items) returns http:NotFound|http:Forbidden|http:BadRequest|http:Ok {
        string? status = orderStatus[orderId];
        if status is () {
            return <http:NotFound>{};
        }

        if status !== "pending" {
            return <http:Forbidden>{body: {message: "Cannot update order when pending!"}};
        }

        if !validateOrderArray(order_items.order_items) {
            return <http:BadRequest>{body: {message: "Invalid Order Array!"}};
        }

        return <http:Ok>{body: {order_id: orderId, total: calculateTotal(order_items.order_items)}};
    }

    resource function delete 'order/[string orderId]() returns http:NotFound|http:Forbidden|http:Ok {
        string? status = orderStatus[orderId];
        if status is () {
            return <http:NotFound>{};
        }

        if status !== "pending" {
            return <http:Forbidden>{};
        }
        _ = orderStatus.remove(orderId);

        return <http:Ok>{};
    }
}
