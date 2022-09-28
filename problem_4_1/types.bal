import ballerina/constraint;

public type OrderRequest record {|
    string username;
    OrderItem[] order_items;
|};

public type OrderItem record {|
    readonly EMenuItems item;
    @constraint:Int {
        minValue: 1
    }
    int quantity;
|};
