// SPDX-License-Identifier: MIT
pragma solidity ^0.6.10;

contract item_management{
    uint item_counter;
    mapping(uint => Item) items;
    uint[] ids;
    mapping(uint => Record) violations;
    
    struct Item{
        string item_type;
        string manufacturer;
        uint th_humidity; // threshold humidity
        uint th_temp; // threshold temperature
        uint time; // epoch time
        uint id; // serial_number
    }
    
    struct VT_Pair{
        uint value; //  value 
        uint time; // epoch time
    }
    
    struct Record{
        uint humidity_violation_size;
        uint temp_violation_size;
        VT_Pair[] humidity;
        VT_Pair[] temp;
    }
    
    
    function addItem(
        string memory my_item_type,
        string memory my_manufacturer,
        uint my_th_humidity,
        uint my_th_temp,
        uint my_time,
        uint my_id
    )
    
        public
    
    {
        items[my_id] = 
        Item(my_item_type, my_manufacturer, my_th_humidity, my_th_temp, my_time, my_id);
        ids.push(my_id);
        item_counter++;
        // VT_Pair[] memory temp_humidity;
        // VT_Pair[] memory temp_temp;
        // violations[my_id] = Record(0, 0, temp_humidity, temp_temp);
        
    }
    
    function getItemCount() public view returns (uint){
        return item_counter;
    }
    
    function getItem(uint my_id) public view returns (string memory, string memory, uint, uint, uint, uint){
        return (items[my_id].item_type, items[my_id].manufacturer, items[my_id].th_humidity, items[my_id].th_temp, items[my_id].time, items[my_id].id);
    }
    
    // Return 1 for success return -1 for failure
    function addHumidityViolation(uint my_id, uint my_value, uint my_time) public returns (int){
        if(isIdValid(my_id)){
            violations[my_id].humidity.push(VT_Pair(my_value, my_time));
            violations[my_id].humidity_violation_size++;
            return int(1);
        }
        
        return int(-1);
    }
    
    // Return 1 for success return -1 for failure
    function addTempViolation(uint my_id, uint my_value, uint my_time) public returns (int){
        if(isIdValid(my_id)){
            violations[my_id].temp.push(VT_Pair(my_value, my_time));
            violations[my_id].temp_violation_size++;
            return int(1);
        }
        
        return int(-1);
    }
    
    function getHumidityViolationSize(uint my_id) public view returns (uint){
        if(isIdValid(my_id)){
            return violations[my_id].humidity_violation_size;
        }
        
        return uint(0);
    }
    
    function getTempViolationSize(uint my_id) public view returns (uint){
        if(isIdValid(my_id)){
            return violations[my_id].temp_violation_size;
        }
        
        return uint(0);
    }
    
    function getHumidityViolationRecord(uint my_id, uint index) public view returns (uint, uint){
        return (violations[my_id].humidity[index].value, violations[my_id].humidity[index].time);
    }
    
    function getTempViolationRecord(uint my_id, uint index) public view returns (uint, uint){
        return (violations[my_id].temp[index].value, violations[my_id].temp[index].time);
    }
    
    
    function isIdValid(uint my_id) internal view returns (bool){
        bool flag = false;
        for(uint i = 0; i < item_counter; i++){
            if(ids[i] == my_id){
                flag = true;
                break;
            }
        }
        
        return flag;
    }
    
    function getTrue() public pure returns (bool){
        return true;
    }
}
