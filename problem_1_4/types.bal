import ballerina/xmldata;

@xmldata:Namespace {
    uri: "http://www.so2w.org",
    prefix: "s"
}
@xmldata:Name {
    value: "employeeFuelRecords"
}
public type EmployeeFuelRecords record {|
    EmployeeFuelRecord[] s\:employeeFuelRecord;
|};

public type EmployeeFuelRecord record {|
    @xmldata:Attribute
    readonly int employeeId;
    int s\:gasFillUpCount;
    decimal s\:totalFuelCost;
    decimal s\:totalGallons;
    int s\:totalMilesAccrued?;
|};

public type OdometerReading record {|
    readonly int employeeId;
    int[] readings;
|};

public type FuelEvent record {|
    int _employeeId;
    int odometerReading;
    decimal gallons;
    decimal gasPrice;
|};
