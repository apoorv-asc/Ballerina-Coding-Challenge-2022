import ballerina/io;

type TravelDetails record {
    int employee_id;
    int odometer_reading;
    decimal gallons;
    decimal gas_price;
};

type SavedDetails record {
    readonly int employee_id;
    int gas_fill_up_count;
    decimal total_fuel_cost;
    decimal total_gallons;
    int strt;
    int end;

};

type SaveToCsv record {
    int employee_id;
    int gas_fill_up_count;
    decimal total_fuel_cost;
    decimal total_gallons;
    int total_miles_accrued;
};

function processFuelRecords(string inputFilePath, string outputFilePath) returns error? {
    
    io:println("Started Running");
    
    stream<TravelDetails, io:Error?> readCsv = check io:fileReadCsvAsStream(inputFilePath);
    TravelDetails[] entries=[];
    check readCsv.forEach(function(TravelDetails entry) {
        entries.push(entry);
    });

    table<SavedDetails> key(employee_id) save= table[];
    foreach TravelDetails e in entries {
        if save.hasKey(e.employee_id) {
            SavedDetails t = save.get(e.employee_id);
            save.put(
                {
                    employee_id: e.employee_id,
                    gas_fill_up_count: t.gas_fill_up_count+1,
                    total_fuel_cost: t.total_fuel_cost + e.gallons*e.gas_price,
                    total_gallons: t.total_gallons+e.gallons,
                    strt: min(e.odometer_reading,t.strt),
                    end: max(e.odometer_reading,t.end)
                }
            );
        }else {
            save.add({
                employee_id: e.employee_id,
                gas_fill_up_count: 1,
                total_fuel_cost: e.gas_price*e.gallons,
                total_gallons: e.gallons,
                strt: e.odometer_reading,
                end: e.odometer_reading
            });
        }
    }

    SaveToCsv[] result = [];
    save.forEach(function(SavedDetails details){
        result.push({
            employee_id: details.employee_id,
            gas_fill_up_count: details.gas_fill_up_count,
            total_fuel_cost: details.total_fuel_cost,
            total_gallons: details.total_gallons,
            total_miles_accrued: details.end-details.strt
        });
    });

    SaveToCsv[] sorted = from var e in result
    order by e.employee_id
    select e;
    check io:fileWriteCsvFromStream(outputFilePath, sorted.toStream());
}

function max(int v1, int v2) returns int {
    if(v1<v2){
        return v2;
    }
    else{
        return v1;
    }
}

function min(int v1, int v2) returns int {
    if(v1>v2){
        return v2;
    }
    else{
        return v1;
    }
}


public function main() {
    error? processFuelRecordsResult = processFuelRecords("./tests/resources/example02_input.csv","./target/example02_output.csv");
    if processFuelRecordsResult is error {
        io:println("Error occured");
    }else{
        io:println("Everything worked");
    }
}
