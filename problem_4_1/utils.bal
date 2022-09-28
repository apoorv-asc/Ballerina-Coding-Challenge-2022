import ballerina/constraint;

function validateOrderPayload(OrderRequest orderPayload) returns boolean {
    if orderPayload.username == "" {
        return false;
    }

    return validateOrderArray(orderPayload.order_items);
}

function validateOrderArray(OrderItem[] order_items) returns boolean {

    if order_items.length() == 0 {
        return false;
    }

    table<OrderItem> key(item) itemsTable = table key(item) from var item in order_items
        select item;

    if (itemsTable.length() < order_items.length()) {
        return false;
    }

    OrderItem[]|error isValid = constraint:validate(order_items);

    if isValid is error {
        return false;
    }

    return true;
}

function calculateTotal(OrderItem[] order_items) returns int {
    int total = 0;

    foreach var orderItem in order_items {
        total += orderItem.quantity * menu.get(orderItem.item);
    }

    return total;
}
