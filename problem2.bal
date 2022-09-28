import ballerina/http; // For handling http request
import ballerina/io; // From printing output in console

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

public function main() {
    string inputFilePath = "./inputCsvFile.csv";
    string outputFilePath = "./outputCsvFile.csv";
    error? processFuelRecordsResult = processFuelRecords(inputFilePath, outputFilePath);
    if processFuelRecordsResult is error {
        io:print("Error while reading");
    }

}

function processFuelRecords(string inputFilePath, string outputFilePath) returns error? {
    stream<TravelDetails, io:Error?> readCsv = check io:fileReadCsvAsStream(inputFilePath);
    TravelDetails[] entries=[];
    check readCsv.forEach(function(TravelDetails entry) {
        entries.push(entry);
    });

    table<SavedDetails> key(employee_id) save= table[];
    foreach TravelDetails e in entries {
        if save.hasKey(e.employee_id) {
            SavedDetails t = save.get(e.employee_id);
            int v1 = t.strt;
            int v2 = e.odometer_reading;
            if(v1>v2){
                int temp = v2;
                v2=v1;
                v1=temp;
            }
            save.put(
                {
                    employee_id: e.employee_id,
                    gas_fill_up_count: t.gas_fill_up_count+1,
                    total_fuel_cost: t.total_fuel_cost + e.gallons*e.gas_price,
                    total_gallons: e.gallons,
                    strt: v1,
                    end:v2
                }
            );
        }else {
            save.add({
                employee_id: e.employee_id,
                gas_fill_up_count: 1,
                total_fuel_cost: e.gas_price,
                total_gallons: e.gallons,
                strt: e.odometer_reading,
                end:0
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

service /greetings on new http:Listener(8000) {
    resource function get hello(http:Request req) returns string {
        return "Hello World";
    }
}
