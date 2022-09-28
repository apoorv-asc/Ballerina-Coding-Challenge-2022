import ballerina/xmldata;
import ballerina/io;

xmlns "http://www.so2w.org" as s;

function processFuelRecords(string inputFilePath, string outputFilePath) returns error? {
    xml file = check io:fileReadXml(inputFilePath);
    xml a = file.<s:FuelEvents>;
    xml FuelEvents = a/<s:FuelEvent>;
    record {|FuelEvent[] FuelEvent;|} rec = check xmldata:toRecord(FuelEvents, false);
    table<EmployeeFuelRecord> key(employeeId) employee_table = table [];
    table<OdometerReading> key(employeeId) odometer_readings = table [];

    foreach var employee in rec.FuelEvent {
        boolean isRecordedBefore = employee_table.hasKey(employee._employeeId);
        boolean isOdometerRecordedBefore = odometer_readings.hasKey(employee._employeeId);

        if (isOdometerRecordedBefore) {
            OdometerReading reading = odometer_readings.get(employee._employeeId);
            reading.readings.push(employee.odometerReading);
        } else {
            odometer_readings.add({employeeId: employee._employeeId, readings: [employee.odometerReading]});
        }

        if isRecordedBefore {
            EmployeeFuelRecord recordedEmployee = employee_table.get(employee._employeeId);
            recordedEmployee.s\:gasFillUpCount += 1;
            recordedEmployee.s\:totalGallons += employee.gallons;
            recordedEmployee.s\:totalFuelCost += employee.gallons * employee.gasPrice;
        } else {
            employee_table.add({employeeId: employee._employeeId, s\:gasFillUpCount: 1, s\:totalFuelCost: employee.gallons * employee.gasPrice, s\:totalGallons: employee.gallons});
        }
    }

    foreach var k in odometer_readings.keys() {
        EmployeeFuelRecord employee = employee_table.get(k);
        OdometerReading reading = odometer_readings.get(k);
        employee.s\:totalMilesAccrued = reading.readings.pop() - reading.readings[0];
    }

    EmployeeFuelRecord[] orderedArray = from EmployeeFuelRecord employee in employee_table
        order by employee.employeeId ascending
        select employee;
    EmployeeFuelRecords records = {s\:employeeFuelRecord: orderedArray};
    xml? xmlResult = check xmldata:toXml(records);
    if xmlResult is () {
        return error("Parsing error.");
    }
    check io:fileWriteXml(outputFilePath, xmlResult);
}
