// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

contract item_management{
    uint public item_counter = 0;
    mapping(uint => Item) items;
    uint[] serial_numbers;
    
    struct Item{
        uint serial_number;
        string asset_type;
        uint date; //mmddyyyy
        uint time; //hhmmss
        string manufacturer;
    }
    
    function addItem(uint _serial_number, string memory _asset_type, uint _date, 
        uint _time, string memory _manufacturer) public {
        serial_numbers.push(_serial_number);
        items[_serial_number] = Item(_serial_number, _asset_type, _date, _time, _manufacturer);
        item_counter++;
    }
    
    function getItemCount() public view returns (uint){
        return item_counter;
    }
    
    function getSerialNumber(uint _index) public view returns (uint){
        return serial_numbers[_index];
    }
    
    function getItem(uint _serial_number) public view returns (uint, string memory, uint, uint, string memory){
        return (items[_serial_number].serial_number, items[_serial_number].asset_type, items[_serial_number].date,
        items[_serial_number].time, items[_serial_number].manufacturer);
    }
}
