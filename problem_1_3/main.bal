import ballerina/io;

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

type TravelDetails record {
    int employeeId;
    int odometerReading;
    decimal gallons;
    decimal gasPrice;
};

type CalulateDetails record {
    readonly int employeeId;
    int gasFillUpCount;
    decimal totalFuelCost;
    decimal totalGallons;
    int strt;
    int end;
};

type SaveToJson record {
    int employeeId;
    int gasFillUpCount;
    decimal totalFuelCost;
    decimal totalGallons;
    int totalMilesAccrued;
};

function processFuelRecords(string inputFilePath, string outputFilePath) returns error? {
    json readJson = check io:fileReadJson(inputFilePath);
    TravelDetails[] readCsv = check readJson.cloneWithType();
    TravelDetails[] entries=[];
    readCsv.forEach(function(TravelDetails entry) {
        entries.push(entry);
    });

    table<CalulateDetails> key(employeeId) save= table[];
    foreach TravelDetails e in entries {
        if save.hasKey(e.employeeId) {
            CalulateDetails t = save.get(e.employeeId);
            save.put(
                {
                    employeeId: e.employeeId,
                    gasFillUpCount: t.gasFillUpCount+1,
                    totalFuelCost: t.totalFuelCost + e.gallons*e.gasPrice,
                    totalGallons: t.totalGallons+e.gallons,
                    strt: min(e.odometerReading,t.strt),
                    end: max(e.odometerReading,t.end)
                }
            );
        }else {
            save.add({
                employeeId: e.employeeId,
                gasFillUpCount: 1,
                totalFuelCost: e.gasPrice*e.gallons,
                totalGallons: e.gallons,
                strt: e.odometerReading,
                end: e.odometerReading
            });
        }
    }

    SaveToJson[] result = [];
    save.forEach(function(CalulateDetails details){
        result.push({
            employeeId: details.employeeId,
            gasFillUpCount: details.gasFillUpCount,
            totalFuelCost: details.totalFuelCost,
            totalGallons: details.totalGallons,
            totalMilesAccrued: details.end-details.strt
        });
    });
    SaveToJson[] sorted = from var e in result
    order by e.employeeId
    select e;
    json res=sorted.toJson();
    check io:fileWriteJson(outputFilePath,res);
}



public function main() returns error?{
    check processFuelRecords("./tests/resources/example01_input.json","./target/example01_output.json");
    
}
