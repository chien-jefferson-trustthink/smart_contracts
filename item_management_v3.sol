// SPDX-License-Identifier: MIT
pragma solidity ^0.5.10;

contract item_management{
    uint item_counter;
    mapping(uint => Item) items;
    uint[] serial_numbers;
    mapping(uint => Record) violations;
    
    
    
    struct Item{
        string asset_type;
        string manufacturer;
        uint th_humidity; // threshold humidity
        uint th_temp; // threshold temperature
        int th_upper_latitude;
        int th_lower_latitude;
        int th_upper_longtitude;
        int th_lower_longtitude;
        uint time; // epoch time
        uint serial_number; // serial_number
    }
    
    struct VT_Pair{
        uint value; //  value 
        uint time; // epoch time
    }
    
    struct Geo_Pair{
        int latitude;
        int longtitude;
        uint time;
    }
    
    struct Record{
        uint humidity_violation_size;
        uint temp_violation_size;
        uint geo_violation_size;
        VT_Pair[] humidity;
        VT_Pair[] temp;
        Geo_Pair[] geo;
    }
    
    
    function addItem(
        string memory my_asset_type,
        string memory my_manufacturer,
        uint my_th_humidity,
        uint my_th_temp,
        int my_th_upper_latitude,
        int my_th_lower_lattitude,
        int my_th_upper_longtitude,
        int my_th_lower_longtitude,
        uint my_time,
        uint my_serial_number
    )
    
        public
    
    {
        if(!isIdValid(my_serial_number)){
            items[my_serial_number] = 
            Item(my_asset_type, my_manufacturer, my_th_humidity, my_th_temp, my_th_upper_latitude, my_th_lower_lattitude, my_th_upper_longtitude, my_th_lower_longtitude, my_time, my_serial_number);
            serial_numbers.push(my_serial_number);
            item_counter++;
            // VT_Pair[] memory temp_humidity;
            // VT_Pair[] memory temp_temp;
            // violations[my_id] = Record(0, 0, temp_humidity, temp_temp);
        }
    }
    
    function getItemCount() public view returns (uint){
        return item_counter;
    }
    
    function getItem(uint my_serial_number) public view returns (string memory, string memory, uint, uint, uint, uint){
        return (items[my_serial_number].asset_type, items[my_serial_number].manufacturer, 
        items[my_serial_number].th_humidity, items[my_serial_number].th_temp, items[my_serial_number].time, items[my_serial_number].serial_number);
    }
    
    // Return 1 for success return -1 for failure
    function addHumidityViolation(uint my_serial_number, uint my_value, uint my_time) public returns (int){
        if(isIdValid(my_serial_number)){
            violations[my_serial_number].humidity.push(VT_Pair(my_value, my_time));
            violations[my_serial_number].humidity_violation_size++;
            return int(1);
        }
        
        return int(-1);
    }
    
    // Return 1 for success return -1 for failure
    function addTempViolation(uint my_serial_number, uint my_value, uint my_time) public returns (int){
        if(isIdValid(my_serial_number)){
            violations[my_serial_number].temp.push(VT_Pair(my_value, my_time));
            violations[my_serial_number].temp_violation_size++;
            return int(1);
        }
        
        return int(-1);
    }
    
    function addGeoViolation(
        uint my_serial_number, 
        int my_latitude, 
        int my_longtitude, 
        uint my_time
    )
        public returns (int)
    {
        if(isIdValid(my_serial_number)){
            violations[my_serial_number].geo.push(Geo_Pair(my_latitude, my_longtitude, my_time));
            violations[my_serial_number].geo_violation_size++;
            
            return int(1);
        }
        
        return int(-1);
    }
    
    function getHumidityViolationSize(uint my_serial_number) public view returns (uint){
        if(isIdValid(my_serial_number)){
            return violations[my_serial_number].humidity_violation_size;
        }
        
        return uint(0);
    }
    
    function getTempViolationSize(uint my_serial_number) public view returns (uint){
        if(isIdValid(my_serial_number)){
            return violations[my_serial_number].temp_violation_size;
        }
        
        return uint(0);
    }
    
    function getGeoViolationSize(uint my_serial_number) public view returns (uint){
        if(isIdValid(my_serial_number)){
            return violations[my_serial_number].geo_violation_size;
        }
        
        return uint(0);
    }
    
    function getHumidityViolationRecord(uint my_serial_number, uint index) public view returns (uint, uint){
        return (violations[my_serial_number].humidity[index].value, violations[my_serial_number].humidity[index].time);
    }
    
    function getTempViolationRecord(uint my_serial_number, uint index) public view returns (uint, uint){
        return (violations[my_serial_number].temp[index].value, violations[my_serial_number].temp[index].time);
    }
    
    function getGeoVilationRecord(
        uint my_serial_number, 
        uint index
    ) 
    
    public view returns 
    
    (
        int, 
        int, 
        uint
    )
    
    {
        return (violations[my_serial_number].geo[index].latitude,
        violations[my_serial_number].geo[index].longtitude, 
        violations[my_serial_number].geo[index].time);
    }
    
    
    function isIdValid(uint my_serial_number) internal view returns (bool){
        bool flag = false;
        for(uint i = 0; i < item_counter; i++){
            if(serial_numbers[i] == my_serial_number){
                flag = true;
                break;
            }
        }
        
        return flag;
    }
}
